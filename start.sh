#!/bin/bash


# Installing modules dependencies
echo Installing sequelize-cli globally 
sudo npm install -g sequelize-cli

echo Module intallation has been initiated
sudo npm install

echo Install pm2 globally
sudo npm i -g pm2

echo Start node server using pm2
sudo pm2 start app.js --name server
