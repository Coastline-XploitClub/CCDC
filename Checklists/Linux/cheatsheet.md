===============================================================================
# VSFTP

```
chroot_local_user=YES
local_root=/ftphome/$USER
user_sub_token=$USER


mkdir -p /ftphome/{test,user1,user2}
chmod 770 -R /ftphome
chown -R ftp. /ftphome
usermod -G ftp test

ln -s /home/user /ftphome
```

===============================================================================
# SFTP
```
Match Group sftponly
  ChrootDirectory %h
  ForceCommand internal-sftp
  AllowTcpForwarding no
  X11Forwarding no

sudo mount --bind /home/sammy /home/sftp/sammy
sudo nano /etc/fstab
then add:
/home/sammy /home/sftp/sammy/sammy/ none bind 00
sudo mount -a  #to mount all in /etc/fstab and test
sudo umount /home/sftp/sammy
```

===============================================================================
# Docker
```
pulling image:
docker pull nginx
docker pull ubuntu:latest
docker pull ubuntu:22.04


docker image			# manage
Docker Image ls
docker image rm ubuntu:22.04
docker rm ubuntu		#  remove the runing or stopped contontainers
docker rm -f $(docker ps -aq)	#  remove all |stopped containers|

docker run [OPTIONS] IMAGE_NAME [COMMAND] [ARGUMENTS...]
docker run -it helloworld /bin/bash # run the image and directly intract with it
docker run -d helloworld 	# run the image in the background
docker run --name helloworld
docker run --rm helloworld
docker run -p 80:80 webserver


docker ps			# list running containers, see the container id
docker ps -a       # list all


docker build -t webserver .
docker run -d --name webserver -p 80:80  webserver

https://docs.docker.com/compose/reference/
https://docs.docker.com/compose/compose-file/

sudo usermod -aG docker $USER	# add user to docker group
```

===============================================================================
# MYSQL
```
sudo apt install mysql-server

select * from table where id=2;

------------------------------------------------------------------
Basics:

CREATE TABLE		# create a table
create table users (username TEXT, password TEXT, id INT);

# add a new row (entry) into the users table (for the password and email columns): 
INSERT INTO users (password, email) VALUES ("mypassword", "admin@example.com");
INSERT INTO users VALUES ("user1", "userpass", 1);	# make sure to insert in the proper order

SELECT * FROM <table>;
select * from <table> where id=2;

# return the rows where the email and password match to what we specify in the query:
SELECT * FROM users WHERE password="mypassword" AND email="admin@example.com";

# set or change a value for and existing entry:
UPDATE users SET password="newpassword" WHERE email="admin@example.com"

# delete the row for the match
DELETE FROM users WHERE email="admin@example.com"

UNION			# combile two queries in one command (normally, we can't have
			# two SELECT in one command)
SELECT ... Tracy Gill" UNION SELECT Profession, Password FROM users;"

LIKE			# used together with WHERE to conduct a pattern search
%			# used in LIKE query to match 0, 1, or more characters
SELECT username FROM users WHERE username LIKE "user%";

DROP TABLE		# delete a table
LIMIT			# specify a maximum number of results to return
AND			# condition on both side should be true
OR			# condition on one side should be true
_			# used in LIKE query to match a single character

------------------------------------------------------------------
wordpress configs:

 mysql_secure_installation

CREATE DATABASE example_database;
CREATE USER 'example_user'@'%' IDENTIFIED WITH mysql_native_password BY 'password';
GRANT ALL ON example_database.* TO 'example_user'@'%';
mysql -u example_user -p

CREATE TABLE example_database.todo_list (
	item_id INT AUTO_INCREMENT,
	content VARCHAR(255),
	PRIMARY KEY(item_id)
);

INSERT INTO example_database.todo_list (content) VALUES ("My first important item");

ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'new_password';       # changing the user pass


CREATE DATABASE wordpress DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci;

FLUSH PRIVILEGES;        # current instance of MySQL knows about the recent changes we’ve made

------------------------------------------------------------------


```

