#!/bin/bash

promptTimezone() {
  sudo dpkg-reconfigure tzdata
}

enableRootSSH() {
  sudo sed -i '/PermitRootLogin prohibit-password/c\PermitRootLogin yes' /etc/ssh/sshd_config
}

installNode() {
  sudo apt-get install build-essential libssl-dev curl git vim -y
  curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.32.0/install.sh | bash && source ~/.bashrc
  $HOME/.nvm/nvm.sh
  nvm install stable
  source ~/.bashrc
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
  git clone https://github.com/FullR/pump-dashboard.git
  cd pump-dashboard
  git checkout rewrite-sep-2016
  npm i
  cd ..

  # create start script
  echo "#!/bin/bash" > start
  echo "node pump-dashboard/server" >> start
  chmod +x start
}

#assertRoot
enableRootSSH
sudo apt-get update
promptTimezone
installNode
installPostgre
setupPumpController
