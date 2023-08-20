#! /bin/bash

sleep 10
sudo apt install git
sudo apt install shc
sudo apt install gcc
git clone -b cloning https://github.com/Janderson975/LAMP-Diag.git
chmod +x LAMP-Diag/scorebot.sh
mv LAMP-Diag/scorebot.sh /var/local/scorebot.sh
mv LAMP-Diag/ScoreReport.html /home/cyber/Desktop/ScoreReport.html
mv LAMP-Diag/README.html /home/cyber/Desktop/README.html
chown cyber:cyber /home/cyber/Desktop/ScoreReport.html
chown cyber:cyber /home/cyber/Desktop/README.html
shc -f /var/local/scorebot.sh
rm /var/local/scorebot.sh
sudo /var/local/scorebot.sh.x
