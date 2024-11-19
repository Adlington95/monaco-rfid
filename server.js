
const express = require('express')
const pool = require('./db')
const cors = require('cors')
const fetch = require('node-fetch')
const WebSocket = require('ws')

const port = 3000
const rfidAddress = process.env.RFID_ADDRESS;
const webUsername = process.env.WEB_USERNAME;
const webPassword = process.env.WEB_PASSWORD;

const debounceTime = 3000; // In milliseconds

const app = express()
app.use(express.json())
app.use(cors())

// TODO: Test if the RFID reader can be connected to
// TODO: Write safety function for if the token is invalid
// TODO: Determine if the RFID reader can be stopped (POST for stop doesnt seem to work)
// TODO: Test the basic logic for the lap times
// TODO: Test the Web socket
// TODO: Test logic for the lights to go on

// Naughty line needed as I can't be bothered with SSL 
process.env['NODE_TLS_REJECT_UNAUTHORIZED'] = 0

/// This token will be generated by the RFID reader for auth
let token;

//name of the scanned in user
let scannedName = null;

//id of the scanned in user
let scannedId = null;

//scanned car id
let scannedCarId = null

//lap times of the scanned car
let lapTimes = [];

let rfidTimes = [];

let lastData = {};

let cutOffTime = 0;

let rfidOn = false;
// create variable named wss
const wss = new WebSocket.Server({ port: 8080 });
// Handle WebSocket connections
wss.on('connection', (ws) => {
    console.log('Client connected');
    cutOffTime = new Date();
    ws.on('message', (data) => {
        //if the only has scanned in via barcode, proceed, else do nothing
        if (!scannedName || !scannedId) {
            return;
        }
        //rename response to 
        const dataObj = data.find(element => element.data.idHex === scannedId);


        // //if there are no current laps and the car has not been scanned in
        // if (!scannedCarId && dataObj?.data?.idHex) {
        //     scannedCarId = dataObj.data.idHex;
        //     //the car has been placed under the rfid sensor and is ready for qualifying
        //     ws.send({
        //         connected: true
        //     });
        //     return;
        // }

        if (!scannedCarId) {
            /// If no car has been scanned, do nothing
            return;
        }

        //if the timestamp has not changed since the last time it was logged, we should do nothing on this tick
        if (data?.timestamp === scannedCarTimestamp) {
            return;
        }

        const lapTimeInMilis = new Date(dataObj.timestamp).getTime() - scannedCarTimestamp.getTime();

        scannedCarTimestamp = new Date(dataObj.timestamp);

        lapTimes.push(lapTimeInMilis);

        // Give to the ws client all lap times to be displayed.
        ws.send(lapTimes);
    });

    // Handle client disconnection
    ws.on('close', () => {
        console.log('Client disconnected');
    });
});


// GET all entries
app.get('/', async (req, res) => {
    try {
        const data = await pool.query('SELECT * FROM monaco')
        res.status(200).send(data.rows);
    } catch (err) {
        console.log(err)
        res.sendStatus(500)
    }
})


