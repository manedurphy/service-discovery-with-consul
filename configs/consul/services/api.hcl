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
