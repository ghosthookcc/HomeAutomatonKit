package main

import (
	"context"
	"fmt"
	"log"

	base "github.com/ghosthookcc/HomeAutomatonKit/app/ServiceManager/proto-base/common/go"
    echopb "github.com/ghosthookcc/HomeAutomatonKit/app/ServiceManager/proto-stubs/impl/go/impl/echo-service"
)

type EchoServiceServer struct {
	*base.BaseServiceServer
	echopb.UnimplementedEchoServiceServer
}

func NewEchoServiceServer() *EchoServiceServer {
	server := &EchoServiceServer{
		BaseServiceServer: base.NewBaseServer(),
	}
	server.SetHandler(server)
	return server
}

func (server *EchoServiceServer) Echo(context context.Context, msg *echopb.Message) (*echopb.Message, error) {
	fmt.Printf("[+][Echo] Received message: %s . . .\n", msg.GetData())
	return &echopb.Message{
		Data: fmt.Sprintf("Echo: %s", msg.GetData()),
	}, nil
}

func (server *EchoServiceServer) OnConnect(context context.Context, reply *base.BaseReply) error {
	fmt.Printf("[+][Echo Service] Client connecting with ID: %d . . .\n", reply.GetId())
	return nil
}

func (server *EchoServiceServer) OnDisconnect(context context.Context, reply *base.BaseReply) error {
	fmt.Printf("[+][Echo Service] Client disconnecting with ID: %d . . .\n", reply.GetId())
	return nil
}

func (server *EchoServiceServer) OnPropagateLogs(context context.Context, reply *base.BaseReply) error {
	fmt.Printf("[+][Echo Service] Propagating logs for ID: %d . . .\n", reply.GetId())
	return nil
}

func (server *EchoServiceServer) OnGetStatus(context context.Context, reply *base.BaseReply) error {
	fmt.Printf("[+][Echo Service] Status check for ID: %d . . .\n", reply.GetId())
	return nil
}

func main() {
	server := NewEchoServiceServer()
	
	fmt.Println("[+] Starting Echo Service server...")
	fmt.Println("[+] Available RPC methods:")
	fmt.Println("    - Common: GetState, Ping, Connect, Disconnect, PropagateCachedLogs, GetCurrentStatus")
	fmt.Println("    - Echo: Echo")
	
	if errno := base.RunServerWithRegistration(func(grpcServer *base.GrpcServer) {
		base.RegisterCommonService(grpcServer, server)
		echopb.RegisterEchoServiceServer(grpcServer, server)
	}); errno != nil {
		log.Fatalf("[-] Failed to run server: %v . . .", errno)
	}
}