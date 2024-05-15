#!/bin/bash

function logo {
  curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/doubletop.sh | bash
}

function line {
  echo -e "-----------------------------------------------------------------------------"
}

function colors {
  GREEN="\e[1m\e[32m"
  RED="\e[1m\e[39m"
  NORMAL="\e[0m"
}

function output {
  echo -e "${GREEN}$1${NORMAL}"
}

function output_error {
  echo -e "${RED}$1${NORMAL}"
}

function output_normal {
  echo -e "${GREEN}$1${NORMAL}"
}

function src_oracle {
    git clone https://github.com/skip-mev/slinky $HOME/initia-oracle
    cd $HOME/initia-oracle
    git checkout v0.4.3
    make build
    mv build/slinky /usr/local/bin/
    rm -rf build
    sed -i 's/"prometheusServerAddress": "0.0.0.0:8002"/"prometheusServerAddress": "0.0.0.0:8202"/' $HOME/initia-oracle/config/core/oracle.json
    sed -i 's/"port": "8080"/"port": "8280"/' $HOME/initia-oracle/config/core/oracle.json
}

function prepare_systemd {
    sudo tee /etc/systemd/system/initia-oracle.service > /dev/null <<EOF
[Unit]
Description=Initia Slinky Oracle
After=network-online.target

[Service]
User=$USER
ExecStart=$(which slinky) --oracle-config-path $HOME/initia-oracle/config/core/oracle.json --market-map-endpoint 127.0.0.1:14090
Restart=on-failure
RestartSec=30
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF
    
    sudo systemctl daemon-reload
    sudo systemctl enable initia-oracle
    sudo systemctl restart initia-oracle
}

function main {
    colors
    line
    logo
    line
    output "Installing Oracle"
    line
    src_oracle
    prepare_systemd
    line
    output "Oracle installed"
    line
}

main