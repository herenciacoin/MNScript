#!/bin/bash

#stop_daemon function
function stop_daemon {
    if pgrep -x 'herenciad' > /dev/null; then
        echo -e "${YELLOW}Attempting to stop herenciad${NC}"
        herencia-cli stop
        sleep 30
        if pgrep -x 'herenciad' > /dev/null; then
            echo -e "${RED}herenciad daemon is still running!${NC} \a"
            echo -e "${RED}Attempting to kill...${NC}"
            sudo pkill -9 herenciad
            sleep 30
            if pgrep -x 'herenciad' > /dev/null; then
                echo -e "${RED}Can't stop herenciad! Reboot and try again...${NC} \a"
                exit 2
            fi
        fi
    fi
}


echo "Your HERENCIA Masternode Will be Updated To The Latest Version v1.1.0 Now" 
sudo apt-get -y install unzip

#remove crontab entry to prevent daemon from starting
crontab -l | grep -v 'herenciaauto.sh' | crontab -

#Stop herenciad by calling the stop_daemon function
stop_daemon

rm -rf /usr/local/bin/herencia*
mkdir HEIRS_1.1.0
cd HEIRS_1.1.0
wget https://github.com/herenciacoin/HEIRS/releases/download/v1.1.0/HEIRS-1.1.0-ubuntu-daemon.tar.gz
tar -xzvf HEIRS-1.1.0-ubuntu-daemon.tar.gz
mv herenciad /usr/local/bin/herenciad
mv herencia-cli /usr/local/bin/herencia-cli
chmod +x /usr/local/bin/herencia*
rm -rf ~/.herencia/blocks
rm -rf ~/.herencia/chainstate
rm -rf ~/.herencia/sporks
rm -rf ~/.herencia/evodb
rm -rf ~/.herencia/zerocoin
rm -rf ~/.herencia/peers.dat
cd ~/.herencia/
wget https://github.com/herenciacoin/HEIRS/releases/download/v1.1.0/bootstrap.zip
unzip bootstrap.zip

cd ..
rm -rf ~/.herencia/bootstrap.zip ~/HEIRS_1.1.0

# add new nodes to config file
sed -i '/addnode/d' ~/.herencia/herencia.conf

echo "addnode=155.138.133.74
addnode=155.138.149.55
addnode=155.138.143.166
addnode=155.138.157.121
addnode=155.138.150.227" >> ~/.herencia/herencia.conf

#start herenciad
herenciad -daemon

printf '#!/bin/bash\nif [ ! -f "~/.herencia/herencia.pid" ]; then /usr/local/bin/herenciad -daemon ; fi' > /root/herenciaauto.sh
chmod -R 755 /root/herenciaauto.sh
#Setting auto start cron job for HERENCIA
if ! crontab -l | grep "herenciaauto.sh"; then
    (crontab -l ; echo "*/5 * * * * /root/herenciaauto.sh")| crontab -
fi

echo "Masternode Updated!"
echo "Please wait a few minutes and start your Masternode again on your Local Wallet"