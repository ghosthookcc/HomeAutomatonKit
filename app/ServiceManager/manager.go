package main

import ("fmt"
        "context"
        "flag"
        "log"
        "net"
        "time"

        "google.golang.org/grpc"
        "google.golang.org/protobuf/types/known/emptypb"
        "google.golang.org/protobuf/types/known/timestamppb"

        pb "github.com/ghosthookcc/HomeAutomatonKit/app/ServiceManager/proto")

var (tls        = flag.Bool("tls", false, "Connection uses TLS if true, else plain TCP")
     certFile   = flag.String("cert_file", "", "The TLS cert file")
     keyFile    = flag.String("key_file", "", "The TLS key file")
     jsonDBFile = flag.String("json_db_file", "", "A json file containing a list of features")
     port       = flag.Int("port", 50051, "The server port"))

type serviceServer struct 
{
    pb.UnimplementedServiceServer
    state pb.CurrentState
}

func newServer() *serviceServer {
    return &serviceServer {
        state: pb.CurrentState_ALIVE,
    }
}

func (server *serviceServer) buildState(id int32) *pb.State {
    return &pb.State {
        Descriptor_: &pb.BaseReply {
            Id: id,
            LastUpdated: timestamppb.New(time.Now()),
        },
        State: server.state,
    }
}

func (server *serviceServer) GetState(context context.Context, reply *pb.BaseReply) (*pb.State, error) {
    return server.buildState(reply.GetId()), nil
}

func (server *serviceServer) Ping(context context.Context, _ *emptypb.Empty) (*pb.State, error) {
    return server.buildState(0), nil
}

func (server *serviceServer) Connect(context context.Context, reply *pb.BaseReply) (*pb.State, error) {
    server.state = pb.CurrentState_CONNECTING
    return server.buildState(reply.GetId()), nil
}

func (server *serviceServer) Disconnect(context context.Context, reply *pb.BaseReply) (*pb.State, error) {
    server.state = pb.CurrentState_DISCONNECTING
    return server.buildState(reply.GetId()), nil
}

func (server *serviceServer) PropagateCachedLogs(context context.Context, reply *pb.BaseReply) (*emptypb.Empty, error) {
    fmt.Println("Propagating logs for ID:", reply.GetId())
    return &emptypb.Empty{}, nil
}

func (server *serviceServer) GetCurrentStatus(context context.Context, reply *pb.BaseReply) (*emptypb.Empty, error) {
    fmt.Printf("Current status requested for ID %d → %v\n", reply.GetId(), server.state)
    return &emptypb.Empty{}, nil
}

func main() {
    flag.Parse()

    listener, errno := net.Listen("tcp", fmt.Sprintf(":%d", *port))
    if errno != nil {
        log.Fatalf("[-] Failed to listen: %v . . .", errno)
    }

    grpcServer := grpc.NewServer()

    pb.RegisterServiceServer(grpcServer, newServer())

    fmt.Printf("[+] Server running on port %d . . .\n", *port)
    if errno := grpcServer.Serve(listener); errno != nil {
        log.Fatalf("[-] Failed to serve: %v . . .", errno)
    }
}
