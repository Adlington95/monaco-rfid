import express, { Request, Response } from "express";
import cors from "cors";
import websocket from "ws";
import {
  addToRFIDTimes,
  lightToggle,
  rfidCheckValidity,
  rfidCompareToPrevious,
  rfidQualifyingLap,
  rfidRaceLap,
  rfidSaveData,
  rfidScannedCar,
  rfidStart,
  rfidStop,
  rfidToggle,
} from "./rfid";
import { pool } from "./db";
import { delay } from "./utils";
import { RfidResponse, Status, User } from "./models";
import { mockLapWS } from "./mocks";

const port = 3000;

// Time to debounce the RFID reader in milliseconds
export const debounceTime = 2500;

const app = express();
app.use(express.json());
app.use(cors());

// TODO: Test logic for the lights to go on

// Naughty line needed as I can't be bothered with SSL
process.env["NODE_TLS_REJECT_UNAUTHORIZED"] = "0";

/// This token will be generated by the RFID reader for auth
export let token: string | undefined | null;

// Whether the RFID reader is toggling
export let toggling: boolean = false;

let carIds: string[] = [];
let users: User[] = [];

//lap times of the scanned car
let lapTimes: Map<string, number[]> = new Map();
let rfidTimes: Map<string, string[]> = new Map();

let lastData: Map<string, string> = new Map();

let status = Status.READY;

let raceStart = false;

// Create  WebSocket server
export const wss = new websocket.Server({ port: 8080 }).on("connection", (ws) => {
  console.log("Client connected");

  // Handle client disconnection
  ws.on("close", () => {
    return console.log("Client disconnected");
    reset();
  });
});

// GET all entries
app.get("/", async (req, res: Response) => {
  try {
    const data = await pool.query("SELECT * FROM monaco");
    res.status(200).send(data.rows);
  } catch (err) {
    console.log(err);
    res.sendStatus(500);
  }
});

// Clear db table
app.get("/removeAllEntries", async (req, res: Response) => {
  try {
    await pool.query("DELETE FROM monaco");

    res.status(200).send({ message: "Successfully deleted all entries, but maintained the table structure" });
  } catch (err) {
    console.log(err);
    res.sendStatus(500);
  }
});

// Remove table from db
app.get("/removeTableFromDb", async (req, res: Response) => {
  try {
    await pool.query("DROP TABLE monaco");

    res.status(200).send({ message: "Successfully deleted monaco from db" });
  } catch (err) {
    console.log(err);
    res.sendStatus(500);
  }
});

// CREATE TABLE
app.get("/setup", async (_, res: Response) => {
  try {
    await pool.query(
      "CREATE TABLE monaco( id SERIAL, name VARCHAR(100), overall_time VARCHAR(100), lap_time VARCHAR(100), team_name VARCHAR(100), attempts INT DEFAULT 0, employee_id VARCHAR(100) PRIMARY KEY )"
    );

    res.status(200).send({ message: "Successfully created table" });
  } catch (err) {
    console.log(err);
    res.sendStatus(500);
  }
});

// Start RFID Reader
app.get("/start", async (_, res: Response) => {
  try {
    await rfidStart();
    res.status(200);
  } catch (e) {
    console.error(e);
    res.sendStatus(500);
  }
});

// Stop RFID Reader
app.get("/stop", async (_, res: Response) => {
  try {
    rfidStop();
    res.status(200);
  } catch (e) {
    console.error(e);
    res.sendStatus(500);
  }
});

// Get status of the server
app.get("/status", async (_, res: Response) => {
  res.status(200).send({ status: status });
});

// // Get the current users data
// app.get("/getUser", async (_, res: Response) => {
//   console.log("sending user data to the frontend");

//   res.send({ scannedId: qualifyingUserId, scannedName });
// });

app.get("/getLeaderboard", async (req, res) => {
  try {
    const data = await pool.query("SELECT * FROM monaco ORDER BY lap_time ASC LIMIT 10");
    res.status(200).send(data.rows);
  } catch (err) {
    console.log(err);
    res.sendStatus(500);
  }
});

app.get("/getOverallLeaderboard", async (req, res) => {
  try {
    const data = await pool.query("SELECT * FROM monaco ORDER BY overall_time ASC LIMIT 10");
    res.status(200).send(data.rows);
  } catch (err) {
    console.log(err);
    res.sendStatus(500);
  }
});

