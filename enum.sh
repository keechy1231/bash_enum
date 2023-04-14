#!/bin/bash

Host=$1
File=$2

if [[ -z "$1" || -z "$2" ]]; then
    echo "Error: Host and Output File required." 
    echo "Example usage ./enum.sh 10.10.10.10 scans"
    exit 1
else
    Host="$1"
    File="$2"
    # continue with the script using the Host and File variables
fi



if [ ! -d "enum" ];then
        mkdir enum
else
    echo "[+] file enum already exists"
fi

echo "[+] Nmap scan started..."
#Run the nmap scan for the Host and save it to a File
nmap $Host -oN enum/$File > /dev/null

# Take results and make the file to show only port numbers that are open
cat enum/$File| sed -e '1,5d' -e 's/[^0-9 ]//g' -e '$d' | tr -d ' ' > enum/open-ports.nmap 
rm enum/$File

ports=""
while read -r line; do
    ports="$ports,$line"
done < enum/open-ports.nmap
ports="${ports:1}" # remove leading comma
last_char="${ports: -1}"
if [[ "$last_char" == "," ]]; then
    ports="${ports::-1}" # remove trailing comma
fi

echo "[+] Open ports found on the target "$ports 

echo "[+] Starting a full nmap version scan..."

nmap $Host -sV -sC -oN enum/service-scan.nmap -p $ports >/dev/null

#cat enum/service-scan.nmap



if [[ "$ports" == *"80"* ]]; then
    web_ports="80"

    echo "[+] Starting gobuster Scan on "$web_ports
    gobuster dir -u http://$Host:$web_ports -w /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt -o enum/gobuster-80.txt >/dev/null
fi

if [[ "$ports" == *"8000"* ]]; then
    web_ports="8000"
    echo " "
    echo "[+] Starting gobuster Scan on "$web_ports
    gobuster dir -u http://$Host:$web_ports -w /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt -o enum/gobuster-8000 >/dev/null
fi

if [[ "$ports" == *"8080"* ]]; then
    web_ports="8080"
    echo " " 
    echo "[+] Starting gobuster Scan on "$web_ports
    gobuster dir -u http://$Host:$web_ports -w /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt -o enum/gobuster-8080 >/dev/null
fi


if [[ "$ports" == *"443"* ]]; then
    web_ports="443"
    echo " " 
    echo "[+] Starting gobuster Scan on "$web_ports
    gobuster dir -u https://$Host:$web_ports -w /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt -o enum/gobuster-8080 >/dev/null
fi

if [[ "$ports" == *"445"* ]]; then
    smb_port="445"
    echo " "
    echo "[+] SMB discoverd, enumerating with guest account and no password..."
    smbclient -L \\\\$Host -U "guest" -P " "

fi

echo " "


rm enum/open-ports.nmap
echo "[=] Scans are now finished and saved in enum/"$File


