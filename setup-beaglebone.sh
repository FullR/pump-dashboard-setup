#!/bin/bash

promptTimezone() {
  sudo dpkg-reconfigure tzdata
}

installNode() {
  sudo apt-get update
  sudo apt-get install build-essential libssl-dev curl git -y
  curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.32.0/install.sh | bash
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
  nvm install stable
  # create symbolic links so root has access to the same versions of node and npm
  sudo ln -s "$NVM_DIR/versions/node/$(nvm version)/bin/node" "/usr/bin/node"
  sudo ln -s "$NVM_DIR/versions/node/$(nvm version)/bin/npm" "/usr/bin/npm"
}

installPostgre() {
  sudo apt-get install postgresql postgresql-contrib -y
  sudo -u postgres psql -c "ALTER USER \"postgres\" WITH PASSWORD 'foobar321'"
  sudo -u postgres psql -c 'CREATE DATABASE "pump-manager"'
}

setupPumpController() {
  export BEAGLEBONE=true
  export NODE_ENV=production
  echo "export BEAGLEBONE=true" >> ~/.bashrc
  echo "export NODE_ENV=production" >> ~/.bashrc
  # echo 'export PUMP_EMAIL_PASSWORD="email password goes here"' >> ~/.bashrc
  git clone https://github.com/FullR/pump-dashboard.git
  cd pump-dashboard
  git checkout rewrite-sep-2016
  npm i
  cd ..

  # create start script
  echo "#!/bin/bash" > start
  echo "cd pump-dashboard && sudo npm run start:beaglebone" >> start
  chmod +x start
}

sudo apt-get update
sudo apt-get install vim -y
installNode
installPostgre
setupPumpController
promptTimezone
passwd
