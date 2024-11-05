const express = require('express')
const pool = require('./db')
const cors = require('cors')
const fetch = require('node-fetch')
const WebSocket = require('ws')

const port = 3000
const rfidAddress = '169.254.39.234'
const webUsername = 'admin'
const webPassword = 'Z3braT3ch*1'

const app = express()
app.use(express.json())
app.use(cors())

// Naughty line needed as I can't be bothered with SSL 
process.env['NODE_TLS_REJECT_UNAUTHORIZED'] = 0

/// Thisftoken will be generated by the RFID reader for auth
let token;

//name of the scanned in user
let scannedName = '';

//id of the scanned in user
let scannedId = '';

//current count of laps
let count = 0;

//scanned car id
let scannedCarId = '';

//scanned car id
let scannedCarTimestamp = '';

//lap times of the scanned car
let lapTimes = [];


//end count of qualifying
const END_COUNT = 10;

//start count of qualifying
const START_COUNT = 3;
// create variable named wss
const wss = new WebSocket.Server({ port: 8080 });
// Handle WebSocket connections
wss.on('connection', (ws) => {
    console.log('Client connected');
  
    ws.on('message', (data) => {
        //if the only has scanned in via barcode, proceed, else do nothing
        if (!scannedName || !scannedId) {
            return;
        }
        //rename response to 
        const dataObj = data.find(element => element.data.idHex === scannedId);


        //if there are no current laps and the car has not been scanned in
        if (!scannedCarId && dataObj?.data?.idHex) {
            scannedCarId = dataObj.data.idHex;
            //the car has been placed under the rfid sensor and is ready for qualifying
            return;
        }

        //if the timestamp has not changed since the last time it was logged, we should do nothing on this tick
        if (data?.timestamp === scannedCarTimestamp) {
            return;
        }

        const lapTimeInMilis = new Date(dataObj.timestamp).getTime() - scannedCarTimestamp.getTime();

        //we should update the timestamp and lap counter
        scannedCarTimestamp = new Date(dataObj.timestamp);

        lapTimes.push(lapTimeInMilis);
        count++;

      // Give to the ws client all lap times to be displayed.
        ws.send(lapTimes);
    });
  
    // Handle client disconnection
    ws.on('close', () => {
      console.log('Client disconnected');
    });
  });
  

// GET all entriess
app.get('/', async (req, res) => {
    try {
        const data = await pool.query('SELECT * FROM monaco')
        res.status(200).send(data.rows);
    } catch (err) {
        console.log(err)
        res.sendStatus(500)
    }
})


//fastest lap
//POST new entry
app.post('/lap', async (req, res) => {
    const {lap_time} = req.body;
    console.log('Finding the current player in the database..');

    //if scannedId exists in the database then we should UPDATE otherwise INSERT
    
        try {
            await pool.query(`INSERT INTO monaco (name, lap_time, team_name, attempts, employee_id)
                VALUES ($1, $2, $3, $4, $5)
                ON CONFLICT (employee_id)
                DO UPDATE
                SET
                    team_name=EXCLUDED.team_name,
                    lap_time=EXCLUDED.lap_time,
                    attempts = monaco.attempts+1`, [scannedName, lap_time, scannedCarId, 0, scannedId]);
        
            res.status(200).send({ message: "Successfully inserted entry into moncaco" })
            resetQualifying();
        } catch (err) {
            console.log(err)
            res.sendStatus(500)
        }

});

app.get('/removeAllEntries', async (req, res) => {
    try {
        await pool.query('DELETE FROM monaco')

        res.status(200).send({ message: "Successfully deleted all entries, but maintained the table structure" })
    } catch (err) {
        console.log(err)
        res.sendStatus(500)
    }
});

app.get('/removeTableFromDb', async (req, res) => {
    try {
        await pool.query('DROP TABLE monaco')

        res.status(200).send({ message: "Successfully deleted monaco from db" })
    } catch (err) {
        console.log(err)
        res.sendStatus(500)
    }
});

//CREATE TABLE
app.get('/setup', async (req, res) => {
    try {
        await pool.query('CREATE TABLE monaco( id SERIAL, name VARCHAR(100), lap_time VARCHAR(100), team_name VARCHAR(100), attempts INT DEFAULT 0, employee_id VARCHAR(100) PRIMARY KEY )')

        res.status(200).send({ message: "Successfully created table" })
    } catch (err) {
        console.log(err)
        res.sendStatus(500)
    }
})


