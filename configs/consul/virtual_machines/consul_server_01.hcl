# The region of the Consul cluster
datacenter = "us-west-1"

# The name of the node
node_name = "consul-server-1"

# The data directory stores the Consul data
data_dir = "/opt/consul"

# The UI configuration
ui_config {
	enabled = true
}

# Enable Connect
connect {
	enabled = true
}

# Set the ports
ports {
	http = 3000
  grpc = 8502
}

# Merges service config default with service instance
enable_central_service_config = true

# The address to which Consul will bind client interfaces
client_addr = "0.0.0.0"

# Sets the instance to run in server mode
server = true

# Address for internal communication within the Consul cluster
bind_addr = "0.0.0.0"

# The address to advertise to other nodes in the Consul cluster
advertise_addr = "{{ GetInterfaceIP `ens5` }}"

# The number of expected servers
bootstrap_expect = 2

# The address of the node to join on start up
retry_join = ["172.31.105.153"]

# Telemetry
telemetry {
	prometheus_retention_time = "60s"
	disable_hostname = true
}

# Centralized config options
config_entries {
  bootstrap = [
    {
      kind = "proxy-defaults"
      name = "global"
      config {
        protocol = "http"
      }
    }
  ]
}

################################################## MANUAL SECURITY ##################################################

# Security - Gossip
encrypt = "Xo4DihfBGcAcrXrazJ+OlRXy4GGRZHuRIEny2NtG+lM="
encrypt_verify_incoming = true
encrypt_verify_outgoing = true

# Security - RPC
verify_incoming = true
verify_outgoing = true
verify_server_hostname = true
ca_file = "/opt/consul/certs/consul-agent-ca.pem"
cert_file = "/opt/consul/certs/us-west-1-server-consul-0.pem"
key_file = "/opt/consul/certs/us-west-1-server-consul-0-key.pem"
auto_encrypt {
  allow_tls = true
}

# Security - ACLs
acl {
  enabled = true
  default_policy = "deny"
  enable_token_persistence = true
  enable_key_list_policy = true
  tokens {
	  agent = "94fe2223-6e05-9324-a471-7fdda5e540a3"
  }
}

################################################## MANUAL SECURITY ##################################################

################################################ SECURITY AUTOCONFIG ################################################

# Security - Gossip
# encrypt = "Xo4DihfBGcAcrXrazJ+OlRXy4GGRZHuRIEny2NtG+lM="
# encrypt_verify_incoming = true
# encrypt_verify_outgoing = true

# Security - RPC
# verify_incoming = true
# verify_outgoing = true
# verify_server_hostname = true
# ca_file = "/opt/consul/certs/consul-agent-ca.pem"
# cert_file = "/opt/consul/certs/us-west-1-server-consul-0.pem"
# key_file = "/opt/consul/certs/us-west-1-server-consul-0-key.pem"

# Security - ACLs
# acl {
#   enabled = true
#   default_policy = "deny"
#   enable_token_persistence = true
#   enable_key_list_policy = true
#   tokens {
# 	  agent = "94fe2223-6e05-9324-a471-7fdda5e540a3"
#   }
# }

# Auto Config - Server
# auto_config {
#   authorization {
#     enabled = true
#     static {
#       bound_audiences = ["us-west-1"]
#       bound_issuer = "http://172.31.107.196:8000/v1/identity/oidc"
#       oidc_discovery_url = "http://172.31.107.196:8000/v1/identity/oidc"
#       claim_mappings {
#         "/consul/hostname" = "node_name"
#       }
#       claim_assertions = [
#         "value.node_name == \"${node}\""
#       ]
#     }
#   }
# }

################################################ SECURITY AUTOCONFIG ################################################
