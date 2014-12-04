#!/bin/bash

# clear output
clear

# defined colours
yellow='\033[1;33m'
green='\033[0;32m'
red='\033[0;31m'

if [[ $EUID -ne 0 ]]; then
   echo -e "${red}This script must be run as root"

   # reset colours
	tput sgr0

   exit
fi

echo "Add New Virtual Host"

# ask for the url
while [ -z $url ]
do
echo -e "${yellow}enter url:"

# reset colours
tput sgr0

read url
done

# ask for the document root
while [ -z $doc_root ]
do
echo -e "${yellow}enter document root (relative to /Applications/MAMP/htdocs/):"

# reset colours
tput sgr0

read doc_root
done

log_file="/Applications/MAMP/logs/$doc_root.log"
doc_root="/Applications/MAMP/htdocs/$doc_root"

# check the document root exists
if [ -d $doc_root ]
then
	echo -e "${green}#######################"
	echo -e "${green}## New Virtual Host Created"
	echo -e "${green}## url: http://$url" 
	echo -e "${green}## document root: $doc_root"
	echo -e "${green}## log file: $log_file"
	echo -e "${green}#######################"
else
	echo -e "${red}$doc_root does not exist"

	# reset colours
	tput sgr0

	exit
fi

# create the vhost in vhost.conf
echo "" >> vhost_conf
echo "<VirtualHost *>" >> /Applications/MAMP/conf/apache/vhosts.conf
echo "ServerName $url" >> /Applications/MAMP/conf/apache/vhosts.conf
echo "DocumentRoot $doc_root" >> /Applications/MAMP/conf/apache/vhosts.conf
echo "ErrorLog $log_file" >> /Applications/MAMP/conf/apache/vhosts.conf
echo "</VirtualHost>" >> /Applications/MAMP/conf/apache/vhosts.conf

# add the vhost to /etc/host
echo "127.0.0.1 $url" >> /etc/hosts

# restart apache
sudo /Applications/MAMP/bin/apache2/bin/apachectl restart

# flush the dns
dscacheutil -flushcache

# reset colours
tput sgr0

# open the url in the browser
open "http://$url"