app.post('/rfid', async (req, res) => {
    if (rfidOn) {
        console.log('RFID POST request received', new Date().toISOString());
        try {

            let json = req.body;
            console.log(json)
            if (
                // wss.readyState === WebSocket.OPEN &&
                json && Array.isArray(json) && json.length > 0 && json[0].data && json[0].data.
                    idHex
                && json.includes(element => (element.timestamp && Date.parse(element.timestamp) > cutOffTime.getTime()))
            ) {
                console.log('Stringifying data')
                const oldObj = JSON.stringify(lastData)
                const newObj = JSON.stringify(json)

                if (oldObj != newObj) {
                    if (scannedCarId == null) {
                        console.log('First if')
                        // If no car is setup, and the rfid reader reports a difference
                        scannedCarId = json[0].data.idHex;
                        rfidTimes.push(json[0].timestamp);
                        wss.clients.forEach(client => {
                            if (client.readyState === WebSocket.OPEN) {
                                client.send(JSON.stringify({ message: 'Car scanned', carId: scannedCarId }));
                            }
                        });
                        lastData = json;
                        return;
                    } else {
                        // console.log(json, lastData)
                        console.log('Addding lap time')
                        // If a car is setup, and the rfid reader reports a difference
                        let carData = json.find(element => element.data.idHex === scannedCarId);

                        if ((carData && carData.timestamp != rfidTimes[rfidTimes.length - 1])) {
                            const newTime = Date.parse(carData.timestamp);

                            const oldTime = Date.parse(rfidTimes[rfidTimes.length - 1]);
                            const lapTime = newTime - oldTime;
                            console.log(`Old Time: ${new Date(oldTime).toLocaleString()}`);
                            console.log('newTime: ' + new Date(newTime).toLocaleString())
                            console.log(lapTime)
                            if (rfidTimes.length == 0 || (lapTime > debounceTime)) {
                                console.log('Lap time: ' + lapTime)
                                rfidTimes.push(carData.timestamp);
                                lapTimes.push(lapTime)
                                wss.clients.forEach(client => {
                                    if (client.readyState === WebSocket.OPEN) {
                                        client.send(JSON.stringify({ lapTimes: lapTimes }));
                                    }
                                });
                                lastData = json;

                            } else {
                                console.log('Lap times too quick!')
                            }
                        } else {
                            console.log("lap failed")
                        }

                    }
                } else {
                    console.log('No new data')
                }


            } else {
                return;
            }

        } catch (e) {
            console.error(e)
        }
    }
})

