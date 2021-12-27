node "consul-client-1" {
	policy = "write"
}
service_prefix "" {
	policy = "read"
}
