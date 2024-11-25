export const Status = {
  UNKNOWN: 0,
  READY: 1,
  QUALIFYING: 2,
  RACE: 3,
};

export type RfidResponse = {
  data: {
    idHex: string;
  };
  timestamp: string;
};
