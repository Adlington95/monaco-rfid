import { wss } from "./server";
import websocket from "ws";

export const mockLapWS = (lapTimes: Map<string, number[]>) => {
  console.log("Sending fake laps, ", lapTimes);
  wss.clients.forEach((client) => {
    if (client.readyState === websocket.OPEN) {
      client.send(JSON.stringify(Object.fromEntries(lapTimes)));
    }
  });
};
