package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"sync"

	"github.com/gorilla/websocket"
)

// Basic 1 to 1 signalining between 2 clients with ID's
// TODO point out flaws with approach (within what its purpose is )

var port = ":9090"

var upgrader = websocket.Upgrader{
	ReadBufferSize:  1024,
	WriteBufferSize: 1024,
	CheckOrigin:     func(r *http.Request) bool { return true },
}

type Client struct {
	conn *websocket.Conn
	id   string
}

var mux sync.Mutex
var clients map[string]*websocket.Conn

func main() {

	clients := make(map[string]*websocket.Conn)

	http.HandleFunc("/ws", func(w http.ResponseWriter, r *http.Request) {

		conn, err := upgrader.Upgrade(w, r, nil)
		defer conn.Close()

		if err != nil {
			log.Println(err)
			return
		}
		fmt.Println("Got connection")

		for {
			// Read message from browser
			msgType, msg, err := conn.ReadMessage()
			if err != nil {
				return
			}

			fmt.Printf("%s sent: %s\n", conn.RemoteAddr(), string(msg))

			jmsg := make(map[string]json.RawMessage)

			err = json.Unmarshal(msg, &jmsg)
			if err != nil {
				fmt.Println(err.Error())
			}

			// fmt.Println(jmsg)

			var t string

			err = json.Unmarshal(jmsg["type"], &t)
			if err != nil {
				fmt.Println(err.Error())
			}

			switch t {
			case "register":
				var id string
				err = json.Unmarshal(jmsg["id"], &id)
				if err != nil {
					fmt.Println(err.Error())
				}

				fmt.Println("registering %s", id)
				mux.Lock()
				clients[id] = conn
				mux.Unlock()
				outmsg, _ := json.Marshal(map[string]interface{}{"type": "register", "success": true})
				conn.WriteMessage(msgType, outmsg)
			case "offer":
				var to string
				err = json.Unmarshal(jmsg["to"], &to)
				if err != nil {
					fmt.Println(err.Error())
				}
				c := clients[to]
				fmt.Println("Forwarding offer msg to %s", to)

				mux.Lock()
				c.WriteMessage(msgType, msg)
				mux.Unlock()
			case "answer":
				var to string
				err = json.Unmarshal(jmsg["to"], &to)
				if err != nil {
					fmt.Println(err.Error())
				}
				c := clients[to]
				fmt.Println("Forwarding answer msg to %s", to)
				mux.Lock()
				c.WriteMessage(msgType, msg)
				mux.Unlock()
			case "candidate":
				var to string
				err = json.Unmarshal(jmsg["to"], &to)
				if err != nil {
					fmt.Println(err.Error())
				}
				c := clients[to]
				fmt.Println("Forwarding candidate msg to %s", to)
				mux.Lock()
				c.WriteMessage(msgType, msg)
				mux.Unlock()
			case "leave":
				var to string
				err = json.Unmarshal(jmsg["to"], &to)
				if err != nil {
					fmt.Println(err.Error())
				}
				c := clients[to]
				fmt.Println("Forwarding leave msg to %s", to)
				mux.Lock()
				c.WriteMessage(msgType, msg)
				mux.Unlock()
			}
		}
	})

	err := http.ListenAndServe(port, nil)
	if err != nil {
		log.Fatal("ListenAndServe: ", err)
	}
}
