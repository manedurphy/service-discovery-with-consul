#! /bin/bash

# Create a policy for DNS
consul acl policy create \
	-description "Policy for resolving DNS requests" \
	-datacenter "us-west-1" \
	-name "dns-request-policy" \
	-rules @configs/consul/acl/dns_request_policy.hcl

# Update the existing agent token for consul-client-2 so that the DNS server can make a request to Consul
consul acl token update \
	-id $(consul acl token list | grep consul-client-2 -B 2 | grep AccessorID | awk '{ print $2 }') \
	-policy-name "dns-request-policy" \
	-merge-node-identities