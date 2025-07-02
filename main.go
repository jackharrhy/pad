package main

import (
	_ "embed"
	"io"
	"log"
	"net/http"
	"os"
	"path/filepath"
	"strings"
)

//go:embed site.html
var siteHTML []byte

const (
	padDir  = "./data"
	padFile = "pad.txt"
)

func ensurePad() string {
	padPath := filepath.Join(padDir, padFile)
	if _, err := os.Stat(padDir); os.IsNotExist(err) {
		os.MkdirAll(padDir, 0755)
	}
	if _, err := os.Stat(padPath); os.IsNotExist(err) {
		os.WriteFile(padPath, []byte(""), 0644)
	}
	return padPath
}

func shouldReturnHTML(r *http.Request) bool {
	accept := r.Header.Get("Accept")
	for _, v := range strings.Split(accept, ",") {
		if strings.TrimSpace(v) == "text/html" {
			return true
		}
	}
	return false
}

func handler(w http.ResponseWriter, r *http.Request) {
	padPath := ensurePad()
	if r.Method == http.MethodGet {
		if shouldReturnHTML(r) {
			w.Header().Set("Content-Type", "text/html")
			w.Write(siteHTML)
			return
		}
		w.Header().Set("Content-Type", "text/plain")
		b, err := os.ReadFile(padPath)
		if err != nil {
			w.WriteHeader(http.StatusInternalServerError)
			w.Write([]byte("error reading pad"))
			return
		}
		w.Write(b)
		return
	}
	if r.Method == http.MethodPut {
		body, err := io.ReadAll(r.Body)
		if err != nil {
			w.WriteHeader(http.StatusBadRequest)
			return
		}
		os.WriteFile(padPath, body, 0644)
		w.WriteHeader(http.StatusNoContent)
		return
	}
	w.WriteHeader(http.StatusMethodNotAllowed)
}

func main() {
	http.HandleFunc("/", handler)
	log.Println("Listening on 0.0.0.0:3000")
	log.Fatal(http.ListenAndServe("0.0.0.0:3000", nil))
}