===============================================================================
# PHP
```
sudo apt install php libapache2-mod-php php-mysql
sudo apt install php-curl php-gd php-mbstring php-xml php-xmlrpc php-soap php-intl php-zip

connect to database:

<?php
$user = "example_user";
$password = "password";
$database = "example_database";
$table = "todo_list";

try {
  $db = new PDO("mysql:host=localhost;dbname=$database", $user, $password);
  echo "<h2>TODO</h2><ol>"; 
  foreach($db->query("SELECT content FROM $table") as $row) {
    echo "<li>" . $row['content'] . "</li>";
  }
  echo "</ol>";
} catch (PDOException $e) {
    print "Error!: " . $e->getMessage() . "<br/>";
    die();
}
```

===============================================================================
# Apache
```
sudo apt install apache2


virtual host in apache:
sudo mkdir /var/www/your_domain
sudo chown -R $USER:$USER /var/www/your_domain

sudo nano /etc/apache2/sites-available/your_domain.conf
<VirtualHost *:80>
    ServerName your_domain
    ServerAlias www.your_domain 
    ServerAdmin webmaster@localhost
    DocumentRoot /var/www/your_domain
    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>

sudo a2ensite your_domain	# enable virtual host
sudo a2dissite 000-default	# disable the default VH
sudo systemctl reload apache2

nano /var/www/your_domain/index.html
<html>
  <head>
    <title>your_domain website</title>
  </head>
  <body>
    <h1>Hello World!</h1>

    <p>This is the landing page of <strong>your_domain</strong>.</p>
  </body>
</html>

sudo nano /etc/apache2/mods-enabled/dir.conf	# change the default donfigauration to perfer the index.php over index.html

<IfModule mod_dir.c>
        DirectoryIndex index.php index.html index.cgi index.pl index.xhtml index.htm
</IfModule>


nano /var/www/your_domain/info.php
<?php
phpinfo();
```


