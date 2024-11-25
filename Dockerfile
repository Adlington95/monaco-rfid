FROM node:16

WORKDIR /usr/src/app

COPY package*.json ./
COPY tsconfig.json ./
COPY server ./server
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y nodejs && \
    npm install && \
    npm run build
EXPOSE 1337
CMD ["npm", "run", "prod"]