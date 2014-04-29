#! /bin/bash 
# 
# =======================
# Siteup Script 0.1
# Written by Command Line Idiot
# http://commandlineidiot.com
# You may use, modify, and redistribute this script freely
# Released: August 2007
# =======================

# =======================
#	set functions
# =======================
#	make_index is the function to create a basic index.html file
# 	within the documents directory of the new domain. The variable
# 	for domain name is passed into the file at $dname. You can alter
#	any of the code between the terms _EOF_ and it will be reflected
#	in the index.html file.
USER=rik
SITEROOT=/home/rik/sites

function make_index
{
cat <<- _EOF_
	<html>
	<head><title>$dname</title></head>
	<body>welcome to $dname</body> 
	</html>
_EOF_
} 

#	make_vhost is the function to create a config file that
#	Apache2 can interpret. The variable for the domain name is passed
#	into the file at $dname, and the system-wide variable for username
#	is passed into the file at $USER. You may wish to replace the
#	ServerAdmin email address with your own email address. You may alter
#	any of the code between the terms _EOF_ to build your own preferred 
#	standard config file.  

function make_vhost
{
cat <<- _EOF_
	<VirtualHost *:80>
			DocumentRoot "/home/rik/sites/$dname/public_html/web"
	        ServerAdmin $USER@localhost
	        ServerName $dname.dev

	       <Directory "/home/rik/sites/$dname/public_html/web">
		        SetEnv APPLICATION_ENV development
		        AllowOverride All
	       </Directory>

	        ErrorLog /home/rik/sites/$dname/logs/error.log
	        CustomLog /home/rik/sites/$dname/logs/access.log common
	</VirtualHost>
_EOF_
}

# =======================
#	     header
# =======================
clear  
echo "***      Site Setup      ***"
 
# =======================
# set domain name variable
# =======================
echo -n "==> Enter new domain name (domain.com): "
read dname
echo "Setting up files for $dname"

# =======================
# create needed directories
# =======================
mkdir -vp /home/rik/sites/$dname/public_html
mkdir -vp /home/rik/sites/$dname/conf
#mkdir -vp /home/rik/sites/$dname/cgi-bin
mkdir -vp /home/rik/sites/$dname/logs
touch /home/rik/sites/$dname/logs/access.log 
echo "created /home/rik/sites/$dname/logs/access.log "
touch /home/rik/sites/$dname/logs/error.log 
echo "created /home/rik/sites/$dname/logs/error.log"

echo "Correcting rights"
chown -R rik:users /home/rik/sites/$dname
chmod -R o+x /home/rik/sites/$dname


# =======================
# build vhost config file
# =======================
make_vhost > /home/rik/sites/$dname/conf/$dname.conf

#arch linux config
ln -Fs /home/rik/sites/$dname/conf/$dname.conf /etc/httpd/conf/sites-available/$dname.conf

#ln -Fs /home/rik/sites/$dname/conf/$dname.conf /etc/apache2/sites-enabled/$dname.conf
echo 'linked config into /etc/apache2/sites-available'

echo 'Enabling site'
a2ensite $dname.conf

add-to-hosts.sh add $dname.dev

httpd -k restart 


# =======================
#    exit
# =======================

echo "***      Finished setting up files for $dname. Goodbye!"
echo "***               (do not forget your hosts file) "
exit
