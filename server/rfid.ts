import { RfidResponse, User } from "./models";
import { debounceTime, wss, setToggling, setToken, token, toggling } from "./server";
import fetch from "node-fetch";
import websocket from "ws";

const webUsername = process.env.WEB_USERNAME;
const webPassword = process.env.WEB_PASSWORD;

/**
 * Logs into RFID Reader with secure credentials and returns a token to be
 * used for all future communications.
 */
export const rfidGetToken = async (rfidAddress: string): Promise<string> => {
  try {
    const loginResponse = await fetch(`https://${rfidAddress}/cloud/localRestLogin`, {
      headers: { Authorization: `Basic ${Buffer.from(`${webUsername}:${webPassword}`).toString("base64")}` },
    });

    if (!loginResponse.ok) {
      console.error("RFID Login error");
      throw new Error(loginResponse.statusText);
    }

    const { message: token } = await loginResponse.json();
    console.log("Token retrieved: " + token);
    return token;
  } catch (e) {
    console.log(e);
    return "";
  }
};

/**
 * Starts the RFID Reader sending HTTP POST requests.
 */
export const rfidStart = async (rfidAddress: string): Promise<void> => {
  if (token === undefined || token === null) {
    setToken(await rfidGetToken(rfidAddress));
  }
  try {
    const startResponse = await fetch(`https://${rfidAddress}/cloud/start`, {
      method: "PUT",
      headers: { Authorization: `Bearer ${token}` },
    });

    if (startResponse.ok) {
      console.log("RFID Started");
      return;
    }
    const json = await startResponse.json();

    if (startResponse.status === 500 && json && json.message.includes("token signature verification failed")) {
      setToken(null);
      return rfidStart(rfidAddress);
    } else if (startResponse.status === 422 && json && json.message.includes("Start currently ongoing")) {
      await rfidStop(rfidAddress);
      await rfidStart(rfidAddress);
    } else {
      console.error("RFID Start error");
      throw startResponse.statusText;
    }
  } catch (e) {
    console.error(e);
  }
};

/**
 * Stops the RFID reader from sending HTTP POST requests
 */
export const rfidStop = async (rfidAddress: string): Promise<void> => {
  if (token === undefined || token === null) {
    setToken(await rfidGetToken(rfidAddress));
  }
  try {
    const stopResponse = await fetch(`https://${rfidAddress}/cloud/stop`, {
      method: "PUT",
      headers: { Authorization: `Bearer ${token}` },
    });

    if (stopResponse.ok) {
      console.log("RFID Stopped");
      return;
    }
    const json = await stopResponse.json();

    if (stopResponse.status === 500 && json && json.message.includes("token signature verification failed")) {
      setToken(null);
      return rfidStart(rfidAddress);
    } else {
      console.error("RFID Start error");
      throw stopResponse.statusText;
    }
  } catch (e) {
    console.error(e);
  }
};

export const rfidScannedCar = (json: RfidResponse): string => {
  console.log("Scanning car");

  let scannedCarId = json.data.idHex;
  wss.clients.forEach((client) => {
    if (client.readyState === websocket.OPEN) {
      client.send(JSON.stringify({ message: "Car scanned", carId: scannedCarId }));
    }
  });
  return scannedCarId;
};

export const rfidQualifyingLap = (timestamp: string, previousTimeStamp: string, lapTimes: number[]): number[] => {
  console.log("Adding new lap");

  const newTime = Date.parse(timestamp);
  const oldTime = Date.parse(previousTimeStamp);

  const lapTime = newTime - oldTime;

  if (lapTime > debounceTime) {
    lapTimes.push(lapTime);
    console.log(lapTimes);
  } else {
    console.log("Lap time too quick");
  }
  return lapTimes;
};