===============================================================================
# Linux Basics
```
------------------------------------------------------------------
w or who	# logged in users
uname -a
hostname -f
dnsdomainname
hostnamectl

in /etc/hosts type below for FQDN and dns domain setup
		ip	ubuntu.domain.com ubunut
		ip	[[same as above]]

------------------------------------------------------------------
wc -l file.txt

------------------------------------------------------------------
top
	s       # delay or update time
	m       # change the info in the screen

------------------------------------------------------------------
kill
SIGTERM - Kill the process, but allow it to do some cleanup tasks beforehand
SIGKILL - Kill the process - doesn't do any cleanup after the fact
SIGSTOP - Stop/suspend a process

------------------------------------------------------------------
awk -F':' -v 'min=1000' '$3 >= min && $1 != "nobody" {print $1}'
awk '{sums[$1]+=$4} END {for (ip in sums) print sums[ip], ip}' merged.log  | sort -n
awk '{s+=$1} END {printf "%.0f\n", s}'				# sum in a command 
awk '{sum+=$1} END {print sum}' ftpdownload.txt
echo "Total: $(awk '{sum+=$1} END {print sum}' ftpuser.txt)"	# sum (+) numbers in the file and print the total
awk '{ print $6 }'
awk '{print $1, $6}'

------------------------------------------------------------------
log parsing

sort				# alphabetic sort
sort -n				# numerical sort
sort -rn			# sort from large to small
uinq				# remove duplicates and list unique values
uniq -c				# count the number of unique values
wc -l				# count lines
grep "\"200 "			# list lines that contain "200 
grep -i				# case insensitive (uppercase, lowercase doesn't matter)
grep -E				# anything in a formula (use regexr.com to test), we can find formula for any value like IP and search for it
grep -A 10 -B 10 text		# -A: number of lines befor text, -B: number of lines after text
grep -C 10			# list 10 line after and before
grep -v				# Selects the non-matching lines of the provided

cat file.txt | grep -E "\/2[0-9][0-9] "		# list all lines that contain /2[any number][any number] (lines that numbers from /200 to /299)

awk '{print $6}'
awk '{print $1, $6}'
cut -d " " -f 1
cat access.log | cut -d '"' -f3 | cut -d ' ' -f2 | sort | uniq -c | sort -rn


------------------------------------------------------------------
&	This operator allows you to run commands in the background of your terminal.
&&	This operator allows you to combine multiple commands together in one line of your terminal.
>	take the output from a command (such as using cat to output a file) and direct it elsewhere. Overwrite.
>>	Appends the output rather than replacing (meaning nothing is overwritten).

------------------------------------------------------------------
cron

crontab -e
0 */12 * * * cp -R /home/cmnatic/Documents /var/backups/
|Min Hour Day Month Year [[command]]|
MIN	What minute to execute at
HOUR	What hour to execute at
DOM	What day of the month to execute at
MON	What month of the year to execute at
DOW	What day of the week to execute at

------------------------------------------------------------------
apt

add-apt-repository
wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | sudo apt-key add -
create a file named sublime-text.list in /etc/apt/sources.list.d
add & save the Sublime Text 3 repository

add-apt-repository --remove ppa:PPA_Name/ppa	# PPA is the personal package archive - the software repository which software and its data saved there for distribution purpose of the app.
apt remove

------------------------------------------------------------------
apps

app list + version:
dpkg -l | grep rsyslog

dnf, yum       # RedHat or Fedora

list apps:

Aptitude-based distributions (Ubuntu, Debian, etc): dpkg -l
RPM-based distributions (Fedora, RHEL, etc): rpm -qa
pkg*-based distributions (OpenBSD, FreeBSD, etc): pkg_info
Portage-based distributions (Gentoo, etc): equery list or eix -I
pacman-based distributions (Arch Linux, etc): pacman -Q
Cygwin: cygcheck --check-setup --dump-only *
Slackware: slapt-get --installed


------------------------------------------------------------------
iptables

it is a way to interact with netfilter

---
sudo iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

-A INPUT: Append to the INPUT Chain
-m conntrack: Call an iptable module. In this case we're calling conntrack which keeps track of connections. This option permits the use of the following option
--ctstate ESTABLISHED,RELATED: Available due to the previous flag/option set. Will keep track of connections which are already ESTABLISHED and RELATED. RELATED just means that it's new but part of another already established connection
-j ACCEPT: The j stands for jump (I don't know why). This option will just ACCEPT the packet and stop processing other rules

---
sudo iptables -A INPUT -p tcp --dport ssh -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 21 -j ACCEPT
sudo iptables -A INPUT -p udp --dport 4380 -j ACCEPT

---
implicit deny:
sudo iptables -A INPUT -j DROP 

---
save configs:
sudo iptables-save

---
set to restore from backup after 5 minutes if you are unsure of effect of iptables changes
echo "mv /etc/sysconfig/iptables.bak /etc/sysconfig/iptables && service iptables restart" | at now + 5min
----------
Uncomplicated Firewall, UFW, https://help.ubuntu.com/community/UFW

sudo ufw <allow/deny> <port>/<optional: protocol>
sudo ufw <allow/deny> <service name>

sudo ufw allow 9000/tcp
sudo ufw deny 23
sudo ufw allow ssh


------------------------------------------------------------------
sudo:

sudo -s		# Gives you a root shell using the current user password. The user home directory doesn't change.
su -		# Switch the user as root and requires the root password. Home directory change. 


sudo gpasswd -a username sudo
usermod -aG sudo admin2		# adding admin2 to sudo group (all members have sudo privileges)
sudo usermod -aG wheel username	#CentOS
gpasswd -d user group		# removing user from the group
visudo				#  /etc/sudoers test editor
sudo visudo -f /etc/sudoers.d/file_to_edit
Names beginning with a % indicate group names

root ALL=(ALL:ALL) ALL        #  root host=(user:group) command
%sudo ALL=(ALL:ALL) ALL NOPASSWD: ALL       # sudoer
GROUPONE	ALL = NOPASSWD: /usr/bin/updatedb
GROUPTWO	ALL = NOPASSWD: /usr/bin/updatedb, PASSWD: /bin/kill
username	ALL = NOEXEC: /usr/bin/less

User_Alias		GROUPONE = abby, brent, carl
Cmnd_Alias		ALLOWCMD = /sbin/shutdown, /sbin/halt, /sbin/reboot, /sbin/restart, /usr/bin/systemctl restart *
Runas_Alias		WEB = www-data, apache

GROUPONE	ALL = (WEB) ALLOWCMD       # GROUPONE users in all hosts can run the ALLOWCMD commands as WEB users
!/usr/bin/sudo -s       # Users are not allowed to execute sudo -s.

sudo -u run_as_user command
sudo -g run_as_group command
sudo -k        #  clear the timer
sudo -v        #  renew lease / add time
sudo -l

----------
/etc/login.defs

Changin the users home directory permission
UMASK           022       # We subtract the 777 from UMASK and the result is the user's home directory permission

------------------------------------------------------------------
PAM:

/etc/pam.d or /etc/pam.conf
disable root ssh:
auth	required	pam_listfile.so \
	onerr=succeed	item=user	sense=deny	file=/etc/ssh/deniedusers


And lastly in /etc/ssh, we make a file called deniedusers and add "root" in the file.
auth: the module type
required: a flag that states if the above module is used, it must pass, otherwise fail.
pam_listfile.so: a module that provides a way to deny or allow services based on an arbitrary file
onerr=succeed: module argument
item=user: module argument that specifies what is listed in the file and should be checked for
sense=deny: module argument which specifies the action to take if the name is found in the file. If not found, then the opposite action is requested
file=/etc/ssh/deniedusers: module argument; specifies file containing one line per argument (in this case, our users that are denied access)

sudo nano /etc/pam.d/common-session
session optional pam_umask.so umask=077       # This line instructs the Pluggable Authentication Modules (PAM) system to set the umask to 077 during the user session initialization.


---
password policy:

sudo apt-get install libpam-pwquality       # automatically adds an entry into the /etc/pam.d/common-password

/etc/security/pwquality.conf on RedHat and Fedora
/etc/pam.d/common-password on Debian and Ubuntu. You can install it using apt-get install libpam-pwquality

difok=5 allows you to specify the number of characters in the new password that were not present in the old password.

minlen=10
minclass=3
retry=2

root@harden:/etc/pam.d# cat common-password | grep pwquality
password requisite pam_pwquality.so retry=3

There's a few differences but let's take a look:

  password: module
  requisite: module; states that if the the module fails, the operation is immediately terminated with a failure without invoking other modules
  pam_pwquality.so: checks the pwquality.conf file for the requirements
  retry=3: allows the user to retry their password 3 times before returning with an error
Uncomment lines in /etc/security/pwquality.conf


---
Password Expiration:

/etc/login.defs

PASS_MIN_DAYS: Users can’t change their password within this range. This is the minimum days that the password should stay unchanged.
PASS_WARN_AGE: how many days after the expiration, the should warn the user


---
Password History:

/etc/pam.d/common-password

password required pam_pwhistory.so remember=2 retry=3
password [success=1 default=ignore]
pam_unix.so use_authtok obscure sha512 shadow

password: module type we are referencing
required: module where failure returns a failure to the PAM-API
pam_pwhistory.so: module that configures the password history requirements
remember=2: option for the pam_pwhistory.so module to remember the last n passwords (n = 2). These passwords are saved in /etc/security/opasswd
retry=3: option for the pam_pwhistory.so module to prompt the user 3 times before returning a failure


------------------------------------------------------------------
echo -n ksdfhsdla | base64       # suppress the new line


------------------------------------------------------------------
sudo find /var/www/wordpress/ -type d -exec chmod 750 {} \;
  		-exec [[command]] \;

tar xvf latest.tar.gz        # unzip
tar xzvf latest.tar.gz       # unzip
touch htaccess.txt
tar -czf backup.tar.gz /path/to/local/directory/

rsync -avz /path/to/local/directory/ user@remote_server:/path/to/remote/directory/
scp backup.tar.gz user@remote_server:/path/to/remote/directory/




------------------------------------------------------------------
netstat -tulpn


------------------------------------------------------------------
user management / UAC / AC:

sudo useradd -g sftponly -s /bin/false -m -d /home/username username

disable root login:
/usr/sbin/nologin       # to disable the intractive log in for a user edit /etc/password, and the line instead of /bin/bash
root:x:0:0:root:/root:/usr/sbin/nologin
Then run "w" or who to see if there is anyone logged in as root. If any root is logged then run:
ps -aux to find the root sshd pid and finely kill the process by:
sudo kill -9 PID


The -g sftponly option will add the user to the sftponly group.
The -s /bin/false option sets the user’s login shell. By setting the login shell to /bin/false the user will not be able to login to the server via SSH.
The -m -d /home/username options tells useradd to create the user home directory.

------------------------------------------------------------------
AppArmor

/etc/apparmor.d			# Its directory
abstractions			# Partial profiles
#The sbin.dhclient and usr.* files are AppArmor profiles.
#The @{HOME} is an AppArmor variable that allows the rule to work with any user's home directory.
sudo apt install apparmor-profiles apparmor-profiles-extra
sudo apt install apparmor-profiles apparmor-profiles-extra

aa-status			# Status
sudo apt install apparmor-utils	# This will enable the following commands, aa-enforce, aa-disable, aa-audit, aa-complain

Enforce - Enforces the active profiles
Complain - Allows processes to perform disallowed actions by the profile and are logged
Audit - The same as Enforce mode but allowed and disallowed actions get logged to



```

