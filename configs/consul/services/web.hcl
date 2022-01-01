service {
	name = "web"
	port = 8080
	tags = ["fake-service-web"]
  token = "48b954b1-0ac7-8f93-e22d-cbb0f3686bc2"
  meta {
    version = "v1"
  }

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