### Auto Configuration

- Instead of configuring each security aspect individually as shown above for Gossip, TLS, and ACLs, we can use `auto_config`
- The following steps will give the same results as each from before
- In order for Consul clients to request confiurations from the Consul servers, they will need to authorize with a JWT
- We will generate the JWT needed for `auto_config` with a Hashicorp Vault server
- See the [step-by-step](https://learn.hashicorp.com/tutorials/consul/docker-compose-auto-config?in=consul/security) for more details

```bash
# Intialize Vault
vault operator init

# Output
Unseal Key 1: SdJV3KGl23XFPoyUIZoyQ/EBjok4Y4IfLYhm3BFRjXf0
Unseal Key 2: U1uU/5+Z3JHUY8MpqydRHG2n2uEq6y0SySawYk6S1lPb
Unseal Key 3: YDxHd552F/FUD0DKdl5ZpIiutx9VP+7xPv2NtSA+0xV1
Unseal Key 4: W4h7cAhWDO9inNxx0l9AJH42j0M7tIKZbw3ACSCyKem6
Unseal Key 5: fD/z/Y87DDqtmgLSr3w+gvxeoOEKwKUN98mLMsW6h93p

Initial Root Token: s.OwE6EIToqtTSSkP4YcfjNEVZ

Vault initialized with 5 key shares and a key threshold of 3. Please securely
distribute the key shares printed above. When the Vault is re-sealed,
restarted, or stopped, you must supply at least 3 of these keys to unseal it
before it can start servicing requests.

Vault does not store the generated master key. Without at least 3 keys to
reconstruct the master key, Vault will remain permanently sealed!

It is possible to generate new unseal keys, provided you have a quorum of
existing unseal keys shares. See "vault operator rekey" for more information.

# Unseal Vault 3x
vault operator unseal

# Confirm unseal
vault status

# Output
Key             Value
---             -----
Seal Type       shamir
Initialized     true
Sealed          false
Total Shares    5
Threshold       3
Version         1.9.2
Storage Type    file
Cluster Name    vault-cluster-58b0471c
Cluster ID      b65e8a95-a587-f03b-55df-8c1a09e88b35
HA Enabled      false

# Set the issuer URL
curl -X POST -H "X-Vault-Token:$VAULT_TOKEN" --data @configs/vault/issuer.json $VAULT_ADDR/v1/identity/oidc/config | jq

# Output
{
  "request_id": "907ea965-1ed3-df12-375a-abe2438485be",
  "lease_id": "",
  "renewable": false,
  "lease_duration": 0,
  "data": null,
  "wrap_info": null,
  "warnings": [
    "If \"issuer\" is set explicitly, all tokens must be validated against that address, including those issued by secondary clusters. Setting issuer to \"\" will restore the default behavior of using the cluster's api_addr as the issuer."
  ],
  "auth": null
}

# Create named keys
vault write identity/oidc/key/oidc-key-api allowed_client_ids="us-west-1"
vault write identity/oidc/key/oidc-key-web allowed_client_ids="us-west-1"

# Create roles that will use the named keys
vault write identity/oidc/role/oidc-role-api \
  ttl=12h \
  key="oidc-key-api" \
  client_id="us-west-1" \
  template='{"consul": {"hostname": "consul-client-1" } }'

vault write identity/oidc/role/oidc-role-web \
  ttl=12h \
  key="oidc-key-web" \
  client_id="us-west-1" \
  template='{"consul": {"hostname": "consul-client-2" } }'

# Create policies to grant each service access to a token
vault policy write oidc-policy-api configs/vault/policies/api.hcl
vault policy write oidc-policy-web configs/vault/policies/web.hcl

# Create a user that can request a JWT
vault auth enable userpass
vault write auth/userpass/users/api password=api-password policies=oidc-policy-api
vault write auth/userpass/users/web password=web-password policies=oidc-policy-web

# Login and get JWTs
vault login -method=userpass username=api password=api-password
vault read identity/oidc/token/oidc-role-api

vault login -method=userpass username=web password=web-password
vault read identity/oidc/token/oidc-role-web

# Outputs
Key          Value
---          -----
client_id    us-west-1
token        eyJhbGciOiJSUzI1NiIsImtpZCI6ImExMWJhODZiLTM0M2QtYzI2YS0zOTk2LTliMWUxNmM0N2E1OCJ9.eyJhdWQiOiJ1cy13ZXN0LTEiLCJjb25zdWwiOnsiaG9zdG5hbWUiOiJjb25zdWwtY2xpZW50LTEifSwiZXhwIjoxNjQwMzc0ODgxLCJpYXQiOjE2NDAzMzE2ODEsImlzcyI6Imh0dHA6Ly8xNzIuMzEuMTA3LjE5Njo4MDAwL3YxL2lkZW50aXR5L29pZGMiLCJuYW1lc3BhY2UiOiJyb290Iiwic3ViIjoiN2M5NjViYzgtMDkwOC00NDFhLWE3M2MtYTJhMzM4YmNiNDRkIn0.XKXXXr3iLXgz-oVpNudIffm8FQI0j-U-d8lunOSHXhBI5FQTBCa8RXIQQ_fBtyE8bQAD8FuuLSq6iPY2d-ssX6c5-ovP97UT2X9Bf9qE-S6lal3kfq6kJq2_pQ3AItOJTQmk4GylGJWmnECt7FU9fpBY7bxshl17XmQ9h05ENdLSxTBzABGql3ldUrINl36Ckly_md8lmP0wm5DbBhHPCHfu7PVkdiG_BsC3tsjotd9sc-BEeM9QGEvElzBor1e9THUia0OpzJAKZUCWWlqDJxPFcERTq-xlp7rm7O7Ct8gBuo-gVY5Rf5hh27aRT8_D1IOIjQV9hpSUUZtUeP6Qhw
ttl          12h

Key          Value
---          -----
client_id    us-west-1
token        eyJhbGciOiJSUzI1NiIsImtpZCI6IjJmMGE5NWU0LWYwOWQtNTYwMi0xNzEyLWIzMzQ5NDdkYWYyMCJ9.eyJhdWQiOiJ1cy13ZXN0LTEiLCJjb25zdWwiOnsiaG9zdG5hbWUiOiJjb25zdWwtY2xpZW50LTIifSwiZXhwIjoxNjQwMzc0OTMzLCJpYXQiOjE2NDAzMzE3MzMsImlzcyI6Imh0dHA6Ly8xNzIuMzEuMTA3LjE5Njo4MDAwL3YxL2lkZW50aXR5L29pZGMiLCJuYW1lc3BhY2UiOiJyb290Iiwic3ViIjoiZDhhNDlmMDktNjg2YS02MzA5LWI0MmEtNzgzZmJhODQ5NTU2In0.CN_mOA0oARW3bIeU6B-lkciErLfl65a3E0vxaLhnCjpQI10aJzg3y8f8dZvIBqTkKkvTN6cl6oxzGR8jQtRttdk1iS1lDrjFkOXp6UTrsXEtyE_50vAZMbZx0_rW4-lSsNlXK3voo0l5jC72ifpRa4yudslmWgmnnFKXKIhCb_M2JqKNo6dTQ5XL-e1CxpQi_UhAkhkyMeLj5z7-o19nWmz6dy2-CTP-A5Zs_WLoyVcjauKjMSOaXk2Gqqunjkg6WP7rswh52qncofUjKUD-AlbqxZGIpci8PjC0pZorD7Q6F1IjE26PXu-D9teTgbPEH4aLOvxD4j0PAA7wMOONCg
ttl          12h
```
