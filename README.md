# Phase 1: Built to take live RFID data and display these times in a table
# Build the docker image
docker build -t my-node-app .

# Run the docker image
docker-compose up

# Run the frontend - just in React/typescript
- cd frontend
- npm start

# Info
Cors is enabled by default on the server
TODO
- connect to RFID APIs
- TODO: call POST API after each lap
