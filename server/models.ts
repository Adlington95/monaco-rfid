export const Status = {
  READY: 1,
  USER_SCANNED: 2,
  CAR_SCANNED: 3,
  PRACTICE: 4,
  QUALIFYING: 5,
  QUALIFYING_COMPLETE: 6,
  UNKNOWN: 0,
};

export type RfidResponse = {
  data: {
    idHex: string;
  };
  timestamp: string;
};
