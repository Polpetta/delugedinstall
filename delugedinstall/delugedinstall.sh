#!/bin/bash
clear
versione=0.3
function unistall
{
#The Daemon will be removed, such as graphic interface. It's important to run a deep cleaning.
	apt-get purge deluged python-mako deluge-web deluge-console -y
	rm -rf ~/.config/deluge/
	echo "It's necessary to select the user used for the installation to remove all the files in the correct way."
	user
	read -p "|"`date +%T`"| Do you want remove \"Download\" path? (y/n)" risposta
	if [ "$risposta" = "y" ]
	then
		rm -rf /home/$username/Download
	else
		echo "Unistall Complete!"
	fi
}
function aiuto
{
#vengono descritti in dettaglio i comandi di questo script
	echo "|"`date +%T`"|" "Questa sezione deve essere ancora completata."
}
function installazione
{
#questa funzione permetterà l'installazione del demone deluge.
	clear
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
	sleep 3
	read -p "|"`date +%T`"| It's strongly suggested to upgrade the script to the last stable version before to proceed with installation. Do you want to upgrade? (y/n)" risposta
	if [ $risposta == "y" ]
	then
		controlloversione
	fi
	user
	echo "|"`date +%T`"|" "Generating a random password..."
	password=( $(dd if=/dev/random bs=1 count=16 2>/dev/null | hexdump -e '16/1 "%02x" "\n"') )
	echo "|"`date +%T`"|" "Generated password is $password"
	sleep 1
	echo "|"`date +%T`"|" "Starting script's execution..."
	echo "|"`date +%T`"|" "Checking what OS is used..." `uname -v`
	echo "|"`date +%T`"|" "Installing Deluge with web interface and dependances..."
	sleep 1
	apt-get update
	apt-get install deluged python-mako deluge-web -y
	echo "|"`date +%T`"|" "Starting Deluge..."
	deluged > /dev/null &
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
	case "$1" in
		-ir)
		    remote
		    ;;
		-irs)
		    remote
		    ;;
		-isr)
		    remote
		    ;;
		-ris)
		    remote
		    ;;
		-rsi)
		    remote
		    ;;
		*)
		    ;;
	esac
	echo "|"`date +%T`"|" "Your local ip is: " `hostname -i`". Connect to "`hostname -i`":8112 to see the Web UI interface."
	read -p "|"`date +%T`"| Installation complete. Do you want to reboot the system? (Y/n)?" risposta
	if [ "$risposta" = "y" ]
	then
		echo "System will reboot!"
		sleep 1
		reboot
	else
		echo "Installation complete!"
	fi
}
function remote
{
#questa funzione permetterà al client deluged di essere controllato da un altro computer connettendosi al demone tramite deluge-gtk
	apt-get install deluge-console -y
	echo "|"`date +%T`"|" "Remote control is being authorized"
	deluge-console "config -s allow_remote True"
	deluge-console "config allow_remote"
	echo "|"`date +%T`"|" "Task completed. In order to connect is required to digit in your client the address "`hostname -i`" with the selected user and the automatically generated password before, such as $password. A system reboot is necessary"
}
function user
{
	users=( $(cat /etc/passwd | grep /home | cut -d: -f1) )
	echo "|"`date +%T`"|" "User founded in this computer:"
	for ((elemento=0; elemento < ${#users[@]}; elemento++))
		do
			echo "$elemento) ${users[$elemento]}"
		done
	if [ ${#users[@]} == 1 ]
		then
			echo "|"`date +%T`"|" "Found ${#users[@]} user"
			username=${users[0]}
			echo "|"`date +%T`"|" "User has been automatically selected, $username will be used"
		else
			echo "|"`date +%T`"|" "Found ${#users[@]} users"
			read -p "Select the number of the used user: " numero_user
			for ((i=0; i < ${#users[@]}; i++))
				do
					if [ $numero_user = $i ]
					then
						username=${users[$i]}
					fi
				done
			echo "|"`date +%T`"|" "User" $username "has been selected"
	fi
}
function salva
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
	echo "|"`date +%T`"|" "Program saved successfully"
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
		echo "|"`date +%T`"|" "An update (or downgrade to stable version) is needed!"
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
		echo "|"`date +%T`"|" "You must be superuser to run this script!!"
		exit 1
fi
echo "|"`date +%T`"|" "Checking for the existance of a newer version of the script..."
controlloversione
case "$1" in
	-u)
	    controlloversione
	    #controlla solamente se la versione in uso è l'ultima versione stabile rilasciata. Non clona il repository.
	    ;;
	--unistall)
	    unistall
	    ;;
	-i)
	    installazione
	    ;;
        -s)
            salva
            ;;
	-r)
	    remote
	    ;;
	-is)
	    installazione
	    salva
	    ;;
	-ir)
	    installazione
	    #l'abilitazione del controllo remoto verrà al "case" presente nella funzione installazione.
	    ;;
	-irs)
	    installazione
	    remote
	    salva
	    ;;
	-isr)
	    installazione
	    remote
	    salva
	    ;;
	-ris)
	    installazione
	    remote
	    salva
	    ;;
	-rsi)
	    installazione
	    remote
	    salva
	    ;;
	--help)
	    aiuto
	    ;;
	*)
	    echo "|"`date +%T`"|" "The input isn't valid. Digit \"--help\" in order to get more informations."
	    exit 1
	    ;;
esac
exit 0
