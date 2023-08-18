#!/bin/bash

total_found=0
total_pen=0

score_report="/home/cyber/Desktop/ScoreReport.html"

function update-found
{
	#updates vuln found counts in score report
	total_percent=$(awk -vn=$total_found 'BEGIN{print(n*1.538461538)}')
	echo $total_percent
        sed -i "s/id=\"total_found\".*/id=\"total_found\">$total_found\/65<\/h3>/g" $score_report
        sed -i "s/id=\"total_percent\".*/id=\"total_percent\">$total_percent%<\/h3>/g" $score_report
	
	echo $total_pen
	
	if [ $total_pen == 0 ]; then
		sed -i "s/id=\"p0\"style=\"display:none\"/id=\"p0\"style=\"display:block\"/g" $score_report
	else
		sed -i "s/id=\"p0\"style=\"display:block\"/id=\"p0\"style=\"display:none\"/g" $score_report
	fi
}

function show-vuln()
{
	#allows vuln name to be seen in score report
	sed -i "s/id=\"$1\"style=\"display:none\"/id=\"$1\"style=\"display:block\"/g" $score_report
	((total_found+=$4))
	#replaces placeholder name with actual vuln name (obfuscation)
	sed -i "s/$2/$3/g" $score_report
	sudo -u skipper DISPLAY=:0.0 notify-send "Congrats!" "You Gained Points"
}

function hide-vuln()
{
	#hides vuln name from score report
	sed -i "s/id=\"$1\"style=\"display:block\"/id=\"$1\"style=\"display:none\"/g" $score_report
	((total_found-=$4))
	#replaces placeholder name (people should keep their own notes on the points they've gained)
	sed -i "s/$2/$3/g" $score_report
	sudo -u skipper DISPLAY=:0.0 notify-send "Uh Oh!" "You Lost Points"
}

function penalty()
{
	sed -i "s/id=\"$1\"style=\"display:none\"/id=\"$1\"style=\"display:block\"/g" $score_report
	((total_found-=$4))
	((total_pen+=1))
		
        #replaces placeholder name (people should keep their own notes on the points they've gained)
        sed -i "s/$2/$3/g" $score_report
        sudo -u skipper DISPLAY=:0.0 notify-send "Uh Oh!" "You Lost Points"
}

function remove-penalty()
{
	#allows vuln name to be seen in score report
        sed -i "s/id=\"$1\"style=\"display:block\"/id=\"$1\"style=\"display:none\"/g" $score_report
        ((total_found+=$4))
	((total_pen-1))
	
        #replaces placeholder name with actual vuln name (obfuscation)
        sed -i "s/$2/$3/g" $score_report
        sudo -u skipper DISPLAY=:0.0 notify-send "Congrats!" "You Gained Points"
}

function check()
{
	if ( eval $1 ); then
		if ( cat $score_report | grep "id=\"$2\"" | grep "display:none" ); then
			show-vuln "$2" "Vuln$2;" "$3" "$4"
		fi
	elif ( cat $score_report | grep "id=\"$2\"" | grep "display:block" ); then
		hide-vuln "$2" "$3" "Vuln$2;" "$4"
	fi
}

function check-pen()
{
	if ( eval $1 ); then
		if ( cat $score_report | grep "id=\"$2\"" | grep "display:none" ); then
			penalty "$2" "$2;" "$3" "$4"
		fi
	elif ( cat $score_report | grep "id=\"$2\"" | grep "display:block" ); then
		remove-penalty "$2" "$3" "$2;" "$4"
	fi
}

update-found

