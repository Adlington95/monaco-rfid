import { RfidResponse } from "./models";
import { debounceTime, wss } from "./server";

const nodefetch = require("node-fetch");

const webUsername = process.env.WEB_USERNAME;
const webPassword = process.env.WEB_PASSWORD;
const rfidAddress = process.env.RFID_ADDRESS;

/**
 * Logs into RFID Reader with secure credentials and returns a token to be
 * used for all future communications.
 */
export const rfidGetToken = async (): Promise<string | undefined> => {
  try {
    const loginResponse = await nodefetch(`https://${rfidAddress}/cloud/localRestLogin`, {
      headers: {
        Authorization: `Basic ${btoa(webUsername + ":" + webPassword)}`,
      },
    });

    if (loginResponse.ok) {
      const json = await loginResponse.json();
      const token = json.message;
      console.log("Token retrieved: " + token);
      return token;
    }
  } catch (e) {
    console.error(e);
  }
  return;
};

/**
 * Starts the RFID Reader sending HTTP POST requests.
 */
export const rfidStart = async (token: string | undefined): Promise<void> => {
  if (token == undefined) {
    token = await rfidGetToken();
  }
  const startResponse = await nodefetch(`https://${rfidAddress}/cloud/start`, {
    method: "PUT",
    headers: {
      Authorization: `Bearer ${token}`,
    },
  });

  if (startResponse.ok) {
    console.log("RFID Started");
    return;
  }
  const json = await startResponse.json();

  if (startResponse.status === 500 && json && json.message.includes("token signature verification failed")) {
    token = undefined;
    return rfidStart(token);
  } else if (startResponse.status === 422 && json && json.message.includes("Start currently ongoing")) {
    await rfidStop(token);
    await rfidStart(token);
  } else {
    console.error("RFID Start error");
    throw startResponse.statusText;
  }
};

/**
 * Stops the RFID reader from sending HTTP POST requests
 */
export const rfidStop = async (token: string | undefined): Promise<void> => {
  if (token == undefined) {
    token = await rfidGetToken();
  }
  const stopResponse = await nodefetch(`https://${rfidAddress}/cloud/stop`, {
    method: "PUT",
    headers: {
      Authorization: `Bearer ${token}`,
    },
  });

  if (stopResponse.ok) {
    console.log("RFID Stopped");
    return;
  }
  const json = await stopResponse.json();

  if (stopResponse.status === 500 && json && json.message.includes("token signature verification failed")) {
    token = undefined;
    return rfidStart(token);
  } else {
    console.error("RFID Start error");
    throw stopResponse.statusText;
  }
};

export const rfidScannedCar = (json: RfidResponse): string => {
  console.log("Scanning car");

  let scannedCarId = json.data.idHex;
  wss.clients.forEach((client) => {
    if (client.readyState === WebSocket.OPEN) {
      client.send(JSON.stringify({ message: "Car scanned", carId: scannedCarId }));
    }
  });
  return scannedCarId;
};

export const rfidLap = (timestamp: string, previousTimeStamp: string, lapTimes: number[]): number[] => {
  console.log("Adding new lap");

  const newTime = Date.parse(timestamp);
  const oldTime = Date.parse(previousTimeStamp);

  const lapTime = newTime - oldTime;

  if (lapTime > debounceTime) {
    console.log("Lap time: " + lapTime);
    lapTimes.push(lapTime);
    wss.clients.forEach((client) => {
      if (client.readyState === WebSocket.OPEN) {
        client.send(JSON.stringify({ lapTimes: lapTimes }));
      }
    });
  } else {
    console.log("Lap time too quick");
  }
  return lapTimes;
};

export const rfidSaveData = (json: RfidResponse[], lastData: string[]) => {
  json.forEach((element) => {
    const elementId = element.data.idHex;

    if (lastData && lastData[elementId]) {
      const oldTime = Date.parse(lastData[elementId]);
      const newTime = Date.parse(element.timestamp);
      if (newTime > oldTime) {
        lastData[element.data.idHex] = element.timestamp;
      }
    } else {
      lastData[element.data.idHex] = element.timestamp;
    }
  });

  return lastData;
};

export const rfidCheckValidity = (newJson: RfidResponse, scannedId: String | undefined) => {
  return (
    // wss.readyState === WebSocket.OPEN &&
    scannedId && newJson && Array.isArray(newJson) && newJson.length > 0 && newJson[0].data && newJson[0].data.idHex
  );
};

function rfidCompareToPrevious(oldJson: RfidResponse, newJson: RfidResponse[]) {
  // console.log(newJson)
  if (oldJson) {
    // const count = newJson.filter(element => {
    //     return !(oldJson[element.data.idHex] && oldJson[element.data.idHex] === element.timestamp);
    // });

    const count = newJson.reduce((acc, element) => {
      const elementId = element.data.idHex;
      if (oldJson[elementId] == null || oldJson[elementId] == undefined) {
        acc.set(elementId, element.timestamp);
      } else if (oldJson[elementId] && oldJson[elementId] < element.timestamp) {
        acc.set(elementId, element.timestamp);
      }

      return acc;
    }, new Map());
    console.log(count);
    console.log(count.size);
    console.log(typeof count);
    if (count.size == 0) {
      console.log("No new RFID Data");
      return null;
    } else if (count.size == 1) {
      console.log("1 new entry found");
      console.log(count[0]);

      const first = count.entries().next().value;
      return { data: { idHex: first[0] }, timestamp: first[1] };
    } else {
      console.log(count.size + " new entries found");
      console.log("Returning first new value");

      const first = count.entries().next().value;
      return { data: { idHex: first[0] }, timestamp: first[1] };
    }
  } else {
    console.log("No previous data to compare against");
    return null;
  }
}

async function rfidToggle() {
  if (toggling) return;
  toggling = true;
  await rfidStop(token);
  await rfidStart(token);
  toggling = false;
}
