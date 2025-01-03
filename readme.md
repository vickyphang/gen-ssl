## Create Your Own Certificate Authority and Sign Server Certificates

### Overview

This repository provides a script to automate the creation of a local Certificate Authority (CA) and the signing of server certificates. With this script, you can easily establish a private PKI (Public Key Infrastructure) for your network, ensuring secure communication between your servers and clients.

### Usage:
1. Create a CA: `./create_ca.sh init`
2. Generate a server certificate: `./create_ca.sh sign <domain>`