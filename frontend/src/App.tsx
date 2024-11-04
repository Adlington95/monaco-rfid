import React, { useEffect, useState } from "react";
import logo from "./logo.svg";
import "./App.css";
// import { COLUMNS } from './data/columns';

const COLUMNS = ["Name", "Team Name", "Lap Time"];

function App() {
  const [monacoData, setMonacoData] = useState([]);

  useEffect(() => {
    fetch("http://localhost:13000")
      .then((res) => res.json())
      .then((data) => {
        setMonacoData(data);
      });
  }, []);

  return (
    <div className="App">
      <header className="App-header">
        {monacoData.length ? (
          <>
            <table>
              <thead>
                <tr>
                  {COLUMNS.map((column: any) => (
                    <th key={column.id}>{column}</th>
                  ))}
                </tr>
              </thead>
              <tbody>
                {monacoData.map((row: any, index: number) => (
                  <tr key={index} style={{ padding: "12px" }}>
                    {COLUMNS.map((column: any, colIndex: number) =>
                      column === "Name" ? (
                        <td style={{ padding: "12px" }} key={colIndex}>
                          {row.name}
                        </td>
                      ) : column === "Team Name" ? (
                        <td style={{ padding: "12px" }} key={colIndex}>
                          {row.team_name}
                        </td>
                      ) : (
                        <td style={{ padding: "12px" }} key={colIndex}>
                          {row.lap_time}
                        </td>
                      )
                    )}
                  </tr>
                ))}
              </tbody>
            </table>
          </>
        ) : (
          <p>Loading...</p>
        )}
      </header>
    </div>
  );
}

export default App;
