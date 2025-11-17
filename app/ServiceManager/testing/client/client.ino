// Humidity Sensor - HW-080

#include <WiFi.h>
#include <time.h>

#include <pb_encode.h>
#include <pb_decode.h>
#include <pb_common.h>

#include "impl/sensor-data-collection-service/sensor-data-collection-service.pb.h"
#include "include/google/protobuf/timestamp.pb.h"

#include "secrets.h"

const char* ntpServer = "pool.ntp.org";
const long  gmtOffset_sec = 0;
const int   daylightOffset_sec = 3600;

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

bool reportSensorData(int humidityPercent) 
{
    if (!client.connected()) 
    {
        Serial.println("[/] Connecting to server . . .");
        if (!client.connect(SERVER_HOST, SERVER_PORT)) 
        {
            Serial.println("[-] Connection failed . . .");
            return false;
        }
        Serial.println("[+] Connected . . .");
    }

    sensor_data_collection_SensorData msg = sensor_data_collection_SensorData_init_zero;
    msg.humidityPercent = humidityPercent;
    msg.has_sendAt = true;
    msg.sendAt = make_timestamp();

    uint8_t buffer[256];
    pb_ostream_t stream = pb_ostream_from_buffer(buffer, sizeof(buffer));

    if (!pb_encode(&stream, sensor_data_collection_SensorData_fields, &msg)) 
    {
        Serial.printf("Encode failed: %s\n", PB_GET_ERROR(&stream));
        return false;
    }

    size_t msg_len = stream.bytes_written;
    Serial.printf("[/] Sending SensorData (%d bytes): humidity=%d%% . . .\n", msg_len, humidityPercent);

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
        delay(10);

    if (client.available() < 4) 
    {
        Serial.println("[-] Timeout waiting for heartbeat response . . .");
        return false;
    }

    uint32_t resp_len = 0;
    resp_len |= (uint32_t)client.read() << 24;
    resp_len |= (uint32_t)client.read() << 16;
    resp_len |= (uint32_t)client.read() << 8;
    resp_len |= (uint32_t)client.read();

    Serial.printf("[+] Response length: %u bytes . . .\n", resp_len);

    if (resp_len > sizeof(buffer)) 
    {
        Serial.println("[-] Response too large . . .");
        return false;
    }

    timeout = millis() + 5000;
    while (client.available() < (int)resp_len && millis() < timeout)
        delay(10);

    if (client.available() < (int)resp_len)
    {
        Serial.println("[-] Timeout waiting response body . . .");
        return false;
    }

    client.readBytes(buffer, resp_len);

    ServicePackage_BaseHeartbeat hb = ServicePackage_BaseHeartbeat_init_zero;
    pb_istream_t in_stream = pb_istream_from_buffer(buffer, resp_len);

    if (!pb_decode(&in_stream, ServicePackage_BaseHeartbeat_fields, &hb)) 
    {
        Serial.printf("[-] Decoding of heartbeat failed: %s . . .\n", PB_GET_ERROR(&in_stream));
        return false;
    }

    Serial.printf("[+] Server responded with heartbeat id=%d . . .\n", hb.id);

    return true;
}

int dryValue = 4095;
int wetValue = 2150;

const int sensorPowerPin = 4;
const int sensorAnalogPin = 35;

int meassureTimeInMs = 2000;

int waitTimeBetweenSensorReadInMs = 4000;

void setup() 
{
  Serial.begin(115200);
  Serial.println("\n=== ESP32 Echo Client ===");
  delay(1000);

  pinMode(sensorPowerPin, OUTPUT);
  digitalWrite(sensorPowerPin, LOW);

  WiFi.begin(WIFI_SSID, WIFI_PASS);
  Serial.printf("[/] Connecting to WiFi: %s . . .\n", WIFI_SSID);
  while (WiFi.status() != WL_CONNECTED) 
  {
    delay(500);
    Serial.print(".");
  }
  Serial.println("\n[+] WiFi Connected - ");
  Serial.println(WiFi.localIP()); 

  configTime(gmtOffset_sec, daylightOffset_sec, ntpServer);
  Serial.println("[/] Waiting for time sync . . .");
  time_t now;
  while ((now = time(nullptr)) < 24 * 3600) 
  {
        delay(500);
        Serial.print(".");
  }
  Serial.println("\n[+] Time synchronized . . .");
}

google_protobuf_Timestamp make_timestamp() 
{
    google_protobuf_Timestamp ts = google_protobuf_Timestamp_init_zero;

    time_t now = time(NULL);
    
    ts.seconds = now;
    ts.nanos = 0;

    return ts;
}

int meassureHumidityInPercent()
{
  digitalWrite(sensorPowerPin, HIGH);
  delay(meassureTimeInMs);

  int sensorValue = analogRead(sensorAnalogPin);

  digitalWrite(sensorPowerPin, LOW);

  int moisturePercent = map(sensorValue, dryValue, wetValue, 0, 100);
  moisturePercent = constrain(moisturePercent, 0, 100);

  return moisturePercent;
}

void loop() 
{
  Serial.println("\n--- Sending DataReport from Client ---");
  int moisturePercent = meassureHumidityInPercent();

  Serial.print("Moisture: ");
  Serial.print(moisturePercent);
  Serial.println("%");

  if (reportSensorData(moisturePercent))
  {
    Serial.println("[+] Send and Receive - Success . . .");
  }
  else 
  {
    Serial.println("[+] Send or Receive - Failed . . .");
    client.stop();
  }
  
  delay(waitTimeBetweenSensorReadInMs);
}