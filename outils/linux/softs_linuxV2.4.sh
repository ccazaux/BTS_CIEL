#! /bin/bash
# ____   ____ ____  ___ ____ _____   ____   ____   ____  _   _ ____  
#/ ___| / ___|  _ \|_ _|  _ \_   _| |  _ \ / ___| / ___|| | | |  _ \ 
#\___ \| |   | |_) || || |_) || |   | |_) | |     \___ \| | | | | | |
# ___) | |___|  _ \ | ||  __/ | |   |  __/| |___   ___) | |_| | |_| |
#|____/ \____|_| \_\___|_|    |_|   |_|    \____| |____/ \___/|____/ 
# Auteur : CCA, le 11/11/2022, derniere MaJ le 9/5/2023
# Version 2.3 : Correction remove brltty (oubli -y) et configuration IDE arduino (preferences, libs et ESP32)
# Installation supplémentaires (goldendict, wireshark...)
# Bonne organisation des menus + isis et falstad dans le menu
# Version 2.4 : Desactivation auto du verouillage mot de passe
# Lancement utilitaire de license proteus en fin de script
# Nettoyage du repertoire .config/autostart et correction erreur dans nom de fichier pour arret automatique le soir
# Ajout affichage du temps de debut / fin du script.
# TODO ############################################
# QT creator? Identifier les besoins (packs à installer)
# Besoin de FlowCode ? Fibula  ?
# Installer vscodium au lieu de vscode? extension necessaires?
# Installation Grammalecte-fr-v2.1.2.oxt
# Active directory/sauvegarde/NAS?
# Packet tracer : auto log? adresse mail?
#### Notes pour l'installation préalable de l'OS  
# Ce script a été testé avec Lubuntu puis Linux Mint Cinnamon, et devrait fonctionner sur la plupart 
# des distributions basées sur debian/ubuntu
# TODO : autoinstall avec langue fr preselectionnee + lancement script install ou selection paquets
# cf https://unix.stackexchange.com/questions/196874/prevent-language-selection-at-ubuntu-installation
# cf https://www.rodneybeede.com/tech%20tricks/custom_preseed_ubuntu_server_iso_from_usb.html
# preenregistrement des fichiers *.deb sur un serveur ou un disque pour ne pas les retelecharger a chaque fois?

#Log version script 
sudo echo "Script SUDV2.4" >> ~/.config/ste_version.txt
echo "debut du script"
start_date=$(date)
date

###############################################################################
echo "### Mise a jour et preparation systeme ###"
###############################################################################
## suppression indésirables lubuntu
sudo apt remove 2048-qt -y
sudo apt remove thunderbird trojita -y
## suppression indésirables mint
sudo apt remove simple-scan hypnotix -y 
##Autorisation des logiciels "snap" sur linux Mint
sudo mv /etc/apt/preferences.d/nosnap.pref ~/Documents/nosnap.backup

##Mise à jour système
sudo apt update
sudo apt upgrade -y

## creation repertoires eleves et installation 
sudo mkdir -p /opt/install && cd "$_"
sudo mkdir -p ~/travaux_eleves

## Installtion outils indispensables
sudo apt install snap snapd git curl wget nano  meld gcc g++ net-tools -y
## Installation outils utiles
sudo apt install gedit figlet printer-driver-cups-pdf btop htop traceroute -y

#Configurer Ubuntu en horloge locale (pour eviter le decalage windows linux)
timedatectl set-local-rtc 0 --adjust-system-clock

