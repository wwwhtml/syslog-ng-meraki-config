#!/bin/bash
#file: rotating-meraki-events-and-urls-log-files.sh
#Rotates meraki-urls.log and meraki-events.log files to a new name, if over filesize is 1MB.
#Author: Daniel Arauz
#2023-06-16 
# Of course, feel free to adjust to fit your needs, if you want.

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
