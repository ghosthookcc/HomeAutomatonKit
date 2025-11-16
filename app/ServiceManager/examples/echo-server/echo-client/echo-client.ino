#include <WiFi.h>
#include <pb_encode.h>
#include <pb_decode.h>
#include <pb_common.h>

#include "impl/echo-service/echo-service.pb.h"
#include "secrets.h"

WiFiClient client;

bool encode_string(pb_ostream_t *stream, const pb_field_t *field, void * const *arg) 
{
    const char *str = (const char*)(*arg);
    if (!pb_encode_tag_for_field(stream, field))
        return false;
    return pb_encode_string(stream, (uint8_t*)str, strlen(str));
}

bool decode_string(pb_istream_t *stream, const pb_field_t *field, void **arg) 
{
    uint8_t buffer[128] = {0};
    size_t str_len = stream->bytes_left;
    
    if (str_len > sizeof(buffer) - 1)
        return false;
    
    if (!pb_read(stream, buffer, str_len))
        return false;
    
    buffer[str_len] = '\0';
    Serial.printf("Decoded: %s\n", buffer);
    return true;
}

bool send_echo(const char* message) 
{
    if (!client.connected()) 
    {
        Serial.println("Connecting...");
        if (!client.connect(SERVER_HOST, SERVER_PORT)) 
        {
            Serial.println("Connection failed!");
            return false;
        }
        Serial.println("Connected!");
    }

    echo_Message msg = echo_Message_init_zero;
    msg.data.funcs.encode = encode_string;
    msg.data.arg = (void*)message;

    uint8_t buffer[256];
    pb_ostream_t stream = pb_ostream_from_buffer(buffer, sizeof(buffer));

    if (!pb_encode(&stream, echo_Message_fields, &msg)) 
    {
        Serial.printf("Encode failed: %s\n", PB_GET_ERROR(&stream));
        return false;
    }

    size_t msg_len = stream.bytes_written;
    Serial.printf("Sending %d bytes: %s\n", msg_len, message);

    uint8_t len_buf[4];
    len_buf[0] = (msg_len >> 24) & 0xFF;
    len_buf[1] = (msg_len >> 16) & 0xFF;
    len_buf[2] = (msg_len >> 8) & 0xFF;
    len_buf[3] = msg_len & 0xFF;
    client.write(len_buf, 4);

    client.write(buffer, msg_len);
    client.flush();

    unsigned long timeout = millis() + 5000;
    while (client.available() < 4 && millis() < timeout) 
    {
        delay(10);
    }
    if (client.available() < 4) 
    {
        Serial.println("Timeout waiting for response");
        return false;
    }

    uint32_t resp_len = 0;
    resp_len |= (uint32_t)client.read() << 24;
    resp_len |= (uint32_t)client.read() << 16;
    resp_len |= (uint32_t)client.read() << 8;
    resp_len |= (uint32_t)client.read();

    Serial.printf("Response length: %d\n", resp_len);

    if (resp_len > sizeof(buffer)) 
    {
        Serial.println("Response too large for buffer");
        return false;
    }

    timeout = millis() + 5000;
    while (client.available() < (int)resp_len && millis() < timeout) 
    {
        delay(10);
    }
    if (client.available() < (int)resp_len) 
    {
        Serial.println("Timeout waiting for response data");
        return false;
    }

    client.readBytes(buffer, resp_len);

    echo_Message response = echo_Message_init_zero;
    response.data.funcs.decode = decode_string;

    pb_istream_t in_stream = pb_istream_from_buffer(buffer, resp_len);
    if (!pb_decode(&in_stream, echo_Message_fields, &response)) 
    {
        Serial.printf("Decode failed: %s\n", PB_GET_ERROR(&in_stream));
        return false;
    }

    return true;
}

void setup() 
{
    Serial.begin(115200);
    Serial.println("\n=== ESP32 Echo Client ===");
    delay(1000);

    WiFi.begin(WIFI_SSID, WIFI_PASS);
    Serial.printf("Connecting to WiFi: %s\n", WIFI_SSID);
    while (WiFi.status() != WL_CONNECTED) 
    {
        delay(500);
        Serial.print(".");
    }
    Serial.println("\n[+] WiFi Connected - ");
    Serial.println(WiFi.localIP());
}

void loop() 
{
    Serial.println("\n--- Sending Echo from Client ---");
    if (send_echo("Client says hello!")) 
    {
        Serial.println("Send Success");
    } 
    else 
    {
        Serial.println("Send Failed");
        client.stop();
    }
    delay(3000);
}