// Post RFID data
app.post("/rfid", async (req, _) => {
  // console.log("RFID data received.");
  // Check if this is an RFID data response
  if (rfidCheckValidity(req.body, users, toggling)) {
    console.log("Valid");

    // Parse the JSON data, only return new data
    const jsonList = rfidCompareToPrevious(lastData, req.body);
    if (jsonList) {
      rfidToggle();
      jsonList.forEach((json) => {
        if (status !== Status.RACE) {
          // Qualifying

          if (carIds.length > 0 && carIds[0] === json.data.idHex) {
            const userRfidTimes = rfidTimes.get(json.data.idHex);
            const lastRFIDTime = userRfidTimes ? userRfidTimes[userRfidTimes.length - 1] : undefined;
            console.log(userRfidTimes);

            if (lastRFIDTime) {
              console.log("Last RFID time: " + lastRFIDTime);
              lapTimes.set(
                json.data.idHex,
                rfidQualifyingLap(json.timestamp, lastRFIDTime, lapTimes.get(json.data.idHex) ?? [])
              );
              wss.clients.forEach((client) => {
                if (client.readyState === websocket.OPEN) {
                  client.send(JSON.stringify(Object.fromEntries(lapTimes)));
                }
              });
            } else {
              console.log("No previous RFID time");
            }
          } else if (carIds.length === 0) {
            rfidScannedCar(json);
            carIds.push(json.data.idHex);
            rfidTimes.set(json.data.idHex, [json.timestamp]);
            console.log(carIds, rfidTimes);
          } else {
            console.log("Wrong car scanned");
          }

          // if (!carIds.includes(json.data.idHex)) {
          //   // qualifyingCarId = rfidScannedCar(json);

          // } else if (carIds[0] === json.data.idHex) {
          //   const userRfidTimes = rfidTimes.get(json.data.idHex);
          //   const lastRFIDTime = userRfidTimes ? userRfidTimes[userRfidTimes.length - 1] : undefined;
          //   if (lastRFIDTime) {
          //     console.log("Last RFID time: " + lastRFIDTime);
          //     lapTimes.set(
          //       json.data.idHex,
          //       rfidQualifyingLap(json.timestamp, lastRFIDTime, lapTimes.get(json.data.idHex) ?? [])
          //     );
          //     wss.clients.forEach((client) => {
          //       if (client.readyState === websocket.OPEN) {
          //         client.send(JSON.stringify(Object.fromEntries(lapTimes)));
          //       }
          //     });
          //   } else {
          //     console.log("No previous RFID time");
          //     rfidTimes.set(json.data.idHex, [json.timestamp]);
          //   }
          // }
        } else {
          // Race

          if (users.length === 0) {
            console.log("No user scanned");
          } else if (carIds.length < 2 && users.length > 0 && users.length < 3 && !carIds.includes(json.data.idHex)) {
            console.log("Adding new car");
            rfidScannedCar(json);

            carIds.push(json.data.idHex);
            rfidTimes.set(json.data.idHex, [json.timestamp]);
          } else if (carIds.length === 2 && users.length === 2 && carIds.includes(json.data.idHex)) {
            const userRfidTimes = rfidTimes.get(json.data.idHex);
            const lastRFIDTime = userRfidTimes ? userRfidTimes[userRfidTimes.length - 1] : undefined;
            if (raceStart) {
              if (lastRFIDTime) {
                console.log("Last RFID time: " + lastRFIDTime);
                lapTimes.set(
                  json.data.idHex,
                  rfidRaceLap(json.timestamp, lastRFIDTime, lapTimes.get(json.data.idHex) ?? [])
                );
                wss.clients.forEach((client) => {
                  if (client.readyState === websocket.OPEN) {
                    client.send(JSON.stringify(Object.fromEntries(lapTimes)));
                  }
                });
              } else {
                console.log("No previous RFID time");
              }
            } else {
            //jump start - send notification to frontend
            wss.clients.forEach((client) => {
              if (client.readyState === websocket.OPEN) {
                client.send(JSON.stringify({ message: 'jump start detected', carId: json.data.idHex })); //send message to frontend
              }
            });
              console.log("Race not started");
            }
          } else {
            console.log("Something is wrong?");
          }
        }
        addToRFIDTimes(json, rfidTimes);
      });
    }
  } else {
    // console.log("Data not valid");
  }
  lastData = rfidSaveData(req.body, lastData);
});

app.post("/resetRFID", async (req, res) => {
  rfidToggle();
  res.sendStatus(200);
});

app.post("/reset", async (req, res) => {
  rfidToggle();
  reset();
  res.sendStatus(200);
});

