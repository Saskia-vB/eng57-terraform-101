#!/bin/bash

cd /home/ubuntu/web-app
export DB_HOST=${db_host}
. ~/.bashrc
node seeds/seed.js
forever stopall
npm install
forever start app.js
