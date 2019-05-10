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
docker run -d --name='Portainer' --restart always -p 9000:9000 -v /var/run/docker.sock:/var/run/docker.sock -v /docker/portainer:/data portainer/portainer 
echo "Deploying TinyProxy"
docker run -d --name='Tinyproxy' --restart always -v /docker/TinyProxy:/etc/tinyproxy -p 443:8888 dannydirect/tinyproxy:latest ANY

echo "All done, enjoy!"
