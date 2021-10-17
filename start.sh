#!/bin/bash

# Installing modules dependencies
echo Module intallation has been initiated
npm install

echo Install pm2 globally
npm i -g pm2

echo Start node server
pm2 start app.js --name server
