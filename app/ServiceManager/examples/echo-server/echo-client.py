import socket

HOST = "127.0.0.1"
PORT = 9999

def startClient(host, port):
    client = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

    print(f"[+] Connecting to {host}:{port} . . .")
    client.connect((host, port))
    print(f"[+] Connected to {host}:{port} . . .")

    dataToSend = "Hello World!".encode("utf-8")
    client.send(dataToSend)

    while True:
        data = client.recv(1024).decode("utf-8")
        print(f"[+] Received from client: {str(data)} . . .")
        break
    client.close()

def main():
    startClient(HOST, PORT)

if __name__ == "__main__":
    main()
