package common_service_proto

import (
    "context"
    "flag"
    "fmt"
    "net"
    "time"

    "google.golang.org/grpc"
    "google.golang.org/protobuf/types/known/emptypb"
    "google.golang.org/protobuf/types/known/timestamppb"
    pb "github.com/ghosthookcc/HomeAutomatonKit/app/ServiceManager/proto-stubs/impl/go/common"
)

type (
    Empty            = emptypb.Empty
    Timestamp        = timestamppb.Timestamp
    
    BaseHeartbeat    = pb.BaseHeartbeat
    BaseState        = pb.BaseState
    ConnectionState  = pb.ConnectionState
    ServiceServer    = pb.ServiceServer

    GrpcServer = grpc.Server
)

var (
    NewTimestamp = timestamppb.New
    
    RegisterCommonService = pb.RegisterServiceServer
)

const (
    State_ALIVE         = pb.ConnectionState_ALIVE
    State_DEAD          = pb.ConnectionState_DEAD
    State_CONNECTING    = pb.ConnectionState_CONNECTING
    State_DISCONNECTING = pb.ConnectionState_DISCONNECTING
    State_RECONNECTING  = pb.ConnectionState_RECONNECTING
    State_ERROR         = pb.ConnectionState_ERROR
)

var (
    tls        = flag.Bool("tls", false, "Connection uses TLS if true, else plain TCP")
    certFile   = flag.String("cert_file", "", "The TLS cert file")
    keyFile    = flag.String("key_file", "", "The TLS key file")
    jsonDBFile = flag.String("json_db_file", "", "A json file containing a list of features")
    port       = flag.Int("port", 50051, "The server port")
)

type ServiceHandler interface {
    OnPing(context context.Context) error
    OnConnect(context context.Context, heartbeat *pb.BaseHeartbeat) error
    OnDisconnect(context context.Context, heartbeat *pb.BaseHeartbeat) error
    OnPropagateLogs(context context.Context, heartbeat *pb.BaseHeartbeat) error
}

type BaseServiceServer struct {
    pb.UnimplementedServiceServer
    state   ConnectionState
    handler ServiceHandler
}

func NewBaseServer() *BaseServiceServer {
    return &BaseServiceServer{
        state:   State_ALIVE,
        handler: nil,
    }
}

func (server *BaseServiceServer) SetHandler(handler ServiceHandler) {
    server.handler = handler
}
func (server *BaseServiceServer) GetCurrentState() ConnectionState {
    return server.state
}

func (server *BaseServiceServer) buildState(id int32) *BaseState {
    heartbeat := &pb.BaseHeartbeat{
        Id:          id,
        LastUpdated: timestamppb.New(time.Now()),
    }
    
    return &pb.BaseState{
        Heartbeat: heartbeat,
        State:     server.state,
    }
}

func (server *BaseServiceServer) BasePing() *BaseHeartbeat {
    return &pb.BaseHeartbeat{
        Id:          0,
        LastUpdated: timestamppb.New(time.Now()),
    }
}
func (server *BaseServiceServer) Ping(context context.Context, _ *Empty) (*BaseHeartbeat, error) {
    if server.handler != nil {
        if errno := server.handler.OnPing(context); errno != nil {
            return nil, errno
        }
    }
    return server.BasePing(), nil
}

func (server *BaseServiceServer) BaseConnect(heartbeat *BaseHeartbeat) *BaseState {
    server.state = State_CONNECTING
    return server.buildState(heartbeat.GetId())
}
func (server *BaseServiceServer) Connect(context context.Context, heartbeat *BaseHeartbeat) (*BaseState, error) {
    if server.handler != nil {
        if errno := server.handler.OnConnect(context, heartbeat); errno != nil {
            return nil, errno
        }
    }
    return server.BaseConnect(heartbeat), nil
}

func (server *BaseServiceServer) BaseDisconnect(heartbeat *BaseHeartbeat) *BaseState {
    server.state = State_DISCONNECTING
    return server.buildState(heartbeat.GetId())
}
func (server *BaseServiceServer) Disconnect(context context.Context, heartbeat *BaseHeartbeat) (*BaseState, error) {
    if server.handler != nil {
        if errno := server.handler.OnDisconnect(context, heartbeat); errno != nil {
            return nil, errno
        }
    }
    return server.BaseDisconnect(heartbeat), nil
}

func (server *BaseServiceServer) BasePropagateCachedLogs(heartbeat *BaseHeartbeat) *Empty {
    fmt.Println("[+] Propagating logs for ID:", heartbeat.GetId(), ". . .")
    return &Empty{}
}
func (server *BaseServiceServer) PropagateCachedLogs(context context.Context, heartbeat *BaseHeartbeat) (*Empty, error) {
    if server.handler != nil {
        if errno := server.handler.OnPropagateLogs(context, heartbeat); errno != nil {
            return nil, errno
        }
    }
    return server.BasePropagateCachedLogs(heartbeat), nil
}

func RunServer(service pb.ServiceServer) error {
    flag.Parse()
    listener, errno := net.Listen("tcp", fmt.Sprintf(":%d", *port))
    if errno != nil {
        return fmt.Errorf("[-] Failed to listen: %v . . .", errno)
    }

    grpcServer := grpc.NewServer()
    pb.RegisterServiceServer(grpcServer, service)
    fmt.Printf("[+] Server running on port %d . . .\n", *port)
    
    if errno := grpcServer.Serve(listener); errno != nil {
        return fmt.Errorf("[-] Failed to serve: %v . . .", errno)
    }
    return nil
}

func RunServerWithRegistration(registerFunc func(*grpc.Server)) error {
    flag.Parse()
    listener, errno := net.Listen("tcp", fmt.Sprintf(":%d", *port))
    if errno != nil {
        return fmt.Errorf("[-] Failed to listen: %v . . .", errno)
    }

    grpcServer := grpc.NewServer()
    registerFunc(grpcServer)
    fmt.Printf("[+] Server running on port %d . . .\n", *port)
    
    if errno := grpcServer.Serve(listener); errno != nil {
        return fmt.Errorf("[-] Failed to serve: %v . . .", errno)
    }
    return nil
}