while true
do
	update-found

 #Forensics
	check 'cat /home/skipper/Desktop/Forensics1 | grep "i like to move it move it"' '1' 'Forensics 1 Correct +5' '5'
	check 'cat /home/skipper/Desktop/Forensics2 | grep "youareanidiot.py"' '2' 'Forensics 2 Correct +5' '5'
	check 'cat /home/skipper/Desktop/Forensics3 | grep "3861643f9374c2355e50c67ea86bd880"' '3' 'Forensics 3 Correct +5' '5'
	
	#Vulns
	!check '! cat /etc/group | grep "sudo" | grep "TK6"' '4' 'User TK6 is not an admin +1' '1'
	!check '! cat /etc/passwd | grep "dave"' '5' 'Unauthorized user dave removed +2' '2'
	!check '! cat /etc/shadow | grep TK2 | grep "\$y\$j9T\$Jz0F23Stn6RsiqChH9z1z"' '6' 'Insecure password on TK2 changed +2' '2'
	!check '! cat /etc/shadow | grep "Kali"' '7' 'Hidden user Kali removed +4' '4'
	!check 'cat /etc/group | grep "sudo" | grep "TK3"' '8' 'User TK3 is an administrator +1' '1'
	!check 'ls -al /etc/shadow | grep "\-rw-------" || ls -al /etc/shadow | grep "\-rw-------"' '9' 'Correct file permissions set on \/etc\/shadow +3' '3'
  !check 'ls -al /etc/shadow | grep "\-rw-------" || ls -al /etc/shadow | grep "\-rw-------"' '9' 'Correct file permissions set on \/etc\/shadow +3' '3'
  !check 'ls -al /etc/shadow | grep "\-rw-------" || ls -al /etc/shadow | grep "\-rw-------"' '9' 'Correct file permissions set on \/etc\/shadow +3' '3'
  !check 'ls -al /etc/shadow | grep "\-rw-------" || ls -al /etc/shadow | grep "\-rw-------"' '9' 'Correct file permissions set on \/etc\/shadow +3' '3'
 
	#!!!!!!check 'ls -al /var/tmp | grep "drwxrwxrwx"' '10' 'Stickybit set on \/var\/tmp\/ +3' '3'
	!check 'cat /etc/sysctl.conf | grep ^"net.ipv4.conf.all.log_martians" | grep "1"' '12' 'Logging martian packets enabled +3' '3'
	!check 'cat /etc/sysctl.conf | grep ^"kernel.randomize_va_space" | grep "1"' '13' 'ASLR is enabled +3' '3'
	!check 'cat /etc/login.defs | grep "PASS_MAX_DAYS" | grep "90"' '14' 'Max password days set to 90 +1' '1'
	!check 'cat /etc/security/pwquality.conf | grep "minlen" | grep "16"' '15' 'Password minimum legnth set to 16 +2' '2'
	#!!!!!!!check '! ls -al /var/www/ | grep "\.\.\." | grep "\->"' '16' 'Symbolic link to \/ directory in \/var\/www\/ removed +4' '4'
	!check 'cat /etc/apache2/conf-available/security.conf | grep "FileEtag" | grep -iF "none"' '17' 'ETag headers are disabled +3' '3'
	!check '! mysql -u root -e "use db; show tables;" | grep "password"' '18' 'MySql database containing password removed +2' '2'
	#!!!!!!!check 'cat /etc/mysql/mysql.conf.d/mysqld.cnf | grep "local-infile" | grep "0"' '19' 'Local infile set to 0 +4' '4'
	!check 'ufw status | grep " active"' '20' 'UFW is enabled +1' '1'
	!check 'cat /home/cyber/snap/firefox/common/.mozilla/firefox/h8bdcys2.default/prefs.js | grep "https_only_mode\"" | grep "true"' '21' 'HTTPS only mode is enabled +3' '3'
	
	
	#penalties
	check-pen '! netstat -tulpn | grep apache2 | cut -d " " -f15 | grep ":80"$' 'p1' 'Apache2 is Disabled or Running on Wrong Port -10' '10'
	check-pen '! netstat -tulpn | grep mysql | cut -d " " -f16 | grep ":3306"$' 'p2' 'MySQL is Disabled or Running on Wrong Port -10' '10'
	check-pen '! cat /etc/passwd | grep "TK1"' 'p6' 'User TK1 was Removed -3' '3'
	check-pen '! cat /etc/passwd | grep "TK2"' 'p7' 'User TK2 was Removed -3' '3'
	check-pen '! cat /etc/passwd | grep "TK3"' 'p8' 'User TK3 was Removed -3' '3'
	check-pen '! cat /etc/passwd | grep "TK4"' 'p9' 'User TK4 was Removed -3' '3'
	check-pen '! cat /etc/passwd | grep "TK5"' 'p10' 'User TK5 was Removed -3' '3'
	check-pen '! cat /etc/passwd | grep "TK6"' 'p11' 'User TK6 was Removed -3' '3'
	
	
	#wait 10 seconds
	sleep 10
done





