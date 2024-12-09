// Defaults for the application

// Server connection
const defaultServerUrl = '169.254.39.254';
const defaultRFIDReaderUrl = '169.254.39.234';
const defaultRestPort = '13000';
const defaultWebsocketPort = '18080';

/// Circuit
const defaultCircuitName = 'Monaco';
const defaultCircuitLength = 11.68; // In metres

// Game play
const defaultPracticeLaps = 3;
const defaultQualifyingLaps = 10;
const defaultRaceLaps = 7;

const defaultEventName = '2025 Monaco Grand Prix';
const defaultRaceLights = 4;
const defaultScannedThingName = 'badge';
const defaultRaceMode = 'QUALIFYING';
const defaultMinLapTime = 3; // In seconds

/// How long to show the finish screen
const defaultFinishPageDuration = 60000; // In milliseconds

// Key for the shared preferences / JSON file
const serverUrlKey = 'serverUrl';
const restPortKey = 'restPort';
const websocketPortKey = 'websocketPort';
const circuitNameKey = 'circuitName';
const circuitLengthKey = 'circuitLength';
const practiceLapsKey = 'practiceLaps';
const qualifyingLapsKey = 'qualifyingLaps';
const finishPageDurationKey = 'finishPageDuration';
const eventNameKey = 'eventName';
const raceLapsKey = 'raceLaps';
const raceLightsKey = 'raceLights';
const scannedThingNameKey = 'scannedThingName';
const rfidReaderUrlKey = 'rfidReaderUrl';
const raceModeKey = 'raceMode';
const backgroundImageKey = 'backgroundImage';
const minLapTimeKey = 'minLapTime';
