#! /bin/bash

sleep 10


mv /var/.score/ScoreReport.html /home/cyber/Desktop/ScoreReport.html
mv /var/.score/README.html /home/cyber/Desktop/README.html
chown cyber:cyber /home/cyber/Desktop/ScoreReport.html
chown cyber:cyber /home/cyber/Desktop/README.html
shc -f /var/local/scorebot.sh
rm /var/local/scorebot.sh
sudo /var/local/scorebot.sh.x