const getTopValues = async () => {
  const fastestLap = await pool.query("SELECT * FROM monaco ORDER BY lap_time ASC LIMIT 1");
  const fastestOverall = await pool.query("SELECT * FROM monaco ORDER BY overall_time ASC LIMIT 1");
  const mostAttempts = await pool.query("SELECT * FROM monaco ORDER BY attempts ASC LIMIT 1");

  return {
    fastestLap: fastestLap.rows[0],
    fastestOverall: fastestOverall.rows[0],
    mostAttempts: mostAttempts.rows[0],
  };
};

app.post("/lap", async (req, res) => {
  const { lap_time, overall_time, attempts } = req.body;
  let newFastestLap = false;
  let newFastestOverall = false;
  let newMostAttempts = false;
  console.log("Finding the current player in the database..");

  //if scannedId exists in the database then we should UPDATE otherwise INSERT

  try {
    const { fastestLap, fastestOverall, mostAttempts } = await getTopValues();

    if (lap_time < fastestLap?.lap_time) {
      newFastestLap = true;
    }

    if (overall_time < fastestOverall?.overall_time) {
      newFastestOverall = true;
    }

    if (attempts > mostAttempts?.attempts) {
      newMostAttempts = true;
    }
    if (status !== Status.RACE) {
      await pool.query(
        `INSERT INTO monaco (name, lap_time, team_name, attempts, employee_id, overall_time)
              VALUES ($1, $2, $3, $4, $5, $6)
              ON CONFLICT (employee_id)
              DO UPDATE
              SET
                  team_name=EXCLUDED.team_name,
                  lap_time=EXCLUDED.lap_time,
                  attempts = monaco.attempts+1,
                  overall_time=EXCLUDED.overall_time`,
        [users[0].name, lap_time, carIds, 0, users[0].id, overall_time]
      );
      // TODO: This only works for quali, not race
    }
    res
      .status(200)
      .send({ message: "Successfully inserted entry into monaco", newFastestLap, newFastestOverall, newMostAttempts });
    reset();
  } catch (err) {
    console.log(err);
    res.sendStatus(500);
  }
});

// Post in new user data
app.post("/scanUser", async (req: Request, res: Response) => {
  try {
    const response = req.body;
    const { name, id } = response;
    const maxUsers = status === Status.RACE ? 2 : 1;
    // TODO: I guess we should lock this to a single user when in qualifying mode just in case
    if (!users.some((user) => user.id === id) && users.length < maxUsers) {
      users.push({ name, id } as User);

      console.log("Set scanned id to " + id);

      const data = await pool.query("SELECT * FROM monaco WHERE employee_id = $1 LIMIT 1", [id]);

      //returns nothing if the user does not exist in the database
      //return [UserData] if the user does exist in the database
      res.status(200).send(data.rows[0]);
    } else if (users.some((user) => user.id === id)) {
      res.status(400).send({ message: "User already scanned" });
    } else if (users.length >= maxUsers) {
      res.status(400).send({ message: "Maximum users scanned", status: status, maxUsers: maxUsers });
    }
  } catch (e) {
    console.error(e);
    res.sendStatus(500);
  }
  rfidToggle();
});

// Post for lights to start
app.post("/lights", async (_, res: Response) => {
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
    console.error(e);
    res.sendStatus(500);
  }
});

// Post new status
app.post("/status", async (req: Request, res: Response) => {
  let newStatus = req.body.status;
  status = newStatus;
  console.log("Status updated to " + newStatus);
  reset();
  res.status(200).send({ message: "Status updated" });
});

app.post("/startRace", async (req: Request, res: Response) => {
  if (status === Status.RACE && users.length === 2 && carIds.length === 2) {
    raceStart = true;
    res.sendStatus(200);
  } else {
    res.status(400).send({
      message: "Status not correct or not enough users or cars scanned",
      users: users.length,
      carIds: carIds.length,
      status: status,
    });
  }
});

app.post("/fakeLaps", async (req, res) => {
  console.log("Setting fake laps");
  carIds[0] = "1";

  const intervalId = setInterval(() => {
    const existingLaps = lapTimes.get("1") ?? [];
    lapTimes.set("1", [...existingLaps, Math.floor(Math.random() * 3000) + 5000]);
    mockLapWS(lapTimes);
    if (lapTimes.get("1")?.length === 13) {
      res.sendStatus(200);
      clearInterval(intervalId);
    }
  }, req.body.cadence * 1000);
});

// Start Rest Server
app.listen(port, () => console.log(`Server has started on port: ${port}`));

// Reset qualifying data
const reset = () => {
  console.log("resetting qualifying local data");
  users = [];
  rfidTimes = new Map();
  lapTimes = new Map();
  raceStart = false;
  carIds = [];
};

// Set whether the RFID reader is toggling
export const setToggling = (value: boolean) => (toggling = value);

// Set the token
export const setToken = (value: string | null) => (token = value);
