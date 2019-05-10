### Create Nescessary Folders
echo "Creating nescessary folders"
mkdir /docker
mkdir /docker/Portainer
mkdir /docker/TinyProxy
mkdir /docker/OpenVPN
mkdir /docker/OpenVPNProfiles

### Download tinyproxy.conf file that allows OpenVPN connectivity
echo "Downloading tinyproxy.conf configuration file"
curl -o /docker/TinyProxy/tinyproxy.conf https://raw.githubusercontent.com/dVerschaeve/azure_vpn_gateway/master/tinyproxy.conf

### Install Docker
echo "Installing Docker"
apt-get -y install apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"
apt-get update
apt-get -y install docker-ce

### Deploy the different containers
echo "Deploying Portainer"
docker run -d --Name='Portainer' -p 9000:9000 -v /var/run/docker.sock:/var/run/docker.sock -v /docker/portainer:/data portainer/portainer --restart always
echo "Deploying TinyProxy"
docker run -d --name='Tinyproxy' -v /docker/tinyproxy/tinyproxy.conf:/etc/tinyproxy/tinyproxy.conf -p 443:8888 --restart always dannydirect/tinyproxy:latest ANY

echo "Deploying OpenVPN"
read -p "OpenVPN URL: "  OpenVPNURL
echo "OpenVPN server URL: $OpenVPNURL"
docker run -v /docker/openvpn:/etc/openvpn --log-driver=none --rm kylemanna/openvpn ovpn_genconfig -N -b -d -D -u tcp://$OpenVPNURL -p "route 10.0.0.0 255.255.255.0"
docker run -v /docker/openvpn:/etc/openvpn --log-driver=none --rm -it kylemanna/openvpn ovpn_initpki
docker run -v --name='OpenVPN' /docker/openvpn:/etc/openvpn -d -p 1194:1194/tcp --restart always --cap-add=NET_ADMIN kylemanna/openvpn

read -p "OpenVPN Profile Name: " OpenVPNProfile
docker run -v /docker/openvpn:/etc/openvpn --log-driver=none --rm -it kylemanna/openvpn easyrsa build-client-full $OpenVPNProfile nopass
docker run -v /docker/openvpn:/etc/openvpn --log-driver=none --rm kylemanna/openvpn ovpn_getclient $OpenVPNProfile > /docker/OpenVPNProfiles/$OpenVPNProfile.ovpn

echo "All done, enjoy!"
