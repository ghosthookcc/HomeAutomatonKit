package main

import (
	"context"
	"fmt"
	"log"

	base "github.com/ghosthookcc/HomeAutomatonKit/app/ServiceManager/proto-base/common/go"
)

type ExtendedServiceServer struct {
	*base.BaseServiceServer
}

func NewExtendedServer() *ExtendedServiceServer {
	server := &ExtendedServiceServer{
		BaseServiceServer: base.NewBaseServer(),
	}
	server.SetHandler(server)
	return server
}

func (server *ExtendedServiceServer) OnConnect(ctx context.Context, reply *base.BaseReply) error {
	fmt.Printf("[/][Extended] Custom connect logic for ID: %d . . .\n", reply.GetId())
	return nil
}

func (server *ExtendedServiceServer) OnDisconnect(ctx context.Context, reply *base.BaseReply) error {
	fmt.Printf("[/][Extended] Custom disconnect logic for ID: %d . . .\n", reply.GetId())
	return nil
}

func (server *ExtendedServiceServer) OnPropagateLogs(ctx context.Context, reply *base.BaseReply) error {
	fmt.Printf("[/][Extended] Custom log propagation for ID: %d . . .\n", reply.GetId())
	return nil
}

func (server *ExtendedServiceServer) OnGetStatus(ctx context.Context, reply *base.BaseReply) error {
	fmt.Printf("[/][Extended] Custom status check for ID: %d . . .\n", reply.GetId())
	return nil
}

func (server *ExtendedServiceServer) Ping(ctx context.Context, empty *base.Empty) (*base.State, error) {
	fmt.Println("[/][Extended] Custom Ping Sent . . .")
	return server.BaseServiceServer.Ping(ctx, empty)
}

func main() {
	server := NewExtendedServer()
	fmt.Println("[+] Starting extended service server . . .")
	if errno := base.RunServer(server); errno != nil {
		log.Fatalf("[-] Failed to run server: %v . . .", errno)
	}
}