echo "Autoextinction le soir (economies d'energie) : Creation fichier .desktop"
echo "qui lance au démarrage un arret planifié le soir :"
#Supression de ce qui pouvait se trouver dans autostart. 
sudo rm -r ~/.config/autostart/*
cd ~/.config/autostart/
sudo echo "[Desktop Entry]"				 > shutdownnight.desktop
sudo echo "Type = Application" 			>> shutdownnight.desktop
sudo echo "Name = Extinction_des_feux" 	>> shutdownnight.desktop
sudo echo "Exec = gnome-terminal --command \"shutdown 20:00\"" 	>> shutdownnight.desktop
#pour annuler l'extinction programmée: Entrer "shutdown -c"
#pour verifier que l'extinction est programmee ou non : cat /run/systemd/shutdown/scheduled
#pour desactiver l'extinction, renommer l'extinction  du fichier, ou taper "démarrage" dans le menu

#DESACTIVATION VEROUILLAGE ECRAN (ne pas executer en root)
gsettings set org.cinnamon.desktop.screensaver lock-enabled false

###############################################################################
echo "### MATHS PHYSIQUE ###"
###############################################################################
cd /opt/install
##xcas
sudo apt install xcas -y
sudo apt install geogebra -y
## Fibula (a voir si utile?)
#sudo mkdir -p  /opt/install/fibula && cd "$_"
#sudo wget http://www.didalab-didactique.fr/update/Fibula/Fibula_V14.zip
#sudo wget http://www.didalab-didactique.fr/update/Fibula/TP.zip
#sudo unzip Fibula_V14.zip
#wine CDM_v2.12.00_WHQL_Certified.exe
#wine Fibula_i_Install.exe
#Probleme avec drivers FTDI? A vérifier FTD2XX.DLL
#check  https://github.com/brentr/wineftd2xx

###############################################################################
echo "### ELECTRONIQUE ###"
###############################################################################
####Arduino ##############################################################

# Arduino
# ne PAS passer par sudo apt install arduino !! (version obsolete)
# ne PAS installer les versions 2.XX (interface lourde)
# Utiliser les versions "Legacy IDE (1.8.X)" cf https://www.arduino.cc/en/software
sudo mkdir -p  /opt/install/arduino && cd "$_"
sudo wget https://downloads.arduino.cc/arduino-1.8.19-linux64.tar.xz
sudo tar -xvf ./arduino*.tar.xz
./arduino-1.8.19/install.sh 
#Pour les cartes ESP32, besoin de python complémentaires
#https://dl.espressif.com/dl/package_esp32_index.json
sudo apt install python-is-python3 -y
sudo apt install python3-pip -y
sudo pip3 install pyserial

#Pour les probleme de detection arduino chinois avec driver CH341(redemarrage necessaire)
#"Could not open /dev/ttyUSB0, the port doesn't exist"
sudo apt remove brltty -y
sudo adduser $USER dialout

#installation arduino CLI (Command Line Interface)
sudo snap remove arduino-cli #Suppression version arduino-cli snap si elle existe 
mkdir -p ~/.arduino-cli && cd "$_"	# creation dossier temporaire
curl -fsSL https://raw.githubusercontent.com/arduino/arduino-cli/master/install.sh | sh	#telechargement et installation
sudo cp ./bin/arduino-cli /usr/bin/		#copie dans path 
rm -rf ~/.arduino-cli	#nettoyage dossier temporaire

# setup configuration file
arduino-cli config init --overwrite
#Config file written: /home/username/.arduino15/arduino-cli.yaml
#arduino-cli config dump >.cli-config.yml
cd ~/.arduino15
sudo echo "board_manager:"				 			>> arduino-cli.yaml
sudo echo "    additional_urls:"				 	>> arduino-cli.yaml
#sudo echo "    - https://dl.espressif.com/dl/package_esp32_index.json"				 							>> arduino-cli.yaml # obsolete
sudo echo "    - https://espressif.github.io/arduino-esp32/package_esp32_index.json"				 			>> arduino-cli.yaml
sudo echo "    - https://github.com/stm32duino/BoardManagerFiles/raw/main/package_stmicroelectronics_index.json">> arduino-cli.yaml

#mise a jour index
arduino-cli core update-index

###Téléchargement outils cartes AVR
arduino-cli core install arduino:avr
#arduino-cli board listall

###Téléchargement outils cartes STM32
#arduino-cli core update-index --additional-urls 'https://github.com/stm32duino/BoardManagerFiles/raw/main/package_stmicroelectronics_index.json'
#arduino-cli core update-index
#arduino-cli core search stm
arduino-cli core install STMicroelectronics:stm32
###Téléchargement outils cartes ESP32
#arduino-cli core update-index --additional-urls 'https://dl.espressif.com/dl/package_esp32_index.json'
#arduino-cli core search esp32
arduino-cli core install esp32:esp32

###Téléchargement librairies couramment utilisées , pour arduino générique
arduino-cli lib install UIPEthernet DmxSimple FastLED "Adafruit Motor Shield library"
###Téléchargement librairies couramment utilisées, pour ESP32
arduino-cli lib install esp_dmx AsyncTCP
#arduino-cli lib list

#ESP32 : sauvegarde fichier boards.txt puis telechargement boards.txt avec les cartes utilisees en tete de liste
cd ~/.arduino15/packages/esp32/hardware/esp32/2.*
sudo cp boards.txt boards.txtbak
fileid="1DQNQdBCkv-C9RUOGS5LhmkS2KOCqlAqH"
filename="boards.txt"
html=`curl -c ./cookie -s -L "https://drive.google.com/uc?export=download&id=${fileid}"`
sudo curl -Lb ./cookie "https://drive.google.com/uc?export=download&`echo ${html}|grep -Po '(confirm=[a-zA-Z0-9\-_]+)'`&id=${fileid}" -o ${filename}

#Remplacement de preferences.txt  pour inclure les
#URL des cartes ESP32 et STM32, et l'affichage des num de lignes...
cd ~/.arduino15
sudo cp preferences.txt preferences.txtbak
fileid="1u3K1aA2X4rOJjY6g-Bd3Llka3gAf_lOl"
filename="preferences.txt"
html=`curl -c ./cookie -s -L "https://drive.google.com/uc?export=download&id=${fileid}"`
sudo curl -Lb ./cookie "https://drive.google.com/uc?export=download&`echo ${html}|grep -Po '(confirm=[a-zA-Z0-9\-_]+)'`&id=${fileid}" -o ${filename}

#Picoscope 7 (70MB)
#sudo apt-get install libps2000a -y
#sudo wget -O - https://labs.picotech.com/Release.gpg.key | sudo apt-key add -
#sudo bash -c 'echo "deb https://labs.picotech.com/rc/picoscope7/debian/ picoscope main" >/etc/apt/sources.list.d/picoscope7.list'
#sudo apt-get update
#sudo apt-get install picoscope -y

#Suppression picoscope 7 (pas satisfaisant pour le moment) si installé et installation picoscope 6
sudo rm /etc/apt/sources.list.d/picoscope7.list
sudo apt remove picoscope -y
sudo bash -c 'echo "deb http://labs.picotech.com/debian picoscope main" >/etc/apt/sources.list.d/picoscope6.list'
sudo wget -O - http://labs.picotech.com/debian/dists/picoscope/Release.gpg.key | sudo apt-key add -
sudo apt update
sudo apt-get install libpicoipp=1.3.0-4r130 -y --allow-downgrades
sudo apt-get install libps2000=3.0.82-3r3072 -y --allow-downgrades
sudo apt-get install libps3000=4.0.82-3r3072 -y --allow-downgrades
sudo apt-get install picoscope -y

# Falstad (simulateur electronique 220MB)
sudo mkdir -p /opt/install/falstad && cd "$_"
sudo wget https://www.falstad.com/circuit/offline/circuitjs1-linux64.tgz
sudo tar -xvf ./circuitjs1-linux64.tgz
sudo ln -s ./circuitjs1/circuitjs1 ./falstad

# Kicad (derniére version, à vérifier sur kicad.org/download/ubuntu )
sudo add-apt-repository --yes ppa:kicad/kicad-6.0-releases
sudo apt update
sudo apt install --install-recommends kicad -y

#Installation fritzing
sudo apt install fritzing -y

# ISIS Proteus v7.10 :  telechargement de l'archive faite via tar -czvf isis.tar.gz ./Proteus\ lubuntu\ test/
sudo mkdir -p  /opt/install && cd "$_"
#fileid="1wWeqxspPfpJ_HWjwA_77p4VE747QNfDd"
fileid="1KPzdQkkSnjCjw174j3V-Ni32__S2TwO6"
filename="proteus.tar.gz"
html=`curl -c ./cookie -s -L "https://drive.google.com/uc?export=download&id=${fileid}"`
sudo curl -Lb ./cookie "https://drive.google.com/uc?export=download&`echo ${html}|grep -Po '(confirm=[a-zA-Z0-9\-_]+)'`&id=${fileid}" -o ${filename}
sudo tar -xzvf ${filename}
#Au premier demarrage, la license est demandée. Elle est dans /opt/install/proteus/LIC

#SUblime texte
sudo wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/sublimehq-archive.gpg > /dev/null
sudo echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list
sudo apt-get update
sudo apt-get install sublime-text -y

###############################################################################
echo "### INFORMATIQUE ###"
###############################################################################
#installation codeblocks, virtualbox...
sudo apt install nmap -y
sudo apt install codeblocks virtualbox putty -y
sudo apt install qtcreator  -y
sudo snap install code --classic
sudo snap install audacity
#Wireshark en mode non interactif
sudo DEBIAN_FRONTEND=noninteractive apt-get -y install wireshark-qt
#LAMP, cf https://doc.ubuntu-fr.org/lamp
sudo apt install apache2 php libapache2-mod-php mariadb-server php-mysql -y
#Raspberry pi imager (pour installer des OS sur carte SD pour raspberry pi)
sudo apt install rpi-imager -y

####################################################################
echo "### BUREAUTIQUE, UTILITAIRES, MODIFICATION MENUS ###"
####################################################################

## Diagrammes de GANTT avec ProjectLibre (pour diagrammes de Gantt?)
sudo snap install projectlibre

#Freemind (MindMapping)
sudo snap install freemind

#Dia (graphiques, logigrammes, chronogrammes...)
sudo apt install dia -y

##Drawio (diagrammes en tout genres)
sudo mkdir -p /opt/install/drawio && cd "$_"
sudo wget https://github.com/jgraph/drawio-desktop/releases/download/v20.8.16/drawio-amd64-20.8.16.deb
sudo apt install ./drawio*.deb -y

#Installation GoldenDict (dictionnaire francais anglais locaux)
sudo apt install goldendict -y
#Installation des dictionnaires spécifiques babylon FR<->EN

sudo mkdir -p /usr/share/goldendict && cd "$_"
sudo wget http://info.babylon.com/glossaries/387/Babylon_English_French.BGL
sudo wget http://info.babylon.com/glossaries/4E5/Babylon_French_English_diction.BGL
killall goldendict
mkdir -p ~/.goldendict && cd "$_"
cd ~/.goldendict
sudo echo "<config>"			 > config
sudo echo " <paths>" 			>> config
sudo echo "  <path recursive=\"1\">/usr/share/goldendict</path>" >> config
sudo echo " </paths>" 			>> config
sudo echo "</config>" 			>> config

#Installation dictionnaires freedict (moins complets que babylon?  a tester)
#apt install dict-freedict-eng-fra dict-freedict-fra-eng 

#nettoyage paquets inutilisés:
sudo apt autoremove -y
sudo apt --fix-broken install

#Fond d'ecran custom Saint-Eloi (heberge chez prof.cazaux.org)
#cd /usr/share/lubuntu/wallpapers
#sudo wget --no-check-certificate 'https://docs.google.com/uc?export=download&id=15nkxNADIqX7s-87lONPjQBJq46ve7LzY' -O wallpaper-ste.png
#sudo rm lubuntu-default-wallpaper.png
#sudo ln -s  ./wallpaper-ste.png ./lubuntu-default-wallpaper.png

#### Logiciels non retenus, mais qui pourraient etre utiles ####
#sudo apt install gdb gimp lsd vim emacs IDLE (ou autre editeur python?)
#Remplacer firefox par chrome???? navigateur??
#sudo apt-get purge firefox
#sudo apt install google-chrome

# WINE last version, cf https://wiki.winehq.org/Ubuntu
#sudo apt update
#sudo apt install --install-recommends winehq-stable -y
sudo apt install wine -y
sudo apt install winetricks -y

#Bonus : installation cxxmatrix
cd /opt/install
sudo git clone https://github.com/akinomyoga/cxxmatrix.git
#cd cxxmatrix
#make
#./cxxmatrix 'BTS CIEL' 'Saint-Eloi'

#CHANGERLE NOM D'HOTE si besoin (pour nommer les PC SUD07N-XX)
#sudo nano hostname
#sudo nano hosts

###COSMETIQUE SYSTEME####################################################
#Ajout applications dans menu, avec icones (isis, picosope, falstad)
cd /usr/share/applications
fileid="1b24Q7o7nnClMTxXTw84kCXc-mT0TAFYE"
filename="mintmenuapps.tar.gz"
html=`curl -c ./cookie -s -L "https://drive.google.com/uc?export=download&id=${fileid}"`
sudo curl -Lb ./cookie "https://drive.google.com/uc?export=download&`echo ${html}|grep -Po '(confirm=[a-zA-Z0-9\-_]+)'`&id=${fileid}" -o ${filename}
sudo tar -xzvf ${filename}

###AJOUT EXTENSION GRAMMALECTE (correcteur avancé + pour libre office) #########
cd /tmp
wget https://grammalecte.net/oxt/Grammalecte-fr-v2.1.2.oxt
sudo unopkg add --shared ./Grammalecte-fr-v2.1.2.oxt

# INFORMATIQUE : CAS PARTICULIER DE PACKET TRACER : A PLACER EN FIN DE SCRIPT 
# packet tracer : Attention,une question est posee à l'installation, ce qui la met en pause !!
# => A faire en dernier ou trouver une parade.
# !!Attention!!, il faut un compte/Login pour telecharger CISCO packet tracer puis suivre la pénible procedure sur le site officiel netacad
# ..ou récupérer directement le fichier dans les poubelles du net : (à date, les fichiers sont identiques apres comparaison diff)
sudo mkdir -p  /opt/install/packettracer && cd "$_"
sudo wget https://archive.org/download/cisco-packet-tracer-820-linux-64bit/Cisco_Packet_Tracer_820_Ubuntu_64bit.deb
echo "### VALIDATION MANUELLE REQUISE POUR LA LICENSE PACKET TRACER ###"
end_date=$(date)

sudo apt install ./Cisco*820*.deb -y
#TODO : A remplacer par filius ou autre? 
#https://perso.univ-lyon1.fr/olivier.gluck/Cours/Supports/L3IF_RE/Filius/Filius-Installation-PriseEnMains.pdf
#https://www.lernsoftware-filius.de/Herunterladen

#ELECTRONIQUE : CAS PARTICULER ISIS PROTEUS : EXECUTION UTILITAIRE DE LICENSE
echo "### VALIDATION MANUELLE REQUISE POUR LA LICENSE ISIS ###"
cd /opt/install/proteus
wine BIN/LICENCE.EXE ./LIC/licence.lxk

echo "debut du script :" $start_date
echo "fin du script   :" $end_date

echo "Ctrl+c pour quitter"
sleep infinity
