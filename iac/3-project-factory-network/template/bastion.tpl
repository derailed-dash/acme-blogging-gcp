#! /bin/bash
set -euo pipefail
export DEBIAN_FRONTEND=noninteractive
sudo apt-get update

sudo apt install -y wget

# retrieve cloud_sql_proxy
wget https://dl.google.com/cloudsql/cloud_sql_proxy.linux.amd64 -O cloud_sql_proxy
chmod +x cloud_sql_proxy

# install mariadb-client. (No cloudsql client on Debian, but this should work fine!)
apt install -y mariadb-client

# And some dev tools
apt install -y python3-venv