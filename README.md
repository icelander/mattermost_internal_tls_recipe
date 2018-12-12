# Mattermost Recipe - Adding TLS to Internal Connections

## Problem

You are using Mattermost behind an Nginx proxy that handles external TLS and load balancing, but need to secure the communication between the Mattermost server and the proxy.

## Solution

1. Change the Nginx configuration to so that every `proxy_pass` is pointing to `https://` and not `http://`
2. Upload the certificate and key file you would like to use to secure the connections
3. Change your Mattermost config by;
	- Setting `ServiceSettings` > `ConnectionSecurity` to `TLS`
	- Setting `ServiceSettings` > `TLSCertFile` to the path of the certificate file
	- Setting `ServiceSettings` > `TLSKeyFile` to the path of the key file
4. Restart Mattermost `service mattermost restart`

## Discussion

This is the minimum possible configuration change to encrypt connections between the Mattermost server and the proxy server. Even if Mattermost is running inside of your firewall, it can be beneficial to encrypt communication between Mattermost and the proxy server to prevent eavesdropping from inside your network. Also, if your internal users are connecting to the Mattermost server directly, they can get the benefits of TLS security on port 8065.

Because TLS is added on top of TCP/IP connections, you can use any port to serve encrypted connections, not just 443. This is helpful because you don't have to run Mattermost with escalated privileges to have encrypted and verified connections.