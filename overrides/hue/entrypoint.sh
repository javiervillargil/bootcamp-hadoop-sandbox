#!/bin/bash

apt-get -y update
apt-get -y upgrade
curl -sL https://deb.nodesource.com/setup_14.x | bash -
apt-get -y install vim mysql-client

./build/env/bin/hue migrate
./build/env/bin/supervisor
