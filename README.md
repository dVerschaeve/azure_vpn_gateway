# azure_vpn_gateway
Azure VPN Gateway for lab deployments

```
wget -O - https://raw.githubusercontent.com/dVerschaeve/azure_vpn_gateway/master/build.sh | sudo bash
sudo usermod -a -G docker $USER


docker run -v /docker/OpenVPN:/etc/openvpn --log-driver=none --rm kylemanna/openvpn ovpn_genconfig -N -b -d -D -u tcp://<%HOSTNAME%> -p "route <%AzureVirtualNetworkSubnet%> 255.255.255.0"
docker run -v /docker/OpenVPN:/etc/openvpn --log-driver=none --rm -it kylemanna/openvpn ovpn_initpki
docker run --name='OpenVPN' -v /docker/OpenVPN:/etc/openvpn -d -p 1194:1194/tcp --restart always --cap-add=NET_ADMIN kylemanna/openvpn

docker run -v /docker/OpenVPN:/etc/openvpn --log-driver=none --rm -it kylemanna/openvpn easyrsa build-client-full <%ProfileName%> nopass
docker run -v /docker/OpenVPN:/etc/openvpn --log-driver=none --rm kylemanna/openvpn ovpn_getclient <%ProfileName%> > ~/<%ProfileName%>.ovpn
```