===============================================================================
# Forensic
```
pdfinfo file.pdf			# sudo apt install poppler-utils
exiftool IMAGE.jpg			# sudo apt install libimage-exiftool-perl

```


===============================================================================

# gpg
```
gpg --gen-key
gpg --list-keys
gpg --armor --export test@test.com > public_key.asc
gpg --clear-sign --output signed.asc inp.txt
gpg --delete-secret-key memem
gpg --delete-key me@me.com
{{7*7}}
gpg -c <our_file>       # encrypt our_file (symetic)
gpg -d file       # decrypt file
gpg --export -a -o <filename>       # export our pub key
gpg --import key       # import other user's pub key
gpg -e <document>       # encrypt as asymetric
```

===============================================================================
# Wazuh
```
https://wazuh.com/blog/web-shell-attack-detection-with-wazuh/

remove agnet
/var/ossec/bin/manage_agents -r 001

file integrity monitoring:
<syscheck>
   <directories>FILEPATH/OF/MONITORED/FILE</directories>
   <directories>FILEPATH/OF/MONITORED/DIRECTORY</directories>
</syscheck>
```

===============================================================================
# CA , Certificate , SSL/TLS , HTTPS
```
Create a self-singed key and certificate pair:
sudo openssl req -x509 -nodes -days 365 -newkey rsa:4096 -keyout /etc/ssl/private/apache-selfsigned.key -out /etc/ssl/certs/apache-selfsigned.crt


sudo nano /etc/apache2/conf-available/ssl-params.conf
SSLCipherSuite EECDH+AESGCM:EDH+AESGCM
# Requires Apache 2.4.36 & OpenSSL 1.1.1
SSLProtocol -all +TLSv1.3 +TLSv1.2
SSLOpenSSLConfCmd Curves X25519:secp521r1:secp384r1:prime256v1
# Older versions
# SSLProtocol All -SSLv2 -SSLv3 -TLSv1 -TLSv1.1
SSLHonorCipherOrder On
# Disable preloading HSTS for now.  You can use the commented out header line that includes 
# the "preload" directive if you understand the implications.
# Header always set Strict-Transport-Security "max-age=63072000; includeSubDomains; preload"
Header always set X-Frame-Options DENY
Header always set X-Content-Type-Options nosniff
# Requires Apache >= 2.4
SSLCompression off
SSLUseStapling on
SSLStaplingCache "shmcb:logs/stapling-cache(150000)"
# Requires Apache >= 2.4.11
SSLSessionTickets Off


sudo cp /etc/apache2/sites-available/default-ssl.conf /etc/apache2/sites-available/default-ssl.conf.bak

sudo nano /etc/apache2/sites-available/default-ssl.conf
                ServerAdmin your_email@example.com
                ServerName server_domain_or_IP



sudo nano /etc/apache2/sites-available/000-default.conf
<VirtualHost *:80>
        . . .

        Redirect "/" "https://your_domain_or_IP/"

        . . .
</VirtualHost>







sudo a2enmod ssl
sudo a2enmod headers
sudo a2ensite default-ssl
sudo a2enconf ssl-params

sudo a2dismod ssl
sudo a2dismod headers
sudo a2dissite default-ssl
sudo a2disconf ssl-params



----------------
see if the key and certificate matches:
openssl x509 -noout -modulus -in cert.pem | openssl md5
openssl rsa -noout -modulus -in key.pem | openssl md5
```

