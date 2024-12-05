export enum Status {
  UNKNOWN,
  ERROR,
  QUALIFYING,
  RACE,
}

export type RfidResponse = {
  data: {
    idHex: string;
  };
  timestamp: string;
};

export type User = {
  id: string;
  name: string;
};