//fastest lap
//POST new entry
app.post('/lap', async (req, res) => {
    const { lap_time } = req.body;
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

        res.status(200).send({ message: "Successfully inserted entry into monaco" })
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

app.post('/scanUser', async (req, res) => {
    try {
        const response = req.body;
        const { name, id } = response;
        scannedId = id;
        scannedName = name;

        console.log('Set scanned id to ' + scannedId);
        console.log('Set scanned name to ' + scannedName);

        const data = await pool.query('SELECT * FROM monaco WHERE employee_id = $1 LIMIT 1', [scannedId])

        //returns [] if the user does not exist in the database
        //return [UserData] if the user does exist in the database
        res.status(200).send(data.rows);
    } catch (e) {
        console.error(e)
        res.sendStatus(500)
    }

})

app.post('/lights', async (req, res) => {
    try {
        // All lights off
        lightToggle(1, false);
        lightToggle(2, false);
        lightToggle(3, false);
        lightToggle(4, false);

        // Small wait
        await delay(3000);

        // Lights on in sequence
        lightToggle(1, true);
        await delay(1000);
        lightToggle(2, true);
        await delay(1000);
        lightToggle(3, true);
        await delay(1000);
        lightToggle(4, true);

        // Random delay
        await delay(Math.floor(Math.random() * 5000) + 800);

        // All lights off
        lightToggle(1, false);
        lightToggle(2, false);
        lightToggle(3, false);
        lightToggle(4, false);
        res.sendStatus(200);
    } catch (e) {
        console.error(e)
        res.sendStatus(500)
    }
});

const Status = {
    'READY': 1,
    'USER_SCANNED': 2,
    'CAR_SCANNED': 3,
    'PRACTICE': 4,
    'QUALIFYING': 5,
    'QUALIFYING_COMPLETE': 6,
    'UNKNOWN': 0,
}

app.get('/status', async (req, res) => {
    let status = Status.UNKNOWN;

    if (!scannedId) {
        status = Status.READY;
    } else if (scannedId && !scannedCarId) {
        status = Status.USER_SCANNED;
    } else if (scannedId && scannedCarId && lapTimes.length === 0) {
        status = Status.CAR_SCANNED;
    } else if (scannedId && scannedCarId && lapTimes.length > 0 && lapTimes.length <= 4) {
        status = Status.PRACTICE;
    } else if (scannedId && scannedCarId && lapTimes.length > 4) {
        status = Status.QUALIFYING;
    }
    //TODO: Add check for qualifying complete

    res.status(200).send({ status: status })
});

app.post('/status', async (req, res) => {

    let status = req.body.status;
    console.log(req.body)

    switch (status) {
        case Status.READY:
            resetQualifying();
            break;
        case Status.USER_SCANNED:
            scannedCarId = null;
            scannedCarTimestamp = null;
            rfidTimes = [rfidTimes.pop()];
            break;
        case Status.CAR_SCANNED:
            scannedCarTimestamp = null;
            lapTimes = [];
            break;
        case Status.PRACTICE:
            while (lapTimes.length > 3) lapTimes.shift();
            break;
        case Status.QUALIFYING:
            while (lapTimes.length > 4) lapTimes.shift();
            break;
        case Status.QUALIFYING_COMPLETE:
            // Handle qualifying complete status
            break;
        default:
            console.log('Unknown status');
    }





    console.log('Status updated to ' + status);
    //TODO: 

    res.status(200).send({ message: 'Status updated' })
});

const delay = ms => new Promise(res => setTimeout(res, ms));

async function lightToggle(num, on) {
    if (token == null) {
        await rfidGetToken();
    }
    fetch(`https://${rfidAddress}/cloud/gpo`, {
        method: "POST",
        headers: {
            "Authorization": `Bearer ${token}`
        },
        body: JSON.stringify({
            "port": num,
            "state": !on
        })
    });
}


function resetQualifying() {
    console.log('resetting qualifying local data');
    scannedId = null
    scannedName = null
    scannedCarId = null
    scannedCarTimestamp = null
    lapTimes = [];
}

app.get('/getUser', async (req, res) => {
    console.log('sending user data to the frontend');

    res.send({
        scannedId,
        scannedName
    });
})

app.get('/getLeaderboard', async (req, res) => {
    try {
        const data = await pool.query('SELECT * FROM monaco ORDER BY lap_time ASC LIMIT 10')
        res.status(200).send(data.rows)
    } catch (err) {
        console.log(err)
        res.sendStatus(500)
    }
});

app.get('/getTeamLeaderboard', async (req, res) => {
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
        console.log('Token retrieved: ' + token)
        return;
    }
    console.log('RFID Token retrieval error')
}

/**
 * Starts the RFID Reader sending HTTP POST requests.
 */
async function rfidStart() {
    if (token == null) {
        await rfidGetToken();
    }
    const startResponse = await fetch(`https://${rfidAddress}/cloud/start`, {
        method: "PUT",
        headers: {
            "Authorization": `Bearer ${token}`
        },
    });

    if (startResponse.ok) {
        console.log('RFID Started')
        cutOffTime = Date();
        return;
    }
    const json = await startResponse.json();

    if (startResponse.status === 500 && json && json.message.includes('token signature verification failed')) {
        token = null;
        return rfidStart();
    } else if (startResponse.status === 422 && json && json.message.includes('Start currently ongoing')) {
        await rfidStop();
        await rfidStart();
    } else {
        console.error('RFID Start error')
        throw startResponse.statusText;
    }
}

/**
 * Stops the RFID reader from sending HTTP POST requests
 */
async function rfidStop() {
    if (token == null) {
        await rfidGetToken();
    }
    const stopResponse = await fetch(`https://${rfidAddress}/cloud/stop`, {
        method: "PUT",
        headers: {
            "Authorization": `Bearer ${token}`
        },
    });

    if (stopResponse.ok) {
        console.log('RFID Stopped')
        return;
    }
    const json = await startResponse.json();

    if (startResponse.status === 500 && json && json.message.includes('token signature verification failed')) {
        token = null;
        return rfidStart();
    } else {
        console.error('RFID Start error')
        throw startResponse.statusText;
    }

}