===============================================================================
# wordpress
```
After configuring wordpress.conf:
sudo nano /etc/apache2/sites-available/wordpress.conf
		<Directory /var/www/wordpress/>
			AllowOverride All
		</Directory>

sudo a2enmod rewrite       # permalink (human-readable)


cd /tmp
curl -O https://wordpress.org/latest.tar.gz
tar xzvf latest.tar.gz
touch /tmp/wordpress/.htaccess
cp /tmp/wordpress/wp-config-sample.php /tmp/wordpress/wp-config.php
mkdir /tmp/wordpress/wp-content/upgrade
sudo cp -a /tmp/wordpress/. /var/www/wordpress
sudo chown -R www-data:www-data /var/www/wordpress
sudo find /var/www/wordpress/ -type d -exec chmod 750 {} \;
sudo find /var/www/wordpress/ -type f -exec chmod 640 {} \;


curl -s https://api.wordpress.org/secret-key/1.1/salt/       # getting the secret keys and adding them to wp-config.php

update the database info based to be the same as yours.

define the filesystem method that specify WordPress can access the file system directly or through ftp which requires password:
define('FS_METHOD', 'direct');
```

===============================================================================
# SSH:
```
ssh-keygen
	-b 6364        #  linger key
	-t ecdsa       # specify the algorithms 
ssh-copy-id username@remote_host
ssh username@remote_host command_to_run
ssh -p port_num username@remote_host

X11 Forwarding no       # it forwards GUI via ssh, but is risky

---
disabel ssh tunneling
 AllowTcpForwarding, GatewayPorts, PermitTunnel       # set them to "no"

---
diable root login:
nano /etc/ssh/sshd_config.conf
PermitRootLogin no
PubkeyAuthentication yes
PasswordAuthentication no

cat /home/user/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys

ssh -R <pivot_host_internal_ip>:<pivot_host_port>:0.0.0.0:<local_port> <target> -v -N
ssh -D 9090 us@targ

---
LogLevel INFO
QUIET
FATAL
ERROR
INFO
VERBOSE
DEBUG1
DEBUG2
DEBUG3
```