// Connect to RFID Reader
app.get('/start', async (req, res) => {
    try {
        await rfidGetToken();
        await rfidStart();
        res.status(200)
    } catch (e) {
        console.error(e)
        res.sendStatus(500)
    }
})

// Connect to RFID Reader
app.get('/stop', async (req, res) => {
    try {
        if (!token) {
            await rfidGetToken();
        }

        rfidStop();
        console.log('Stopped RFID')
        res.status(200)
    } catch (e) {
        console.error(e)
        res.sendStatus(500)
    }

})

app.post('/scanUser', async (req,res) => {
    const response = req.body;

    const { name, id } = response;
    scannedId = id;
    scannedName = name;

    console.log('Set scanned id to ' + scannedId);
    console.log('Set scanned name to ' + scannedName);

    res.status(200).send({ message: "Successfully scanned user" })
})

function resetQualifying() {
    console.log('resetting qualifying local data');
    scannedId = '';
    scannedName = '';
    scannedCarId = '';
    scannedCarTimestamp = '';
    lapTimes = [];
    count = 0;
}

app.get('/getUser', async (req,res) => {
    console.log('sending user data to the frontend');
    
    res.send({
        scannedId,
        scannedName,
        count
    });
})

app.get('/getLeaderboard', async (req,res) => {
    try {
        const data = await pool.query('SELECT * FROM monaco ORDER BY lap_time ASC LIMIT 10')
        res.status(200).send(data.rows)
    } catch (err) {
        console.log(err)
        res.sendStatus(500)
    }
});

app.get('/getTeamLeaderboard', async (req,res) => {
    try {
        const data = await pool.query('SELECT * FROM monaco ORDER BY lap_time ASC')
        //create array from data.rows of the top 10 employee_id based on their lap_time value in ascending order. The same employee_id cannot appear twice
       const idsList = [];
       const dataList = [];
    
        data.rows.forEach((rowItem) => {
            if (!idsList.includes(rowItem.team_name)) {
                idsList.push(rowItem.team_name);
                dataList.push({
                    team_name: rowItem.team_name,
                    lap_time: rowItem.lap_time
                });
            }
       });


        res.status(200).send(dataList);
    } catch (err) {
        console.log(err)
        res.sendStatus(500)
    }
});

app.listen(port, () => console.log(`Server has started on port: ${port}`))


/**
 * Logs into RFID Reader with secure credentials and returns a token to be 
 * used for all future communications.
 */
async function rfidGetToken() {
    const loginResponse = await fetch(`https://${rfidAddress}/cloud/localRestLogin`, {
        headers: {
            "Authorization": `Basic ${btoa(webUsername + ':' + webPassword)}`
        },
    });

    if (loginResponse.ok) {
        let json = await loginResponse.json();
        token = json.message;
        console.log('Token retrieved' + token)
        return;
    }
    console.log('RFID Token retrieval error')
    throw loginResponse.statusText;
}

/**
 * Starts the RFID Reader sending HTTP POST requests.
 */
async function rfidStart(retryCount = 0) {
    const startResponse = await fetch(`https://${rfidAddress}/cloud/start`, {
        method: "PUT",
        headers: {
            "Authorization": `Bearer ${token}`
        },
    });
    console.log(startResponse);
    if (startResponse.ok) {
        console.log('RFID Started')
        return;
    } else if (retryCount < 2) {
        await rfidGetToken();
        await rfidStop()
        await rfidStart(retryCount + 1)
    } else {
        console.error('RFID Start error')
        throw startResponse.statusText;
    }
}

/**
 * Stops the RFID reader from sending HTTP POST requests
 */
async function rfidStop() {
    const stopResponse = await fetch(`https://${rfidAddress}/cloud/stop`, {
        method: "PUT",
        headers: {
            "Authorization": `Bearer ${token}`
        },
    });

    if (stopResponse.ok) {
        console.log('RFID Stopped')
        return;
    } else {
        console.error('RFID Start error')
        throw stopResponse.statusText;
    }
}
