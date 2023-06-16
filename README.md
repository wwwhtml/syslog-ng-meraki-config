## Syslog-ng and Meraki URLs and Events Configuration

Installation and configuration of syslog-ng server with meraki urls and events logs on Linux Mint. 

For this example we use: 
"admin" = as the sudo user.
192.168.0.10 = as the server IP adddress, and the 514 port.
192.168.0.20 = as the Meraki Appliance IP address.

# Steps
#1. Installing syslog-ng
#2. Create a 'meraki' directory to keep all meraki logs in it
#3. Modify the syslog-ng.conf file
#4. Create the two meraki log files in /var/log/meraki/
#5. Create a bash script to rotate the events, and urls log files, if bigger than 1MB
#6. Save the rotating script in: /etc/crontab.d/
#7 Create the crontab job
#8. Useful commands

# 1. Installing syslog-ng:
sudo apt update && sudo apt install syslog-ng -y

# 2. Create a 'meraki' directory to keep all meraki logs in it:
sudo mkdir -p /var/log/meraki

# 3. Modify the syslog-ng.conf file.
sudo nano /etc/syslog-ng/syslog-ng.conf

#--------------  syslog-ng.conf starts here -----------------------------------------------------
#If you wish to get logs from remote machine you should uncomment
#this and comment the above source line. 
source s_net { udp(ip(192.168.0.10) port(514)); };

#create individual filters to match each of the role categories
filter f_meraki_urls { host( "192.168.0.20" ) and match("urls" value ("MESSAGE")); };
filter f_meraki_events { host( "192.168.0.20" ) and match("events" value ("MESSAGE")); };

#define individual destinations for each of the role categories
destination df_meraki_urls { file("/var/log/meraki/meraki_urls.log"); };
destination df_meraki_events { file("/var/log/meraki/meraki_events.log"); };

#bundle the source, filter, and destination rules together with a logging rule for each role category
log { source ( s_net ); filter( f_meraki_urls ); destination ( df_meraki_urls ); };
log { source ( s_net ); filter( f_meraki_events ); destination ( df_meraki_events ); };
#--------------  syslog-ng.conf ends here -----------------------------------------------------

# 4. Create the two meraki log files in /var/log/meraki/:
touch /var/log/meraki/meraki_urls.log
touch /var/log/meraki/meraki_events.log

# 5. Create a bash script to rotate the events, and urls log files, if bigger than 1MB
#-------- rotating log files start here ----------------
#!/bin/bash
#file: rotating-meraki-events-and-urls-log-files.sh
#Rotates meraki-urls.log and meraki-events.log files to a new name, if over filesize is 1MB.
#Author: Daniel Arauz
#2023-06-16 

#Checking Meraki EVENTS log files:
#---------------------------------
sourceFolderLocation="/var/log/meraki/"
cd $sourceFolderLocation

file="/var/log/meraki/meraki_events.log"

#Check if the file exists
if [ ! -f "$file" ]; then
  #If the file does not exist, create it
  touch "$file"
  #Set the permission to 0750
  chmod 0750 "$file"
  echo "New meraki events log File created successfully with permissions 0750"
else
  #If the file exists  
  now=$(date +"%Y%m%d_%H%M%S")
  fileNewName="meraki_events.log.$now.log"
  minimumsize=1000000
  actualsize=$(wc -c <"$file")
    if [ $actualsize -ge $minimumsize ]; then
      echo size is over $minimumsize bytes
      mv $file $fileNewName
      touch "/var/log/meraki/meraki_events.log"
      chmod 0750 "/var/log/meraki/meraki_events.log"
      else
      echo "meraki events log file size is under $minimumsize bytes"
    fi
fi

#Checking Meraki URL log files:
#------------------------------

file2="/var/log/meraki/meraki_urls.log"

#Check if the file exists
if [ ! -f "$file2" ]; then
  #If the file2 does not exist, create it
  touch "$file2"
  #Set the permission to 0750
  chmod 0750 "$file2"
  echo "New meraki-urls log file created successfully with permissions 0750"
  #Restarting syslog-ng:
  /etc/init.d/syslog-ng restart
else
  #If the file exists
  now=$(date +"%Y%m%d_%H%M%S")
  fileNewName2="meraki_urls.log.$now.log"
  minimumsize=1000000
  actualsize=$(wc -c <"$file2")
    if [ $actualsize -ge $minimumsize ]; then
      echo size is over $minimumsize bytes
      mv $file2 $fileNewName2
      touch "/var/log/meraki/meraki_urls.log"
      chmod 750 "/var/log/meraki/meraki_urls.log"
#Restarting syslog-ng:
      /etc/init.d/syslog-ng restart
      else
      echo "meraki urls log file size is under $minimumsize bytes"
    fi
fi
exit
#-------- rotating log files start here ----------------

# 6. Save the rotating script in: /etc/crontab.d/
#Then when done save it at this path: /etc/crontab.d/
#Then apply permissions: 
sudo chmod +x /etc/crontab.d/rotating-meraki-events-and-urls-log-files.sh

# 7 Create a crontab job:
#Run the command below to edit crontab:
crontab -e
#Enter the following to run the script every hour: 
0 * * * * /etc/crontab.d/rotating-meraki-events-and-urls-log-files.sh
#After crontab is saved, if you want to check the crontab listing:
sudo crontab -l

# 8. Useful commands:
#Restart syslog-ng (or restart the server):
sudo systemctl restart syslog-ng
#Syslog-ng status:
sudo systemctl status syslog-ng
#If you want to check if the meraki urls and event files are receiving log entries:
cat /var/log/meraki/meraki_urls.log
cat /var/log/meraki/meraki_events.log
#To see live entries:
tail -F /var/log/meraki/meraki_urls.log
#To see the last 50 entries en meraki_urls.org (or any file):
tail -n 50 /var/log/meraki/meraki_urls.log
#To see the whole content of the meraki-urls.org file (or any file):
cat /var/log/meraki/meraki_urls.log
#To search in a log file for a particular IP: 
cat /var/log/meraki/meraki_urls.log | grep <IP>

Hope this is useful to someone out there.

Thank you!

2023-06-16 - Source: https://www.github.com/wwwhtml/syslog-ng-meraki-config

