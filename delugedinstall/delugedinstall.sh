#!/bin/bash
clear
versione=0.3
function installazione
{
#verrà scaricato il file "tmpversione" e i dati verranno ricaricati in un array.
#lo script verrà copiato in /usr/bin/ per far si che possa essere eseguito come un normale "programma"
#inoltre verrà rinominato rimuovendo l'estensione .sh
i=0
wget -q -P /tmp/ http://dl.delugedinstall.altervista.org/dl/permanent/tmpversione -O /tmp/Aj88h5
#in alternativa (ma non sempre funziona) wget -P /tmp/ http://goo.gl/Aj88h5
for tmp in `cat /tmp/Aj88h5`
	do
	versionescaricata[i]=$tmp
	let i=$i+1
	done
rm /tmp/Aj88h5
echo "|"`date +%T`"|" "Downloading the script..."
wget -q -P /tmp/ https://github.com/Polpetta/delugedinstall/archive/${versionescaricata[0]}.tar.gz -O /tmp/delugedinstall-v${versionescaricata[0]}.tar.gz
echo "|"`date +%T`"|" "Installing the script in /usr/bin/ ..."
cd /tmp/ && tar xf delugedinstall-v${versionescaricata[0]}.tar.gz && cd 
cp /tmp/delugedinstall-${versionescaricata[0]}/delugedinstall/delugedinstall.sh /usr/bin/delugedinstall
chmod +x /usr/bin/delugedinstall
echo "|"`date +%T`"|" "Program installed successfully"
echo "|"`date +%T`"|" "Cleaning..."
rm /tmp/delugedinstall-v${versionescaricata[0]}.tar.gz
rm -rf /tmp/delugedinstall-${versionescaricata[0]}/
}
function controlloversione
{
# verrà implementata un controllo di versione per scaricare la versione aggiornata dello script.
i=0
wget -q -P /tmp/ http://dl.delugedinstall.altervista.org/dl/permanent/tmpversione -O /tmp/Aj88h5
for tmp in `cat /tmp/Aj88h5`
	do
	versionescaricata[i]=$tmp
	if [ $i == 0 ]
		then
		echo "|"`date +%T`"|" "Last available version is $versionescaricata version, and you currently have $versione version."
		sleep 1
	fi
	let i=$i+1
	done
rm /tmp/Aj88h5
if [ ${versionescaricata[0]} == $versione ]
	then
		echo "|"`date +%T`"|" "You have the last available version. The script doesn't need any update."
		echo "|"`date +%T`"|" "Deluge daemon's installation will start shortly."
else
	echo "|"`date +%T`"|" "An update is needed!"
	sleep 1
	echo "|"`date +%T`"|" "You can find new version's changelog at the following link: ${versionescaricata[2]}"
	sleep 2
	wget -q -P /tmp/ https://github.com/Polpetta/delugedinstall/archive/${versionescaricata[0]}.tar.gz -O /tmp/delugedinstall-v${versionescaricata[0]}.tar.gz
	cd /tmp/ && tar xf delugedinstall-v${versionescaricata[0]}.tar.gz
	cd /tmp/delugedinstall-${versionescaricata[0]}/delugedinstall/
	chmod +x delugedinstall.sh
	./delugedinstall.sh
fi
}
if [ $(id -u) != "0" ]
then
    echo "|"`date +%T`"|" "You must be the superuser to run this script!!"
    exit 1
fi
echo "###############################################################"
echo "#                                                             #"
echo "#           Deluge Installer for Debian-like systems          #"
echo "#                         v $versione                               #"
echo "#                                                             #"
echo "###############################################################"
echo "#Notes:                                                       #"
echo "#§In order to run some commands you will need administrator's #"
echo "#  password and an Internet connection.                       #"
echo "#§Some package will be removed or modified. We recommend      #"
echo "# to have at least 100 MB of free disk space.                 #"
echo "#§The procedure could teke some time. Please, patiently wait  #"
echo "#  script execution.                                          #"
echo "#§This procedure will allow you to install on your computer   #"
echo "# Deluge, a torrent client.                                   #"
echo "# We recommend to use it with proper precautions.             #"
echo "#§It's possible to stop the script in any moment simply       #"
echo "# pressing Ctrl+c at the same time.                           #"
echo "###############################################################"
echo "#§Before starting, it's necessary to give to the script       #"
echo "# your username and password, that are requested in Deluge's  #"
echo "# configuration process. It will only be used to              #"
echo "# correctly configurate the daemon.                           #"
echo "###############################################################"
sleep 3
echo "|"`date +%T`"|" "Checking for the existance of a newer version of the script..."
sleep 1
controlloversione
case "$1" in
        --install)
            installazione
            ;;
         
        -i)
            installazione
            ;;
esac
read -p "Username: " username
echo "Password per $username: " ; read -s password
echo "|"`date +%T`"|" "Starting script's execution..."
echo "|"`date +%T`"|" "Checking what OS is used..." `uname -v`
echo "|"`date +%T`"|" "Installing Deluge with web interface and dependances..."
sleep 1
apt-get update
apt-get install deluged python-mako deluge-web -y
echo "|"`date +%T`"|" "Starting Deluge..."
deluged
sleep 5
echo "|"`date +%T`"|" "Confiuration's file will be modified"
echo "|"`date +%T`"|" "Note: a backup of the file ~/.config/deluge/auth will be created. it will be renamed auth.old"
cp ~/.config/deluge/auth ~/.config/deluge/auth.old
echo "$username:$password:10" >> ~/.config/deluge/auth
echo "|"`date +%T`"|" "Initiating Deluge's web interface..."
deluge-web > /dev/null &
echo "|"`date +%T`"|" "Creating a download folder in /home/$username/Download..."
mkdir -p /home/$username/Download
mkdir -p /home/$username/Download/.temp
echo "|"`date +%T`"|" "Configuring Deluge for auto start..."
sleep 1
wget -q -O /etc/default/deluge-daemon http://dl.delugedinstall.altervista.org/dl/permanent/default.deluge-daemon.txt
sed -i "4 i DELUGED_USER=\"$username\"" /etc/default/deluge-daemon
wget -q -O /etc/init.d/deluge-daemon http://dl.delugedinstall.altervista.org/dl/permanent/init.d.deluge-daemon.txt
chmod 755 /etc/init.d/deluge-daemon
update-rc.d deluge-daemon defaults
read -p "|"`date +%T`"| Installation complete. Do you want to reboot the system? (y/n)?" risposta
if [ "$risposta" = "y" ]
then
	echo "System will reboot!"
	sleep 1
	reboot
else
	echo "Installation complete!"
fi
exit 0
