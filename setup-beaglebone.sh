#!/bin/bash

assertRoot() {
  if [ "$(id -u)" != "0" ]; then
    echo "This script must be run as root" 1>&2
    exit 1
  fi
}

promptTimezone() {
  dpkg-reconfigure tzdata
}

enableRootSSH() {
  sed -i '/PermitRootLogin prohibit-password/c\PermitRootLogin yes' /etc/ssh/sshd_config
}

installNode() {
  apt-get install build-essential libssl-dev curl git vim -y
  curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.32.0/install.sh | bash
  source ~/.bashrc
  nvm install stable
}

installPostgre() {
  sudo apt-get install postgresql postgresql-contrib -y
  # set postgres user's password to password00
  sudo -u postgres psql -c "ALTER USER \"postgres\" WITH PASSWORD 'foobar321'"
  sudo -u postgres psql -c 'CREATE DATABASE "pump-manager"'
}

setupPumpController() {
  echo "export BEAGLEBONE=true" >> ~/.bashrc
  echo "export NODE_ENV=production" >> ~/.bashrc
  # echo 'export PUMP_EMAIL_PASSWORD="email password goes here"' >> ~/.bashrc
  source ~/.bashrc
  git clone https://github.com/FullR/pump-dashboard
  cd pump-dashboard
  git checkout rewrite-sep-2016
  npm i
  cd ..

  # create start script
  echo "#!/bin/bash" > start
  echo "cd pump-dashboard" >> start
  echo "npm run start" >> start
  chmod +x start
}

assertRoot
enableRootSSH
apt-get update
promptTimezone
installNode
installPostgre
setupPumpController
