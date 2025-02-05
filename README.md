# Setup VPN Server (OpenVPN) in Linux Ubuntu

###### Very simple steps to create your own VPN Server and use it with Multiple Clients.

###### This tutorial works great on Ubuntu 20.04 LTS

###### Commands:
###### First installation of Needed Libraries and Programs

> $ sudo apt update

> $ sudo apt -y install openvpn easy-rsa unzip firewalld

###### Extracting then Copying and editing openvpn config file

> $ gunzip /usr/share/doc/openvpn/examples/sample-config-files/server.conf.gz

> $ cp /usr/share/doc/openvpn/examples/sample-config-files/server.conf /etc/openvpn/

> $ nano /etc/openvpn/server.conf

###### Using Ctrl+W search short key: look for these and uncomment them (by removing ; semicolon)
###### #uncomment bellow
> topology subnet

> push "dhcp-option DNS 208.67.222.222" # change dns to whatever you want (e.g. 8.8.8.8)

> push "dhcp-option DNS 208.67.220.220" # change dns to whatever you want (e.g. 1.1.1.1)

> user nobody

> group nogroup

###### #comment this
> ;tls-auth ta.key 0

###### #optional uncomment # if you want your clients to be able to see each other, useful for offices or companies
> client-to-client

###### Then Ctrl+X to Exit nano, Press Y to save then enter to overwrite
###### Now

> $ cd /usr/share/easy-rsa/

> $ ./easyrsa init-pki

> $ ./easyrsa build-ca nopass

> // Leave blank, press enter

> $ ./easyrsa gen-req server nopass

> // Leave blank, press enter

> $ ./easyrsa gen-req client nopass

> // Leave blank, press enter

> $ ./easyrsa sign-req server server nopass

> yes

> $ ./easyrsa sign-req client client nopass

> yes

> $ ./easyrsa gen-dh

###### Then you wait for awhile, depends on the Computer Hardware Specs
> $ cd pki

> $ pwd

###### copy the path to use it afterwards: /usr/share/easy-rsa/pki
> $ nano /etc/openvpn/server.conf

###### Using Ctrl+W search short key: look for these and change them:
> ca ca.crt

> cert server.crt

> key server.key


###### Change them to:
> ca /usr/share/easy-rsa/pki/ca.crt

> cert /usr/share/easy-rsa/pki/issued/server.crt

> key /usr/share/easy-rsa/pki/private/server.key


###### Using Ctrl+W search short key: look for "dh20" and change:
> dh dh2048.pem

to

> dh /usr/share/easy-rsa/pki/dh.pem

###### Then Ctrl+X to Exit nano, Press Y to save then enter to overwrite

###### Then we enable ip forwarding
> $ sysctl -w net.ipv4.ip_forward=1

> $ sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/g' /etc/sysctl.conf

###### We install firewall if not already installed, then we configure it
> $ systemctl status firewalld

> $ firewall-cmd --set-default=trusted

> $ firewall-cmd --permanent --zone=trusted --add-masquerade

> $ firewall-cmd --permanent --add-service openvpn

> $ firewall-cmd --reload

> $ firewall-cmd --list-all

###### We start openvpn
> $ systemctl start openvpn@server

> $ systemctl enable openvpn@server

> $ systemctl status openvpn@server

###### Then to create Clients
# Create and Setup Clients
###### Use the shell script file i wrote to generate clients keys very easily
###### Download it from this github repo: OpenVPNClientsKeysGenerator.sh
###### Download it with wget and unzip
> $ cd ~

> $ wget https://github.com/TarikSeyceri/Setup-OpenVPN-Server-in-Linux-Ubuntu.sh/archive/refs/heads/main.zip

> $ unzip -qq main.zip && rm -rf main.zip

> $ cd Setup-OpenVPN-Server-in-Linux-Ubuntu.sh-main

> $ nano OpenVPNClientsKeysGenerator.sh
###### Modify 'server_static_ip_address' variable to work with your Server's IP Address

###### To authorise the file to be executed
> $ sed -i -e 's/\r$//' OpenVPNClientsKeysGenerator.sh

> $ sudo chmod +x OpenVPNClientsKeysGenerator.sh

###### Then you can run it with
> $ ./OpenVPNClientsKeysGenerator.sh

###### Follow the instructions in the Script
###### It will only ask for the client username, make sure it is unique
###### a folder has been created with the client username you wrote in the path: /root/Documents/, provides THE_CLIENT_USERNAME.ovpn and the needed keys and certs to be used for VPN Client Programs, if you want to use OpenVPN Client (Which is recommended), for Windows download it from here: 
> https://openvpn.net/community-downloads/
###### For Other OS OpenVPN or Other VPN Client Programs ( Google it :) )

# Setup OpenVPN Client in Windows
###### Download the THE_CLIENT_USERNAME.ovpn file from the server using SFTP (E.g. using WinSCP) or SSH and send it to the Client Computer.

###### Download the OpenVPN Client from: https://openvpn.net/community-downloads/ and then double click install Next — Next — Next

###### From Desktop => OpenVPN GUI => Double Click to run it => Then => From Taskbar => System Tray => Right click on OpenVPN icon => Import => Import file...

###### Then right click again on OpenVPN icon => connect. Done.

###### Enjoy!

