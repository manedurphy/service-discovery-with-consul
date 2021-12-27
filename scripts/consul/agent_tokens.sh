#! /bin/bash

# Create agent policy and token for consul-server-1
consul acl token create -description "consul-server-1 agent token" -node-identity "consul-server-1:us-west-1"

# Create agent policy and token for consul-server-2
consul acl token create -description "consul-server-2 agent token" -node-identity "consul-server-2:us-west-1"

# Create agent policy and token for consul-client-1
consul acl token create -description "consul-client-1 agent token" -node-identity "consul-client-1:us-west-1"

# Create agent policy and token for consul-client-2
consul acl token create -description "consul-client-2 agent token" -node-identity "consul-client-2:us-west-1"