===============================================================================
# Syslog
```
sudo apt install rsyslog-relp
sudo apt-get install rsyslog-gnutls
sudo apt install gnutls-bin
sudo apt-get install libgnutls28-dev


rsyslogd -f /etc/rsyslog.conf -N1 

echo "Test message" | openssl s_client -connect 192.168.213.133:10514 -tls1


---------------
tsls

CA
certtool --generate-privkey --outfile ca-key.pem
certtool --generate-self-signed --load-privkey ca-key.pem --outfile ca.pem

----------------
machine
certtool --generate-privkey --outfile key.pem --bits 2048
certtool --generate-request --load-privkey key.pem --outfile request.pem

certtool --generate-certificate --load-request request.pem --outfile cert.pem --load-ca-certificate ca.pem --load-ca-privkey ca-key.pem


rm -f request.pem
mv cert.pem machine-cert.pem


---------------------------------------------
rsyslog with relp

server:
module(load="imuxsock")
module(load="imrelp" ruleset="relp")

template(name="remote-incoming-logs" type="string" string="/var/log/%HOSTNAME%/%PROGRAMNAME%.log")

input(type="imrelp" port="20514"
      tls="on"
      tls.caCert="/etc/ssl/rsyslog/ca.pem"
      tls.myCert="/etc/ssl/rsyslog/wazuh-cert.pem"
      tls.myPrivKey="/etc/ssl/rsyslog/wazuh-key.pem"
      tls.authMode="name"
      tls.permittedpeer=["ubuntu.naqib.com"])

ruleset (name="relp") {
    action(type="omfile" dynaFile="remote-incoming-logs")
}


client:
module(load="imuxsock")
module(load="omrelp")
module(load="imtcp")
input(type="imtcp" port="514")
action(type="omrelp" target="192.168.213.133" port="20514" tls="on" tls.caCert="/etc/ssl/rsyslog/ca.pem" tls.myCert="/etc/ssl/rsyslog/ubuntu-cert.pem" tls.myPrivKey="/etc/ssl/rsyslog/ubuntu-key.pem" tls.authmode="name" tls.permittedpeer=["wazuh.naqib.com"] )
```


