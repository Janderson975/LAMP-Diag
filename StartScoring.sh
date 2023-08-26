#! /bin/bash

#sudo apt install git
#sudo apt install shc
#sudo apt install gcc
git clone -b cloning https://github.com/Janderson975/LAMP-Diag.git
sleep 20
chmod +x LAMP-Diag/scorebot.sh
mv LAMP-Diag/scorebot.sh /var/.score/scorebot.sh
mv LAMP-Diag/ScoreReport.html /home/cyber/Desktop/ScoreReport.html
mv LAMP-Diag/README.html /home/cyber/Desktop/README.html
chown cyber:cyber /home/cyber/Desktop/ScoreReport.html
chown cyber:cyber /home/cyber/Desktop/README.html
shc -f /var/.score/scorebot.sh
rm /var/.score/scorebot.sh
rm -rf LAMP-Diag
sudo /var/.score/scorebot.sh.x
