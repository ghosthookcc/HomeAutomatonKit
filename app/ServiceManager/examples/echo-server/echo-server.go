package main

import (
	"context"
	"encoding/binary"
	"fmt"
	"net"
	"io"
	"log"

	base "github.com/ghosthookcc/HomeAutomatonKit/app/ServiceManager/proto-base/common/go"
	echopb "github.com/ghosthookcc/HomeAutomatonKit/app/ServiceManager/proto-stubs/impl/go/impl/echo-service"

	"google.golang.org/protobuf/proto"
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

func (server *EchoServiceServer) OnPing(context context.Context) error {
	fmt.Printf("[+][Echo Service] Ping received . . .\n")
	return nil
}
func (server *EchoServiceServer) OnConnect(context context.Context, heartbeat *base.BaseHeartbeat) error {
	fmt.Printf("[+][Echo Service] Client connecting with ID: %d . . .\n", heartbeat.GetId())
	return nil
}
func (server *EchoServiceServer) OnDisconnect(context context.Context, heartbeat *base.BaseHeartbeat) error {
	fmt.Printf("[+][Echo Service] Client disconnecting with ID: %d . . .\n", heartbeat.GetId())
	return nil
}
func (server *EchoServiceServer) OnPropagateLogs(context context.Context, heartbeat *base.BaseHeartbeat) error {
	fmt.Printf("[+][Echo Service] Propagating logs for ID: %d . . .\n", heartbeat.GetId())
	return nil
}

func (server *EchoServiceServer) handleClientBridge(connection net.Conn) {
	defer connection.Close()
	fmt.Printf("\n[+][TCP] Client connected: %s . . .\n\n", connection.RemoteAddr())

	lengthBuffer := make([]byte, 4)
	if _, errno := io.ReadFull(connection, lengthBuffer); errno != nil {
		if errno != io.EOF {
			fmt.Printf("[-][TCP] Error reading length: %v . . .\n", errno)
		}
		return
	}

	messageLength := binary.BigEndian.Uint32(lengthBuffer)
	if messageLength > 1024*1024 {
		fmt.Printf("[-][TCP] Message too large: %d bytes . . .\n", messageLength)
		return
	}

	messageBuffer := make([]byte, messageLength)
	if _, errno := io.ReadFull(connection, messageBuffer); errno != nil {
		fmt.Printf("[-][TCP] Error reading message: %v . . .\n", errno)
		return
	}

	request := &echopb.Message{}
	if errno := proto.Unmarshal(messageBuffer, request); errno != nil {
		fmt.Printf("[-][TCP] Error decoding protobuf: %v  . . .\n", errno)
		return
	}

	response, errno := server.Echo(context.Background(), request)
	if errno != nil {
		fmt.Printf("[-][TCP] Echo error: %v . . .\n", errno)
		return
	}

	responseBuffer, errno := proto.Marshal(response)
	if errno != nil {
		fmt.Printf("[-][TCP] Error encoding response: %v . . .\n", errno)
		return
	}

	responseLengthBuffer := make([]byte, 4)
	binary.BigEndian.PutUint32(responseLengthBuffer, uint32(len(responseBuffer)))
	if _, errno := connection.Write(responseLengthBuffer); errno != nil {
		fmt.Printf("[-][TCP] Error writing response length: %v . . .\n", errno)
		return
	}

	if _, errno := connection.Write(responseBuffer); errno != nil {
		fmt.Printf("[-][TCP] Error writing response: %v . . .\n", errno)
		return
	}
	fmt.Printf("[+][TCP] Sent response: %s . . .\n\n", response.GetData())
}

func (server *EchoServiceServer) RunTCPServer(port string) error {
	listener, errno := net.Listen("tcp", ":"+port)
	if errno != nil {
		return fmt.Errorf("[-] Failed to start TCP listener: %v . . .", errno)
	}
	defer listener.Close()

	fmt.Printf("[+] TCP server listening on port %s for ESP32 clients . . .\n\n", port)

	for {
		connection, errno := listener.Accept()
		if errno != nil {
			fmt.Printf("[-][TCP] Accept error: %v . . .\n", errno)
			continue
		}
		go server.handleClientBridge(connection)
	}
}

func main() {
	server := NewEchoServiceServer()
	
	fmt.Println("[+] Starting Echo Service server . . .\n")
	fmt.Println("[+] Available RPC methods:")
	fmt.Println("    - Common: Ping, Connect, Disconnect, PropagateCachedLogs")
	fmt.Println("    - Echo: Echo")
	fmt.Println("[+] Ports:")
	fmt.Println("    - TCP (ESP32): 8081")
	fmt.Println("    - gRPC: 50051\n")

	go func() {
		if errno := server.RunTCPServer("8081"); errno != nil {
			log.Fatalf("[-] Failed to run TCP server: %v . . .", errno)
		}
	}()
	
	if errno := base.RunServerWithRegistration(func(grpcServer *base.GrpcServer) {
		base.RegisterCommonService(grpcServer, server)
		echopb.RegisterEchoServiceServer(grpcServer, server)
	}); errno != nil {
		log.Fatalf("[-] Failed to run gRPC server: %v . . .", errno)
	}
}