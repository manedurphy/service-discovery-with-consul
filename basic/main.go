package main

import (
	"fmt"
	"net/http"
)

func main() {
	var (
		mux    *http.ServeMux
		server *http.Server
	)
	mux = http.NewServeMux()
	mux.HandleFunc("/healthz", func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusOK)
		w.Write([]byte("healthy"))
	})
	server = &http.Server{
		Addr:    ":8080",
		Handler: mux,
	}

	fmt.Println("server started on port 8080")
	if err := server.ListenAndServe(); err != nil {
		panic(err)
	}
}
