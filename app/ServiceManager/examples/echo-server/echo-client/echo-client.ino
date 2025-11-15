#include <WiFi.h>

const char* SSID = "Kasper&Ayumi-2.4GHz";
const char* PASSWORD = "jaghinner";

void setup() 
{
    Serial.begin(115200);
    WiFi.begin(ssid, password);
    Serial.print("[+] Connecting to WiFi . . .");
    while (WiFi.status() != WL_CONNECTED) 
    {
        delay(500);
        Serial.print(".");
    }
  Serial.println("\n[+] Connected - ");
  Serial.println(WiFi.localIP());
}

void loop() 
{

}
 