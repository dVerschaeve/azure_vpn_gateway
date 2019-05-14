 # Azure OpenVPN Gateway
Azure OpenVPN Gateway for lab deployments

As a consultant, I often work on customer guest WiFi networks which are often blocking any kind of traffic besides HTTP and HTTPS. This prevents me from executing validations against my lab environment running on Azure Virtual Machines and required a solution. I always wanted to get to know Docker and found this a suitable project to start to know the technology.

The idea was to have an OpenVPN server running on Azure VM that provides you VPN connectivity into my Azure lab Environment. If I would achieve this, this would avoid me using a public IP address for each single VM or make use of a VPN gateway (which costs around $26.78 a month acording to the calculator). Next to this, I would not need to expose each machine towards the internet on TCP port 3383.

The idea resulted into the following Azure VM running Docker with the following containers:
  - Portainer: used to manage the different Docker containers
  - TinyProxy: used to proxy the OpenVPN connection from TCP/443 towards TCP/1194 when my customer is blocking port TCP/1194 on their guest WiFi
  - OpenVPN: used for VPN connectivity

![Alt text](images/Image.png?raw=true "Overview")

Azure VM Requirements:
  - VM Size: Standard B1s (US$ 8,76)
  - VM OS: Ubuntu Server 18.04 LTS
  - VM Inbound Connectivity:
    - TCP/443
    - TCP/1194
    - TCP/9000
  - A DNS name

```
# Install Docker and deploy Portainer and TinyProxy
wget -O - https://raw.githubusercontent.com/dVerschaeve/azure_vpn_gateway/master/build.sh | sudo bash
sudo usermod -a -G docker $USER

#Install OpenVPN server
docker run -v /docker/OpenVPN:/etc/openvpn --log-driver=none --rm kylemanna/openvpn ovpn_genconfig -N -b -d -D -u tcp://<%HOSTNAME%> -p "route <%AzureVirtualNetworkSubnet%> 255.255.255.0"

#Configure OpenVPN PKI
docker run -v /docker/OpenVPN:/etc/openvpn --log-driver=none --rm -it kylemanna/openvpn ovpn_initpki

#Start OpenVPN Server
docker run --name='OpenVPN' -v /docker/OpenVPN:/etc/openvpn -d -p 1194:1194/tcp --restart always --cap-add=NET_ADMIN kylemanna/openvpn

#Generate Client Connection files and store them in your home directory
docker run -v /docker/OpenVPN:/etc/openvpn --log-driver=none --rm -it kylemanna/openvpn easyrsa build-client-full <%ProfileName%> nopass
docker run -v /docker/OpenVPN:/etc/openvpn --log-driver=none --rm kylemanna/openvpn ovpn_getclient <%ProfileName%> > ~/<%ProfileName%>.ovpn
```

When you imported the OpenVPN client configuration file and want to make use of the TinyProxy component, add
```
http-proxy <%HostName%> 443
```
Enjoy

Used Sources:
- OpenVPN Docker: https://github.com/kylemanna/docker-openvpn
- TinyProxy Docker:https://github.com/monokal/docker-tinyproxy
