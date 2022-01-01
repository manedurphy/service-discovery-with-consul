service {
  id = "api-v2"
  name = "api"
  port = 8081
  tags = ["fake-service-api", "v2"]
  token = "800818ce-ccb5-11ba-4cbc-b20dca15dac8"
  meta {
    version = "v2"
  }

  connect {
    sidecar_service{
      port = 20001
      check {
        name = "API V2 Connect Envoy Sidecar"
        tcp = "127.0.0.1:20001"
        interval = "10s"
        timeout = "1s"
      }
    }
  }

  checks = [
    {
      id = "api_v2_check"
      name = "Check API health 8081"
      service_id = "api-v2"
      http = "http://localhost:8081/health"
      method = "GET"
      interval = "10s"
      timeout = "1s"
      success_before_passing = 3
      failures_before_critical = 3
    }
  ]
}
