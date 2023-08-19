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
	sudo -u cyber DISPLAY=:0.0 notify-send "Congrats!" "You Gained Points"
}

function hide-vuln()
{
	#hides vuln name from score report
	sed -i "s/id=\"$1\"style=\"display:block\"/id=\"$1\"style=\"display:none\"/g" $score_report
	((total_found-=$4))
	#replaces placeholder name (people should keep their own notes on the points they've gained)
	sed -i "s/$2/$3/g" $score_report
	sudo -u cyber DISPLAY=:0.0 notify-send "Uh Oh!" "You Lost Points"
}

function penalty()
{
	sed -i "s/id=\"$1\"style=\"display:none\"/id=\"$1\"style=\"display:block\"/g" $score_report
	((total_found-=$4))
	((total_pen+=1))
		
        #replaces placeholder name (people should keep their own notes on the points they've gained)
        sed -i "s/$2/$3/g" $score_report
        sudo -u cyber DISPLAY=:0.0 notify-send "Uh Oh!" "You Lost Points"
}

function remove-penalty()
{
	#allows vuln name to be seen in score report
        sed -i "s/id=\"$1\"style=\"display:block\"/id=\"$1\"style=\"display:none\"/g" $score_report
        ((total_found+=$4))
	((total_pen-1))
	
        #replaces placeholder name with actual vuln name (obfuscation)
        sed -i "s/$2/$3/g" $score_report
        sudo -u cyber DISPLAY=:0.0 notify-send "Congrats!" "You Gained Points"
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
	#check 'cat /home/cyber/Desktop/Forensics1 | grep "i like to move it move it"' '1' 'Forensics 1 Correct +5' '5'
	#check 'cat /home/cyber/Desktop/Forensics2 | grep "youareanidiot.py"' '2' 'Forensics 2 Correct +5' '5'
	#check 'cat /home/cyber/Desktop/Forensics3 | grep "3861643f9374c2355e50c67ea86bd880"' '3' 'Forensics 3 Correct +5' '5'
	
	#Vulns
	check '! cat /etc/group | grep "sudo" | grep "Hannah"' '4' 'User Hannah is not an admin +1' '1'
	check '! cat /etc/passwd | grep "dave"' '5' 'Unauthorized user dave removed +2' '2'
 	check 'cat /etc/group | grep "dev"' '8' 'User dev created +1' '1'
	check '! cat /etc/shadow | grep Kyle | grep "!"' '6' 'User dev has a password' +2' '2'
	check '! cat /etc/shadow | grep "Kali"' '7' 'Hidden user Kali removed +4' '4'
	check 'cat /etc/group | grep "sudo" | grep "Derrick"' '8' 'User Derrick is an administrator +1' '1'
	check 'cat /etc/group | grep "Exploiters" | grep "Derrick"' '9' 'Users added to group Exploiters +1' '1'
 	check 'cat /etc/group | grep "New_Hires" | grep "Daniel"' '9' 'Users added to group New_Hires +1' '1'
 
	check 'ls -al /etc/shadow | grep "\-rw-------" || ls -al /etc/shadow | grep "\-rw-------"' '9' 'Correct file permissions set on \/etc\/shadow +3' '3'
  	check 'ls -ald /var/tmp | grep "\drwxrwxrwt" || ls -ald /var/tmp | grep "\drwxrwxrwt"' '10' 'Stickybit set on \/var\/tmp +3' '3'
  	check '! ls -al /usr/bin/cp | grep "\-rwsr-xr-x"' '11' 'Removed SUID on \/bin\/usr\/cp +5' '5'
  	#check 'ls -al /etc/shadow | grep "\-rw-------" || ls -al /etc/shadow | grep "\-rw-------"' '12' 'Correct file permissions set on \/etc\/shadow +3' '3'
 

	check 'cat /etc/sysctl.conf | grep ^"net.ipv4.conf.all.log_martians" | grep "1"' '14' 'Logging martian packets enabled +3' '3'
	check 'cat /etc/sysctl.conf | grep ^"kernel.randomize_va_space" | grep "1"' '15' 'ASLR is enabled +3' '3'
	check 'cat /etc/login.defs | grep "PASS_MAX_DAYS" | grep "90"' '16' 'Max password days set to 90 +1' '1'
	check 'cat /etc/security/pwquality.conf | grep "minlen" | grep "16"' '17' 'Password minimum legnth set to 16 +2' '2'
	check 'cat /etc/pam.d/common-auth | grep "deny=5"' '18' 'Correct PAM authentication configuration +2' '2'
 	#!!!!!!!check '! ls -al /var/www/ | grep "\.\.\." | grep "\->"' '18' 'Symbolic link to \/ directory in \/var\/www\/ removed +4' '4'
	check 'cat /etc/apache2/conf-available/security.conf | grep "FileEtag" | grep -iF "none"' '19' 'ETag headers are disabled +3' '3'
	check '! mysql -u root -e "use db; show tables;" | grep "password"' '20' 'MySql database containing password removed +2' '2'
	#!!!!!!!check 'cat /etc/mysql/mysql.conf.d/mysqld.cnf | grep "local-infile" | grep "0"' '21' 'Local infile set to 0 +4' '4'
	check 'ufw status | grep " active"' '22' 'UFW is enabled +1' '1'
 	check 'ufw status verbose | grep "high"' '22' 'UFW logging set to high +1' '1'
	check 'cat /home/cyber/snap/firefox/common/.mozilla/firefox/h8bdcys2.default/prefs.js | grep "https_only_mode\"" | grep "true"' '23' 'HTTPS only mode is enabled +3' '3'
	check '! cat /var/spool/cron/crontabs/root | grep "payload.elf" '25' 'Removed malicious cronjob +3' '3'
	
	#penalties
	check-pen '! netstat -tulpn | grep apache2 | cut -d " " -f15 | grep ":443"$' 'p1' 'Apache2 is Disabled or Running on Wrong Port -10' '10'
	check-pen '! netstat -tulpn | grep mysql | cut -d " " -f16' 'p2' 'MySQL is Disabled -10' '10'
	check-pen '! cat /etc/passwd | grep "cyber"' 'p3' 'User cyber was Removed -3' '3'
	check-pen '! cat /etc/passwd | grep "Kyle"' 'p4' 'User Kyle was Removed -3' '3'
	check-pen '! cat /etc/passwd | grep "Derrick"' 'p5' 'User Derrick was Removed -3' '3'
	check-pen '! cat /etc/passwd | grep "Paula"' 'p6' 'User Paula was Removed -3' '3'
	check-pen '! cat /etc/passwd | grep "Hannah"' 'p7' 'User Hannah was Removed -3' '3'
	check-pen '! cat /etc/passwd | grep "Daniel"' 'p8' 'User Daniel was Removed -3' '3'
	
	
	#wait 10 seconds
	sleep 10
done






