# The region of the Consul cluster
datacenter = "us-west-1"

# The name of the node
node_name = "consul-client-1"

# The data directory stores the Consul data
data_dir = "/opt/consul"

# The address to which Consul will bind client interfaces
client_addr = "0.0.0.0"

# Sets the instance to run in server mode
server = false

# The address to advertise to other nodes in the Consul cluster
advertise_addr = "{{ GetInterfaceIP `ens5` }}"

# Set the ports
ports {
  grpc = 8502
}

################################################## MANUAL SECURITY ##################################################

# The address of the node to join on start up
retry_join = ["172.31.107.196", "172.31.105.153"]

# Security - Gossip
encrypt = "Xo4DihfBGcAcrXrazJ+OlRXy4GGRZHuRIEny2NtG+lM="
encrypt_verify_incoming = true
encrypt_verify_outgoing = true

# Security - RPC
verify_incoming = false
verify_outgoing = true
verify_server_hostname = true
ca_file = "/opt/consul/certs/consul-agent-ca.pem"
auto_encrypt {
  tls = true
}

# Security - ACLs
acl {
  enabled = true
  default_policy = "deny"
  enable_token_persistence = true
  tokens {
	  default = "1538f24b-a2cb-7078-11dc-c9de514a6b28"
	  agent = "1538f24b-a2cb-7078-11dc-c9de514a6b28"
  }
}

################################################## MANUAL SECURITY ##################################################

################################################ SECURITY AUTOCONFIG ################################################

# Security - RPC
# verify_incoming = false
# verify_outgoing = true
# verify_server_hostname = true
# ca_file = "/opt/consul/certs/consul-agent-ca.pem"

# Auto Config - Client
# auto_config {
#   enabled = true
#   intro_token_file = "/opt/consul/tokens/jwt"
#   server_addresses = [
#     "172.31.107.196",
#     "172.31.105.153"
#   ]
# }

################################################ SECURITY AUTOCONFIG ################################################
