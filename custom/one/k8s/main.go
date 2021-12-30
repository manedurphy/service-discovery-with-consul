package main

import (
	"fmt"
	"io"
	"net/http"
	"os"
)

func main() {
	var (
		mux    *http.ServeMux
		server *http.Server
		err    error
	)

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

		resp, err = http.Get(fmt.Sprintf("%s/hello", os.Getenv("TWO_SERVICE_URL")))
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

	fmt.Println("starting server on port 8080")
	if err = server.ListenAndServe(); err != nil {
		panic(err)
	}
}
