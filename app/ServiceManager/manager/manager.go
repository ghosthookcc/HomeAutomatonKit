package main

import (
	"context"
	"encoding/binary"
	"fmt"
	"net"
	"io"
	"log"

	base "github.com/ghosthookcc/HomeAutomatonKit/app/ServiceManager/proto-stubs/impl/go/service_manager"

	"google.golang.org/protobuf/proto"
)

type ServiceServerOverride struct {
	*base.BaseServiceServer
}

func NewServiceServerOverride() *ServiceServerOverride {
	server := &ServiceServerOverride{
		BaseServiceServer: base.NewBaseServer(),
	}
	server.SetHandler(server)
	return server
}

func (server *ServiceServerOverride) OnPing(context context.Context) error {
	fmt.Printf("[+][Echo Service] Ping received . . .\n")
	return nil
}
func (server *ServiceServerOverride) OnConnect(context context.Context, heartbeat *base.BaseHeartbeat) error {
	fmt.Printf("[+][Echo Service] Client connecting with ID: %d . . .\n", heartbeat.GetId())
	return nil
}
func (server *ServiceServerOverride) OnDisconnect(context context.Context, heartbeat *base.BaseHeartbeat) error {
	fmt.Printf("[+][Echo Service] Client disconnecting with ID: %d . . .\n", heartbeat.GetId())
	return nil
}
func (server *ServiceServerOverride) OnPropagateLogs(context context.Context, heartbeat *base.BaseHeartbeat) error {
	fmt.Printf("[+][Echo Service] Propagating logs for ID: %d . . .\n", heartbeat.GetId())
	return nil
}

func main() {
	server := NewEchoServiceServer()
	
	fmt.Println("[+] Starting Echo Service server . . .\n")
	fmt.Println("[+] Available RPC methods:")
	fmt.Println("    - Common: Ping, Connect, Disconnect, PropagateCachedLogs")
	fmt.Println("[+] Ports:")
	fmt.Println("    - gRPC: 50051\n")

	if errno := base.RunServerWithRegistration(func(grpcServer *base.GrpcServer) {
		base.RegisterCommonService(grpcServer, server)
	}); errno != nil {
		log.Fatalf("[-] Failed to run gRPC server: %v . . .", errno)
	}
}