export const rfidRaceLap = (timestamp: string, previousTimeStamp: string, lapTimes: number[]): number[] => {
  console.log("Adding new lap");

  const newTime = Date.parse(timestamp);
  const oldTime = Date.parse(previousTimeStamp);

  const lapTime = newTime - oldTime;

  if (lapTime > debounceTime) {
    console.log("Lap time: " + lapTime);
    lapTimes.push(lapTime);
    // wss.clients.forEach((client) => {
    //   if (client.readyState === websocket.OPEN) {
    //     client.send(JSON.stringify({ lapTimes: lapTimes }));
    //   }
    // });
  } else {
    console.log("Lap time too quick");
  }
  return lapTimes;
};

/**
 * Saves the new JSON data to the last data map
 * @param json - The new JSON data
 * @param lastData - The previous JSON data
 * @returns The updated last data map
 */
export const rfidSaveData = (json: RfidResponse[], lastData: Map<string, string>) => {
  json.forEach((element) => {
    const elementId = element.data.idHex;
    const newTime = Date.parse(element.timestamp);
    if (!lastData.get(elementId) || newTime > Date.parse(lastData.get(elementId)!)) {
      lastData.set(elementId, element.timestamp);
    }
  });
  return lastData;
};

/**
 * Checks if the new JSON data is valid
 * @param newJson - The new JSON data
 * @param scannedId - The scanned ID used to check if the app is in the correct state
 * @returns If the data is valid, true is returned. Otherwise, false is returned.
 */
export const rfidCheckValidity = (newJson: RfidResponse[], users: User[], toggling: boolean): boolean => {
  // console.log("Checking validity'");

  return (
    // wss.readyState === webSocket.OPEN &&
    (users && users.length >= 1 && newJson.length > 0 && newJson[0]?.data?.idHex !== undefined) as boolean
    // &&    !toggling // TODO: Luke put this back
  );
};

/**
 * Compares the new JSON data to the previous JSON data to determine if there is any new data
 * @param oldJson - The previous JSON data
 * @param newJson - The new JSON data
 * @returns If new data is found, the first new entry is returned. Otherwise, null is returned.
 */
export const rfidCompareToPrevious = (oldJson: Map<string, string>, newJson: RfidResponse[]): RfidResponse[] | null => {
  const newEntries = newJson.filter((element) => {
    const elementId = element.data.idHex;
    return !oldJson.get(elementId) || oldJson.get(elementId)! < element.timestamp;
  });

  if (newEntries.length === 0) {
    console.log("No new RFID Data");
    return null;
  }

  console.log(`${newEntries.length} new entries found`);
  return newEntries;
};

/**
 * Toggles the RFID reader on or off
 * @param token - The token to use for the request
 * @param toggling - Whether or not the RFID reader is currently toggling
 */
export const rfidToggle = async (rfidAddress: string) => {
  if (toggling) return;
  setToggling(true);
  try {
    await rfidStop(rfidAddress);
    await rfidStart(rfidAddress);
  } catch (e) {
    console.log(e);
  } finally {
    setToggling(false);
  }
};

/**
 * Adds the RFID time to the user's RFID times
 * @param json - The new JSON data
 * @param rfidTimes - The map of RFID times
 */
export const addToRFIDTimes = (json: RfidResponse, rfidTimes: Map<string, string[]>) => {
  const userRfidTimes = rfidTimes.get(json.data.idHex) ?? [];
  userRfidTimes.push(json.timestamp);
  rfidTimes.set(json.data.idHex, userRfidTimes);
};

export const rfidReaderSetup = async (rfidAddress: string) => {
  try {
    if (token === undefined || token === null) {
      setToken(await rfidGetToken(rfidAddress));
    }

    await fetch(`https://${rfidAddress}/cloud/mode`, {
      method: "PUT",
      body: JSON.stringify({
        type: "SIMPLE",
        transmitPower: "20",
        reportFilter: {
          duration: "3",
          type: "RADIO_WIDE",
        },
      }),
    });
  } catch (e) {
    console.log("Unable to setup RFID reader");
    console.error(e);
  }
};
