#!/bin/bash
clear
versione=0.2
function controlloversione
{
# verrà implementata un controllo di versione per scaricare la versione aggiornata dello script.
i=0
wget -P /tmp/ http://goo.gl/Aj88h5
for tmp in `cat /tmp/Aj88h5`
	do
	versionescaricata[i]=$tmp
	if [ $i == 0 ]
		then
		echo "|"`date +%T`"|" "L'ultima versione disponibile è la $versionescaricata e si possiede la versione $versione."
		sleep 1
	fi
	let i=$i+1
	done
rm /tmp/Aj88h5
if [ ${versionescaricata[0]} == $versione ]
	then
	echo "|"`date +%T`"|" "Disponete dell'ultima versione. Lo script non necessita di nessun aggiornamento."
	echo "|"`date +%T`"|" "Inizierà l'installazione del demone di Deluge."
else
	echo "|"`date +%T`"|" "È necessario un aggiornamento!"
	sleep 1
	echo "|"`date +%T`"|" "Potete trovare il changelog della nuova versione al seguente link: ${versionescaricata[2]}"
	sleep 2
	wget ${versionescaricata[1]}
	chmod +x delugedinstall$versionescaricata.sh
	./delugedinstall$versionescaricata.sh
fi
}
echo "###############################################################"
echo "#                                                             #"
echo "#           Deluge Installer per sistemi Debian-like          #"
echo "#                         v $versione                               #"
echo "#                                                             #"
echo "###############################################################"
echo "#Note:                                                        #"
echo "#§Per eseguire alcuni comandi è necessario la password di     #"
echo "# amministrazione e una connessione a internet.               #"
echo "#§Verranno rimossi e modificati dei pacchetti. Si consiglia   #"
echo "# aver disponibile come minimo 100 MB sul disco.              #"
echo "#§La procedura potrebbe richiedere tempo. Si prega di         #"
echo "# attendere pazientemente l'esecuzione dello script.          #"
echo "#§Questa procedura vi consentirà l'installazione del client   #"
echo "# torrent Deluge come demone nel vostro computer.             #"
echo "# Utilizzatelo con le dovute precauzioni.                     #"
echo "#§È possibile terminare in qualsiasi momento lo script        #"
echo "# premendo simultaneamente Ctrl+c.                            #"
echo "###############################################################"
echo "#§Prima di iniziare, è necessario dare allo script il vostro  #"
echo "# username e la vostra password, richieste nel processo di    #"
echo "# configurazione di Deluge. Esse serviranno solamente per     #"
echo "# configurare correttamente il demone.                        #"
echo "###############################################################"
sleep 3
echo "|"`date +%T`"|" "Controllo l'esistenza di una versione più aggiornata dello script..."
sleep 1
controlloversione
read -p "Username: " username
echo "Password per $username: " ; read -s password
echo "|"`date +%T`"|" "Inizio esecuzione dello script..."
echo "|"`date +%T`"|" "Cerco il sistema operativo utilizzato..." `uname -v`
echo "|"`date +%T`"|" "Installo Deluge con l'interfaccia web e dipendenze..."
sleep 1
sudo apt-get update
sudo apt-get install deluged python-mako deluge-web -y
echo "|"`date +%T`"|" "Avvio Deluge..."
deluged
sleep 5
echo "|"`date +%T`"|" "Modifico il file di configurazione"
echo "|"`date +%T`"|" "Nota: sarà creato un backup del file ~/.config/deluge/auth. Sarà rinominato auth.old"
cp ~/.config/deluge/auth ~/.config/deluge/auth.old
sudo echo "$username:$password:10" >> ~/.config/deluge/auth
echo "|"`date +%T`"|" "Avvio interfaccia Web di Deluge..."
deluge-web > /dev/null &
echo "|"`date +%T`"|" "Creo cartella per i download in /home/$username/Download..."
mkdir /home/$username/Download
mkdir /home/$username/Download/.temp
echo "|"`date +%T`"|" "Configuro Deluge per l'avvio automatico..."
sleep 1
sudo wget -O /etc/default/deluge-daemon http://dl.delugedinstall.altervista.org/dl/permanent/default.deluge-daemon.txt
sudo sed -i "4 i DELUGED_USER=\"$username\"" /etc/default/deluge-daemon
sudo wget -O /etc/init.d/deluge-daemon http://dl.delugedinstall.altervista.org/dl/permanent/init.d.deluge-daemon.txt
sudo chmod 755 /etc/init.d/deluge-daemon
sudo update-rc.d deluge-daemon defaults
read -p "|"`date +%T`"| Installazione completata. Si desidera riavviare il sistema? (y/n)?" risposta
if [ "$risposta" = "y" ]
then
	echo "Il sistema verrà riavviato!"
	sleep 1
	sudo reboot
else
	echo "Installazione finita!"
fi

