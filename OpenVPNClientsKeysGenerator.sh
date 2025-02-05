#!/bin/bash

#Setting constants
server_static_ip_address="X.X.X.X" #Host Server IP Address
path_to_root_document="/root/Documents"
path_to_rsa="/usr/share/easy-rsa"
server_openvpn_port="1194"
server_openvpn_protocol="udp"

opvn_data="
client\n
proto $server_openvpn_protocol\n
remote $server_static_ip_address\n
port $server_openvpn_port\n
dev tun\n
nobind\n
persist-key\n
persist-tun\n
resolv-retry infinite\n
remote-cert-tls server\n
cipher AES-256-CBC\n
route-metric 1\n
redirect-gateway def1\n
\n
";

# Done in 2019 August
sudo mkdir /root 2> /dev/null
sudo mkdir /root/Documents 2> /dev/null
echo ""
echo "---------------------------------"
echo ""
echo "Welcome to OpenVPN Clients Keys Generator (By Tarik Seyceri)"
echo ""
echo "Enter client device name (Must be Unique)"
read client_device_name
echo ""

#escape spaces
printf -v client_device_name '%s' $client_device_name

crtFile="$path_to_rsa/pki/issued/$client_device_name.crt"
keyFile="$path_to_rsa/pki/private/$client_device_name.key"

if [ -f $crtFile -a -f $keyFile  ]; then
	echo "This Client $client_device_name Key files already exist!"
else 
	cd $path_to_rsa
	if [ -d $path_to_rsa ]; then
		echo -en "\n" | ./easyrsa gen-req $client_device_name nopass
		echo -en "yes" |./easyrsa sign-req client $client_device_name nopass

		caFile="$path_to_rsa/pki/ca.crt"

		if [ -f $caFile -a -f $crtFile -a -f $keyFile  ]; then
			if [ -d $path_to_root_document ]; then
				mkdir /root/Documents/$client_device_name
				mkdir /root/Documents/$client_device_name/keys

				ovpn_config_file=$path_to_root_document/$client_device_name/$client_device_name.ovpn
				echo -e $opvn_data >> $ovpn_config_file
				echo -e "<ca>" >> $ovpn_config_file
				cat "$caFile" >> $ovpn_config_file
				echo -e "</ca>" >> $ovpn_config_file

				echo -e "<cert>" >> $ovpn_config_file
				cat "$crtFile" >> $ovpn_config_file
				echo -e "</cert>" >> $ovpn_config_file

				echo -e "<key>" >> $ovpn_config_file
				cat "$keyFile" >> $ovpn_config_file
				echo -e "</key>" >> $ovpn_config_file

				cp $path_to_rsa/pki/ca.crt /root/Documents/$client_device_name/keys/
				mv $path_to_rsa/pki/issued/$client_device_name.crt /root/Documents/$client_device_name/keys/$client_device_name.crt
				mv $path_to_rsa/pki/private/$client_device_name.key /root/Documents/$client_device_name/keys/$client_device_name.key
			else 
				echo "$path_to_root_document does not exist"
			fi
		else
			echo "Error happened, files not generated!"
		fi
	fi
fi

echo "---------------------------------"
echo "Done!"
echo ""
echo "Check $path_to_root_document for the keys"
echo ""