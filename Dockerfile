FROM node:16

WORKDIR /usr/src/app

COPY package*.json ./
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y nodejs \
    npm

COPY . .
EXPOSE 1337
CMD ["npm", "run", "dev"]