===============================================================================
# sshfs
```
sshfs maythux@192.168.xx.xx:/home/maythuxServ/Mounted ~/remoteDir
sudo sshfs -o allow_other,default_permissions sammy@your_other_server:~/ /mnt/droplet
https://askubuntu.com/questions/412477/mount-remote-directory-using-ssh
```


===============================================================================
# Kubernetes
```
master:
API server: The gateway of communication
Scheduler: Schdule the running of pods on node, it just decides on which node the new pod should be scheduled but its kublet that run and execute that pod on the node
controller manager:
etcd: Is the cluster brain, store cluster state information

sudo swapoff -a
sudo nano /etc/fstab

https://phoenixnap.com/kb/install-kubernetes-on-ubuntu

sudo apt-mark hold kubeadm kubelet kubectl       #  prevent automatic installation, upgrade, or removal

---------------------
kubeadm version
kubectl version --client
kubectl version --client --output=yaml

kubectl apply -f file.yaml

kubectl get pod
kubectl get all
kubectl get svc       # service
kubectl get node -o wide== IP Address
kubectl get configmap
kubectl get secret
kubectl describe [recource type] [name]
kubectl describe service webapp-service

kubectl port-forward --address 0.0.0.0 service/webapp-service 8080:3000 
kubectl port-forward --address 0.0.0.0 service/webapp-service 8080:3000 &

----------
minikube

minikube start --driver docker --static-ip 192.168.200.200
minikube start --driver=docker 
minikube start 
minikube delete
minikube ip       # IP Address

sudo kubeadm init       # build the kuber cluster


To start using your cluster, you need to run the following as a regular user:

  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

Alternatively, if you are the root user, you can run:

  export KUBECONFIG=/etc/kubernetes/admin.conf

You should now deploy a pod network to the cluster.
Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
  https://kubernetes.io/docs/concepts/cluster-administration/addons/

Then you can join any number of worker nodes by running the following on each as root:

kubeadm join 192.168.213.138:6443 --token jlma89.t0zurjttn9rldwh3 \
        --discovery-token-ca-cert-hash sha256:60cc4e02b17b55de1e7016bc8940167773a4fe2bec58714c084ece29abd48a8c 
```

===============================================================================
# auditd
```
auditctl -w path_to_file -p permissions -k key_name
auditctl -a always,exit -F arch=b64 -S adjtimex -S settimeofday -k time_change
auditctl -a always,exit -F exe=/bin/id -F arch=b64 -S execve -k execution_bin_id
```

