# TODO: Compile the ts rather than running it with tsx

FROM node:16

WORKDIR /usr/src/app

COPY package*.json ./
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y nodejs && \
    npm install && \
    npm install tsx -g 
COPY . .
EXPOSE 1337
CMD ["npm", "run", "dev"]