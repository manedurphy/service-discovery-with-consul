<!-- omit in toc -->
# Service Disovery & Service Mesh with Hashicorp Consul

<!-- omit in toc -->
## Purpose

- The purpose of this project is to familiarize myself with the fundamental concepts of service discover and service mesh
- For this project I will be using Hashicorp's Consul

## Security

### Gossip Encryption (Manual)

- Consul uses a [gossip protocol](https://www.consul.io/docs/architecture/gossip) for membership management and message broadcasting to the cluster over a UDP connection
- Server and client agents participate in a gossip pool for distrubuting information on healthy and unhealthy Consul nodes
- Encryption for gossip is base on a 32-byte, base64 encoded symmetric key that all agents must have in their configuration
- Generate an encryption key and copy it to all node configurations in `configs/consul/virtual_machines` for servers and clients
- Once the key have been added to each agent's config file, restart the Consul service
- See the [step-by-step](https://learn.hashicorp.com/tutorials/consul/gossip-encryption-secure?in=consul/security) for more details

```bash
# Generates a new gossip encryption key
./scripts/consul/gossip_keygen.sh

# Output
Xo4DihfBGcAcrXrazJ+OlRXy4GGRZHuRIEny2NtG+lM=
```

<details>
<summary>Gossip Config</summary>

```hcl
# Security - Gossip
encrypt = "Xo4DihfBGcAcrXrazJ+OlRXy4GGRZHuRIEny2NtG+lM="
encrypt_verify_incoming = true
encrypt_verify_outgoing = true
```

</details>

```bash
sudo systemctl restart consul
```

### RPC Encryption (Manual)

- Consul supports the verification of servers and clients over TLS
- After running the script below, the CA certificate, `consul-agent-ca.pem`, must be written to disk for all servers and clients
- The server certificates must be written to disk for their respective nodes
- Add the paths to these certificates in the config files of each agent
- Client certificates can be automatically generated and distributed with the `auto_encrypt` feature
- See the [step-by-step](https://learn.hashicorp.com/tutorials/consul/tls-encryption-secure?in=consul/security) for more details

```bash
# Generates TLS certificates in the certs directory
./scripts/consul/tls_keygen.sh
```

<details>
<summary>Server Config</summary>

```hcl
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
```

</details>

<details>
<summary>Client Config</summary>

```hcl
# Security - RPC
verify_incoming = false
verify_outgoing = true
verify_server_hostname = true
ca_file = "/opt/consul/certs/consul-agent-ca.pem"
auto_encrypt {
  tls = true
}
```

</details>

### Access Control Lists (ACLs)

- Consul uses `Access Control Lists` to manage priviledges to the UI, API, CLI, service communications, and agent communications
- `ACL policies` allows for the grouping of rules
- `ACL tokens` are created from policies, and grant access to select Consul features
- ACLs must be enabled in the config file for server and client agents
- See the [step-by-step](https://learn.hashicorp.com/tutorials/consul/access-control-setup-production?in=consul/security) for more details

<details>
<summary>ACL Config</summary>

```hcl
# Security - ACLs
acl = {
  enabled = true
  default_policy = "deny"
  enable_token_persistence = true
}
```

</details>

- With `default_policy` set to `deny`, only named resources may be accessed with the necessary tokens
- Now we can create the bootstrap token

```bash
# Creates a full-access token
./scripts/consul/acl_bootstrap.sh

# Output
AccessorID:       61c922fa-ec85-32c1-0c3d-fa891ab8ec67
SecretID:         68f6dcc8-ce9b-5259-3041-d5ef710acd94
Description:      Bootstrap Token (Global Management)
Local:            false
Create Time:      2021-12-24 02:43:28.638440363 +0000 UTC
Policies:
   00000000-0000-0000-0000-000000000001 - global-management

# Set token in environment
export CONSUL_HTTP_TOKEN="68f6dcc8-ce9b-5259-3041-d5ef710acd94"

# Lists all tokens in cluster
consul acl token list

# Output
AccessorID:       61c922fa-ec85-32c1-0c3d-fa891ab8ec67
SecretID:         68f6dcc8-ce9b-5259-3041-d5ef710acd94
Description:      Bootstrap Token (Global Management)
Local:            false
Create Time:      2021-12-24 02:43:28.638440363 +0000 UTC
Legacy:           false
Policies:
   00000000-0000-0000-0000-000000000001 - global-management

AccessorID:       00000000-0000-0000-0000-000000000002
SecretID:         anonymous
Description:      Anonymous Token
Local:            false
Create Time:      2021-12-24 02:42:42.705070791 +0000 UTC
Legacy:           false
```

- We can create policies for individual agents that grant them write privileges for node-related actions
- These privileges include registration, health checks, and modification to the configuration file
- Apply the following agent policies for each node in the cluster


#### The Old Way
```bash
# Apply agent policies for servers and clients
./scripts/consul/agent_policies.sh

# Output
ID:           843141db-f3ce-83ef-d805-71a8f0ad7510
Name:         consul-server-1
Description:
Datacenters:
Rules:
node "consul-server-1" {
        policy = "write"
}
service_prefix "" {
        policy = "read"
}

ID:           f32e913e-87fc-b92d-4307-d2d7ea885ae0
Name:         consul-server-2
Description:
Datacenters:
Rules:
node "consul-server-2" {
        policy = "write"
}
service_prefix "" {
        policy = "read"
}
ID:           65af9449-0aa8-ab94-fca9-896a8c34642c
Name:         consul-client-1
Description:
Datacenters:
Rules:
node "consul-client-1" {
        policy = "write"
}
service_prefix "" {
        policy = "read"
}

ID:           88a70c4a-f25a-fb9a-88d1-e47ebfc9e451
Name:         consul-client-2
Description:
Datacenters:
Rules:
node "consul-client-2" {
        policy = "write"
}
service_prefix "" {
        policy = "read"
}
```

- With the agent polcies in place, we can create tokens for each agent

```bash
# Creates tokens for each agent
./scripts/consul/agent_tokens_old.sh
```

#### The New Way

- We can create tokens and agent policies with the `node-identity` flag

```bash
# Create agent policies and tokens
./scripts/consul/agent_tokens.sh

# Output
AccessorID:       73f07f47-66ca-7b51-535f-8a8ca1b2d443
SecretID:         9ed687c1-4ec6-0fd5-0cf2-fee83dbb2999
Description:      consul-server-1 agent token
Local:            false
Create Time:      2021-12-24 03:35:25.306541424 +0000 UTC
Node Identities:
   consul-server-1 (Datacenter: us-west-1)

AccessorID:       fd556f18-68c9-5787-478d-3cd00f56429f
SecretID:         7ec6aadd-8f2b-a94e-b0ae-3a7b4baa75ec
Description:      consul-server-2 agent token
Local:            false
Create Time:      2021-12-24 03:35:25.681266128 +0000 UTC
Node Identities:
   consul-server-2 (Datacenter: us-west-1)

AccessorID:       1cb81dc5-6f2d-1a61-9e40-fbd68f9b8229
SecretID:         ef3dcead-5a47-b773-c49c-181641004e97
Description:      consul-client-1 agent token
Local:            false
Create Time:      2021-12-24 03:35:25.934209573 +0000 UTC
Node Identities:
   consul-client-1 (Datacenter: us-west-1)

AccessorID:       cd6e8fb5-1f40-444b-df95-41e4e41e6791
SecretID:         2db6b675-82ca-9ac5-bbb2-8759292c2883
Description:      consul-client-2 agent token
Local:            false
Create Time:      2021-12-24 03:35:26.270583119 +0000 UTC
Node Identities:
```

- Add each of these tokens to their respective config files as shown
- For client configs, we should set the defaut token as well since it is needed for making request for the Consul servers
- In order for the `web` service to make a request to the `api` service, it needs to make a request to the DNS server to resolve `api.service.consul`

<details>
<summary>Server Config</summary>

```hcl
acl {
  enabled = true
  default_policy = "deny"
  enable_token_persistence = true
  enable_key_list_policy = true
  tokens {
    agent = "9ed687c1-4ec6-0fd5-0cf2-fee83dbb2999"
  }
}
```

</details>

<details>
<summary>Client Config</summary>

```hcl
acl {
  enabled = true
  default_policy = "deny"
  enable_token_persistence = true
  tokens {
    default = "2db6b675-82ca-9ac5-bbb2-8759292c2883"
    agent = "2db6b675-82ca-9ac5-bbb2-8759292c2883"
  }
}
```

</details>

- We now need to create tokens for each service, and add them to the configurations in `configs/consul/services`

```bash
# Create service tokens
./scripts/consul/service_tokens.sh

# Output
AccessorID:       bacd35d9-237a-f5ab-6b5e-1b3d3748e293
SecretID:         800818ce-ccb5-11ba-4cbc-b20dca15dac8
Description:      Token for API
Local:            false
Create Time:      2021-12-24 03:59:57.326227863 +0000 UTC
Service Identities:
   api (Datacenters: all)

AccessorID:       da93de2a-ac40-d9f9-d0ce-a8252f57127d
SecretID:         48b954b1-0ac7-8f93-e22d-cbb0f3686bc2
Description:      Token for WEB
Local:            false
Create Time:      2021-12-24 03:59:57.478195237 +0000 UTC
Service Identities:
   web (Datacenters: all)
```

<details>
<summary>API Config</summary>

```hcl
service {
  name = "api"
  port = 8080
  tags = ["fake-service-api"]
  token = "800818ce-ccb5-11ba-4cbc-b20dca15dac8"

  checks = [
    {
      id = "api_check"
      name = "Check API health 8080"
      service_id = "api"
      http = "http://localhost:8080/health"
      method = "GET"
      interval = "10s"
      timeout = "1s"
      success_before_passing = 3
      failures_before_critical = 3
    }
  ]
}
```

</details>

<details>
<summary>WEB Config</summary>

```hcl
service {
  name = "web"
  port = 8080
  tags = ["fake-service-web"]
  token = "48b954b1-0ac7-8f93-e22d-cbb0f3686bc2"

  checks = [
    {
      id = "web_check"
      name = "Check WEB health 8080"
      service_id = "web"
      http = "http://localhost:8080/health"
      method = "GET"
      interval = "10s"
      timeout = "1s"
      success_before_passing = 3
      failures_before_critical = 3
    }
  ]
}
```

</details>

### Service Mesh

- For the nodes that are running our serivices, we need to install Envoy to run our sidecar proxies
- Download a specific version of Envoy with [func-e](https://func-e.io/)
- Compatible versions of Envoy are listed [here](https://www.consul.io/docs/connect/proxies/envoy#supported-versions)

```bash
# Install v1.18.4 of Envoy
func-e use 1.18.4

# See directory
ls ~/.func-e
```

- When creating a service mesh, all communication between services is done through the `localhost` of the node that the service is running on, eliminating the need for DNS resolution

<details>
<summary>Server Config</summary>

- For the server, we need to open the gRPC port as well as set a global default config for the proxy

```hcl
# Set the ports
ports {
  grpc = 8502
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
```

</details>

<details>
<summary>Client Config</summary>

- For the server, we need to open the gRPC port

```hcl
# Set the ports
ports {
  grpc = 8502
}
```

</details>

<details>
<summary>API Config</summary>

- Add the connect nested object in the service config

```hcl
service {
  name = "api"
  port = 8080
  tags = ["fake-service-api"]
  token = "800818ce-ccb5-11ba-4cbc-b20dca15dac8"

  connect {
    sidecar_service{
      port = 20000
      check {
        name = "API Connect Envoy Sidecar"
        tcp = "127.0.0.1:20000"
        interval = "10s"
        timeout = "1s"
      }
    }
  }

  checks = [
    {
      id = "api_check"
      name = "Check API health 8080"
      service_id = "api"
      http = "http://localhost:8080/health"
      method = "GET"
      interval = "10s"
      timeout = "1s"
      success_before_passing = 3
      failures_before_critical = 3
    }
  ]
}
```

</details>

<details>
<summary>WEB Config</summary>

```hcl
service {
	name = "web"
	port = 8080
	tags = ["fake-service-web"]
  token = "48b954b1-0ac7-8f93-e22d-cbb0f3686bc2"

  connect {
    sidecar_service{
      port = 20000
      check {
        name = "API Connect Envoy Sidecar"
        tcp = "127.0.0.1:20000"
        interval = "10s"
        timeout = "1s"
      }
      proxy {
        upstreams = [
          {
            destination_name = "api"
            local_bind_port = 8081
          }
        ]
      }
    }
  }

	checks = [
    {
      id = "web_check"
      name = "Check WEB health 8080"
      service_id = "web"
      http = "http://localhost:8080/health"
      method = "GET"
      interval = "10s"
      timeout = "1s"
      success_before_passing = 3
      failures_before_critical = 3
    }
  ]
}
```

</details>

```bash
# Show envoy JSON config file
consul connect envoy -sidecar-for="api" token="800818ce-ccb5-11ba-4cbc-b20dca15dac8" -bootstrap

# Run the Envoy proxies
consul connect envoy -sidecar-for="api" token="800818ce-ccb5-11ba-4cbc-b20dca15dac8"
consul connect envoy -sidecar-for="web" token="48b954b1-0ac7-8f93-e22d-cbb0f3686bc2"

# Create an intention to permit communication from WEB to API
consul intention create -allow web api
```