===============================================================================
# vyos
```
1. Set NAT, SSH, DHCP, DNS
2. Harden
3. Set groups
4. Set stateful firewall with global options
5. Block incoming (drop forward from outside to inside)
6. Allow management


Input       # Traffic that come to the router, des is router | default action should be "drop"
Output       # Traffic go out from the router, src is router
Forward       # Router just forward the traffic, its not dec nor src | forward should not be allowed from outside to inside
Hook       # Connection point like forward, input, output, etc.
Chain       # Set of rules
Common chain       # Custom chain
jump       # if the condition in current chain meet for the traffic, then refer to specific chain. Normally, from base chain to custom chains.
default-action       # if no rule in the current chain corresponding to traffic, do what the default-action says. For base chains (input, output, forward), it is set to "accept". For custom chain (name), it is set to "drop".
return       # if no rule in the current chain corresponding to traffic, return to main chain.
outbound-interface - applicable only to SNAT
        sourse
	translation 
inbound-interface - applicable only to DNAT
	destination
	translation

b: will scroll back one page
/config/config.boot       # config file

config       # go to config mode
show configuration
show configuration commands | strip-private        # run opp commands in config mode
run [command]       # run any opp command in config mode

edit interfaces ethernet eth0       # moving in hierarchy to "interfaces ethernet eth0"
up       # moving one level up in hierarchy
top       # moving to the top level
show inerfaces       # in config mode shows the configuration of interfaces, + for set, - for delete, > for |change|
copy rule 10 to rule 20
rename rule 10 to rule 5
comment firewall all-ping "Yes I know this VyOS is cool"       # comments are in /* */
comment firewall all-ping ""       # to remove

show system commit       # see local backups (revisions)
set system config-management commit-revisions 1
compare 0 6
compare 1
rollback 1

|set system config-management commit-archive location SFTP://user:pass@ip/path|

save [path]
load [path]

compare       # |show the configs|
commit       # commit the changes
commit-confirm <miniutes>       # it commit the changes for specified minutes, by default 10 min
confirm       # run after commit-confirm to confirm the commit, otherwise, it reverts back.
save


ipv4:
- set firewall
    * ipv4
         - forward
            + filter
         - input
            + filter
         - output
            + filter
         - name
            + custom_name
set firewall ipv4 forward filter rule <1-999999> disable       # disable the rule

Logging
set firewall ipv4 forward filter enable-default-log 
set firewall ipv4 forward filter rule <1-999999> log
set firewall ipv4 forward filter rule <1-999999> log-options level [emerg | alert | crit | err | warn | notice | info | debug]
set firewall ipv4 forward filter rule <1-999999> log-options group <0-65535> 



hardening:
set system login user [newuser] authentication plaintext-password [password]
set system login user [newuser] authentication public-keys myusername@mydesktop type ssh-rsa
set system login user [newuser] authentication public-keys myusername@mydesktop key [pub key]
```

===============================================================================
# Git Repo
```
google dorking:

find git repositories to clone:
	- intitle: indexof /.git
find "secret"s from gitlab repository text files:
	- filetype:txt site:gitlab.* "secret"
find website logins from gitlab repositories
	- site:gitlab.* intext:password intext:@gmail.com | @yahoo.com
find windows login credentials from github repositories
	- site:github.com intext:"unattend xmlns" AND "password" ext:xml


git:

# in copyed directoy 

git log
git show 438fa54ba62144ad84376635d957e5e73d89066e	# give us the diff, or what was added between the two commits
git branch						# list branches
git branch -a						# list all branches
git init			# create a new git repo
git clone <location of repo>	# create a copy of a repo
git add <filename>		# add a file for staging
git commit			# save all changes in staging into commi
git checkout <branch>		# switch between git branches
git checkout 438fa54ba62144ad84376635d957e5e73d89066e	# also, it used to go to specific version of a commit
git revert <commit reference>	# revert back to an old commit

```

===============================================================================
# Python
```
# file
f = open("file_name", "r")
print(f.read())

f = open("demofile1.txt", "a")			# Append to an existing file
f.write("The file will include more text..")
f.close()

f = open("demofile2.txt", "w")			# Creating and writing to a new file
f.write("demofile2 file created, with this content in!")
f.close()


```

