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

import (
    _ "google.golang.org/protobuf/types/known/emptypb"
    _ "google.golang.org/protobuf/types/known/timestamppb"
)

type (
    Empty     = emptypb.Empty
    Timestamp = timestamppb.Timestamp
    
    BaseReply     = pb.BaseReply
    State         = pb.State
    CurrentState  = pb.CurrentState
    ServiceServer = pb.ServiceServer

    GrpcServer = grpc.Server
)

var (
    NewTimestamp = timestamppb.New
    
    RegisterCommonService = pb.RegisterServiceServer
)

const (
    State_ALIVE         = pb.CurrentState_ALIVE
    State_CONNECTING    = pb.CurrentState_CONNECTING
    State_DISCONNECTING = pb.CurrentState_DISCONNECTING
)

var (
    tls        = flag.Bool("tls", false, "Connection uses TLS if true, else plain TCP")
    certFile   = flag.String("cert_file", "", "The TLS cert file")
    keyFile    = flag.String("key_file", "", "The TLS key file")
    jsonDBFile = flag.String("json_db_file", "", "A json file containing a list of features")
    port       = flag.Int("port", 50051, "The server port")
)

type ServiceHandler interface {
    OnConnect(context context.Context, reply *pb.BaseReply) error
    OnDisconnect(context context.Context, reply *pb.BaseReply) error
    OnPropagateLogs(context context.Context, reply *pb.BaseReply) error
    OnGetStatus(context context.Context, reply *pb.BaseReply) error
}

type BaseServiceServer struct {
    pb.UnimplementedServiceServer
    state   CurrentState
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

func (server *BaseServiceServer) GetCurrentState() CurrentState {
    return server.state
}
func (server *BaseServiceServer) SetState(state CurrentState) {
    server.state = state
}

func (server *BaseServiceServer) buildState(id int32) *State {
    return &pb.State{
        Descriptor_: &pb.BaseReply{
            Id:          id,
            LastUpdated: timestamppb.New(time.Now()),
        },
        State: server.state,
    }
}
func (server *BaseServiceServer) GetBuildState(context context.Context, reply *BaseReply) (*State, error) {
    return server.buildState(reply.GetId()), nil
}


func (server *BaseServiceServer) Ping(context context.Context, _ *Empty) (*State, error) {
    return server.buildState(0), nil
}

func (server *BaseServiceServer) Connect(context context.Context, reply *BaseReply) (*State, error) {
    if server.handler != nil {
        if errno := server.handler.OnConnect(context, reply); errno != nil {
            return nil, errno
        }
    }
    
    server.state = State_CONNECTING
    return server.buildState(reply.GetId()), nil
}

func (server *BaseServiceServer) Disconnect(context context.Context, reply *BaseReply) (*State, error) {
    if server.handler != nil {
        if errno := server.handler.OnDisconnect(context, reply); errno != nil {
            return nil, errno
        }
    }
    
    server.state = State_DISCONNECTING
    return server.buildState(reply.GetId()), nil
}

func (server *BaseServiceServer) PropagateCachedLogs(context context.Context, reply *BaseReply) (*Empty, error) {
    if server.handler != nil {
        if errno := server.handler.OnPropagateLogs(context, reply); errno != nil {
            return nil, errno
        }
    }
    
    fmt.Println("[+] Propagating logs for ID:", reply.GetId(), ". . .")
    return &Empty{}, nil
}

func (server *BaseServiceServer) GetCurrentStatus(context context.Context, reply *BaseReply) (*Empty, error) {
    if server.handler != nil {
        if errno := server.handler.OnGetStatus(context, reply); errno != nil {
            return nil, errno
        }
    }
    
    fmt.Printf("[/] Current status requested for ID %d → %v . . .\n", reply.GetId(), server.state)
    return &Empty{}, nil
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