#!/bin/bash
sudo touch /var/swap.img
sudo chmod 600 /var/swap.img
sudo dd if=/dev/zero of=/var/swap.img bs=1024k count=2000
mkswap /var/swap.img
sudo swapon /var/swap.img
sudo echo "/var/swap.img none swap sw 0 0" >> /etc/fstab
sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt-get dist-upgrade -y
sudo apt-get install -y nano htop git build-essential libtool autotools-dev automake pkg-config libssl-dev libevent-dev bsdmainutils software-properties-common libboost-all-dev
sudo add-apt-repository -y ppa:bitcoin/bitcoin
sudo apt-get update -y
sudo apt-get install -y libdb4.8-dev libdb4.8++-dev
mkdir /root/temp
sudo git clone https://github.com/HashRentalCoin/hashrentalcoin /root/temp
chmod -R 755 /root/temp
cd /root/temp
./autogen.sh
./configure
make
make install
cd
mkdir /root/hashrentalcoincore
mkdir /root/.hashrentalcoincore
cp /root/temp/src/hashrentalcoind /root/hashrentalcoincore
cp /root/temp/src/hashrentalcoin-cli /root/hashrentalcoincore
chmod -R 755 /root/hashrentalcoincore
chmod -R 755 /root/.hashrentalcoincore
sudo apt-get install -y pwgen
GEN_PASS=$(pwgen -1 -n 20)
echo -e "rpcuser=hashrentalcoinuser\nrpcpassword=${GEN_PASS}\nrpcport=12547\nport=12548\nlisten=1\nmaxconnections=256" >> /root/.hashrentalcoincore/hashrentalcoin.conf
cd /root/hashrentalcoincore
./hashrentalcoind -daemon
sleep 10
masternodekey=$(./hashrentalcoin-cli masternode genkey)
./hashrentalcoin-cli stop
echo -e "masternode=1\nmasternodeprivkey=$masternodekey" >> /root/.hashrentalcoincore/hashrentalcoin.conf
./hashrentalcoind -daemon
cd /root/.hashrentalcoincore
sudo apt-get install -y virtualenv
git clone https://github.com/HashRentalCoin/sentinel.git
cd sentinel
virtualenv ./venv
./venv/bin/pip install -r requirements.txt
sudo echo "hashrentalcoincoin_conf=/root/.hashrentalcoincore/hashrentalcoin.conf" >> /root/.hashrentalcoincore/sentinel/sentinel.conf
sudo crontab -l >> tempcron
sudo echo "* * * * * cd /root/.hashrentalcoincore/sentinel && ./venv/bin/python bin/sentinel.py 2>&1 >> sentinel-cron.log" >> tempcron
sudo crontab tempcron
rm tempcron
echo "Masternode private key: $masternodekey"
echo "Job completed successfully" 
