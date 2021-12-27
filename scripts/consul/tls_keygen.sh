#! /bin/bash

# Enter certs directory
cd certs

# Initialize the Certificate Authority that will sign all certificates 
consul tls ca create

# Create the server certificates for both servers
consul tls cert create -server -dc "us-west-1"
consul tls cert create -server -dc "us-west-1"
