import socket

HOST = "127.0.0.1"
PORT = 9999

def startServer(host, port):
    server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    server.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)

    print(f"[+] Binding to {host}:{port} . . .")

    server.bind((host, port))
    server.listen(10)

    print(f"[/] Waiting for client connection . . .")

    connection, address = server.accept()
    print(f"[+] Received connection: {address} . . .")

    while True:
        data = connection.recv(1024).decode("utf-8")
        if not data: continue

        print(f"[/] Received from server: {str(data)} . . .")

        response = ("ECHO " + str(data)).encode("utf-8")
        connection.send(response)
        break
    server.close()

def main():
    startServer(HOST, PORT)

if __name__ == "__main__":
    main()
