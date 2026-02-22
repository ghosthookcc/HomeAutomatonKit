package main

import (
	"context"
	"encoding/binary"
	"time"
	"fmt"
	"net"
	"io"
	"log"
	"os"

	base "github.com/ghosthookcc/HomeAutomatonKit/app/ServiceManager/proto-base/common/go"
	datacollectionpb "github.com/ghosthookcc/HomeAutomatonKit/app/ServiceManager/proto-stubs/impl/go/impl/sensor-data-collection-service"

	"google.golang.org/protobuf/proto"
	"google.golang.org/protobuf/types/known/timestamppb"
)

type SensorReading struct {
	Humidity int
	Timestamp time.Time
}

type DataCollectionServiceServer struct {
	*base.BaseServiceServer
	datacollectionpb.UnimplementedDataCollectionServiceServer
	LogChannel chan SensorReading
}

func NewDataCollectionServiceServer() *DataCollectionServiceServer {
	server := &DataCollectionServiceServer{
		BaseServiceServer: base.NewBaseServer(),
		LogChannel: make(chan SensorReading, 50),
	}
	server.SetHandler(server)
	return server
}

func (server *DataCollectionServiceServer) ReportData (context context.Context, msg *datacollectionpb.SensorData) (*base.BaseHeartbeat, error) {
	ts := time.Unix(msg.SendAt.Seconds, int64(msg.SendAt.Nanos)).Local()
	fmt.Printf("Received SensorData: humidity=%d%%, sendAt=%s . . .\n", msg.HumidityPercent, ts.Format(time.RFC3339))

	select {
	case server.LogChannel <- SensorReading {
		Humidity:  int(msg.HumidityPercent),
		Timestamp: ts,
	}:
	default:
		fmt.Println("[/] Log channel full, dropping sensor reading . . .")
	}

	hb := &base.BaseHeartbeat{
		Id:          1,
		LastUpdated: timestamppb.Now(),
	}

	return hb, nil
}

func (server *DataCollectionServiceServer) OnPing(context context.Context) error {
	fmt.Printf("[+][Echo Service] Ping received . . .\n")
	return nil
}
func (server *DataCollectionServiceServer) OnConnect(context context.Context, heartbeat *base.BaseHeartbeat) error {
	fmt.Printf("[+][Echo Service] Client connecting with ID: %d . . .\n", heartbeat.GetId())
	return nil
}
func (server *DataCollectionServiceServer) OnDisconnect(context context.Context, heartbeat *base.BaseHeartbeat) error {
	fmt.Printf("[+][Echo Service] Client disconnecting with ID: %d . . .\n", heartbeat.GetId())
	return nil
}
func (server *DataCollectionServiceServer) OnPropagateLogs(context context.Context, heartbeat *base.BaseHeartbeat) error {
	fmt.Printf("[+][Echo Service] Propagating logs for ID: %d . . .\n", heartbeat.GetId())
	return nil
}

func (server *DataCollectionServiceServer) handleClientBridge(connection net.Conn) {
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

	request := &datacollectionpb.SensorData{}
	if errno := proto.Unmarshal(messageBuffer, request); errno != nil {
		fmt.Printf("[-][TCP] Error decoding protobuf: %v  . . .\n", errno)
		return
	}

	response, errno := server.ReportData(context.Background(), request)
	if errno != nil {
		fmt.Printf("[-][TCP] Error in ReportData: %v . . .\n", errno)
		return
	}

	responseAsBytes, errno := proto.Marshal(response)
	if errno != nil {
		fmt.Printf("[-][TCP] Error encoding response: %v . . .\n", errno)
		return
	}

	responseLength := uint32(len(responseAsBytes))
	lengthBuffer = []byte{
		byte(responseLength >> 24),
		byte(responseLength >> 16),
		byte(responseLength >> 8),
		byte(responseLength),
	}

	if _, errno := connection.Write(lengthBuffer); errno != nil {
		fmt.Printf("[-][TCP] Error sending response length: %v . . .\n", errno)
		return
	}
	if _, errno := connection.Write(responseAsBytes); errno != nil {
		fmt.Printf("[-][TCP] Error sending response data: %v . . .\n", errno)
		return
	}
}

func (server *DataCollectionServiceServer) RunTCPServer(port string) error {
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
	server := NewDataCollectionServiceServer()
	
	fmt.Println("[+] Starting Echo Service server . . .\n")
	fmt.Println("[+] Available RPC methods:")
	fmt.Println("    - Common: Ping, Connect, Disconnect, PropagateCachedLogs")
	fmt.Println("    - Echo: Echo")
	fmt.Println("[+] Ports:")
	fmt.Println("    - TCP (ESP32): 8081")
	fmt.Println("    - gRPC: 50051\n")

	go func() {
		file, errno := os.OpenFile("humidity_log.txt", os.O_APPEND|os.O_CREATE|os.O_WRONLY, 0644)
		if errno != nil {
			panic(errno)
		}
		defer file.Close()

		for reading := range server.LogChannel {
			line := fmt.Sprintf("%d%% %s %s\n",
				reading.Humidity,
				reading.Timestamp.Format("2006-01-02"),
				reading.Timestamp.Format(time.RFC3339))
			if _, errno := file.WriteString(line); errno != nil {
				fmt.Printf("[-] Failed to write to file: %v . . .\n", errno)
			}
		}
	}()

	go func() {
		if errno := server.RunTCPServer("8081"); errno != nil {
			log.Fatalf("[-] Failed to run TCP server: %v . . .", errno)
		}
	}()
	
	if errno := base.RunServerWithRegistration(func(grpcServer *base.GrpcServer) {
		base.RegisterCommonService(grpcServer, server)
		datacollectionpb.RegisterDataCollectionServiceServer(grpcServer, server)
	}); errno != nil {
		log.Fatalf("[-] Failed to run gRPC server: %v . . .", errno)
	}
}