package main

import (
	"fmt"
	"io"
	"net/http"
	"os"
	"os/signal"
	"syscall"

	"github.com/hashicorp/consul/api"
	"github.com/hashicorp/consul/connect"
)

type Service struct {
	Name         string
	ConsulClient *api.Client
}

func NewService(name string) (*Service, error) {
	var (
		client     *api.Client
		serviceDef *api.AgentServiceRegistration
		s          *Service
		err        error
	)

	if client, err = api.NewClient(api.DefaultConfig()); err != nil {
		return nil, err
	}

	s = &Service{
		Name:         name,
		ConsulClient: client,
	}

	serviceDef = &api.AgentServiceRegistration{
		Name: name,
		Meta: map[string]string{
			"location": "atlanta",
			"region":   "us-east-1",
		},
		Port: 8080,
		Connect: &api.AgentServiceConnect{
			SidecarService: &api.AgentServiceRegistration{
				Proxy: &api.AgentServiceConnectProxyConfig{
					Upstreams: []api.Upstream{
						{
							DestinationName: "service_two",
							LocalBindPort:   8081,
						},
					},
				},
			},
		},
		Check: &api.AgentServiceCheck{
			Name:                           "health-check",
			HTTP:                           "http://localhost:8080/healthz",
			Method:                         http.MethodGet,
			Notes:                          "Health endpoint ensures that service is available",
			DeregisterCriticalServiceAfter: "1m",
			Timeout:                        "5s",
			Interval:                       "10s",
			TLSSkipVerify:                  false,
		},
	}

	if err := s.ConsulClient.Agent().ServiceRegister(serviceDef); err != nil {
		return nil, err
	}

	return s, nil
}

func main() {
	var (
		svc        *Service
		mux        *http.ServeMux
		server     *http.Server
		connectSvc *connect.Service
		sigs       chan os.Signal
		err        error
	)
	if svc, err = NewService("service_one"); err != nil {
		panic(err)
	}

	if connectSvc, err = connect.NewService("service_one", svc.ConsulClient); err != nil {
		panic(err)
	}
	defer connectSvc.Close()

	mux = http.NewServeMux()
	mux.HandleFunc("/healthz", func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusOK)
		w.Write([]byte("healthy"))
	})

	mux.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		var (
			resp *http.Response
			b    []byte
			err  error
		)

		resp, err = http.Get("http://localhost:8081/hello")
		if err != nil {
			w.WriteHeader(http.StatusInternalServerError)
			w.Write([]byte(err.Error()))
			return
		}

		if b, err = io.ReadAll(resp.Body); err != nil {
			w.WriteHeader(http.StatusInternalServerError)
			w.Write([]byte(err.Error()))
			return
		}
		w.WriteHeader(http.StatusOK)
		w.Write(b)
	})

	server = &http.Server{
		Addr:    ":8080",
		Handler: mux,
	}

	sigs = make(chan os.Signal, 1)
	signal.Notify(sigs, syscall.SIGINT, syscall.SIGTERM)
	go func() {
		<-sigs
		fmt.Println("exiting program")
		if err := svc.ConsulClient.Agent().ServiceDeregister(svc.Name); err != nil {
			panic(err)
		}
		os.Exit(0)
	}()

	fmt.Println("starting server on port 8080")
	if err = server.ListenAndServe(); err != nil {
		panic(err)
	}
}
