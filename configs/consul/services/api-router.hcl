Kind = "service-router"
Name = "api"
Routes = [
  {
    Match {
      HTTP {
        Header = [
          {
            Name = "x-api-version"
            Exact = "v1"
          }
        ]
      }
    }

    Destination {
      Service = "api"
      ServiceSubset = "v1"
    }
  }
]
