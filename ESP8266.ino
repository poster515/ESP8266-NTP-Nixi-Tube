/*
 This code is meant for the Adafruit Huzzah. It will perdiodically ask 
 */

#include <ESP8266WiFi.h>
#include <WiFiUdp.h>
#include <Wire.h>

#define FPGA_REGISTER 0x32 // Hexadecima address for the Altera FPGA internal register.

char ssid[] = "Never Rong";       //  your network SSID (name)
char pass[] = "Sixty_2_Sixteen";    // your network password
 

unsigned int localPort = 2390;      // local port to listen for UDP packets

//GPIO 4 and 5 are I2C SDA and SCL respectively
int ESP8266_SCL = 5;
int ESP8266_SDL = 4;

//preamble for FPGA detection
byte FPGA_ADDRESS = 0xFF;

/* Don't hardwire the IP address or we won't get the benefits of the pool.
 *  Lookup the IP address for the host name instead */
//IPAddress timeServer(129, 6, 15, 28); // time.nist.gov NTP server

IPAddress timeServerIP; // time.nist.gov NTP server address
const char* ntpServerName = "time.nist.gov";

const int NTP_PACKET_SIZE = 48; // NTP time stamp is in the first 48 bytes of the message

byte packetBuffer[ NTP_PACKET_SIZE ]; //buffer to hold incoming and outgoing packets

// A UDP instance to let us send and receive packets over UDP
WiFiUDP udp;

//byte[3] for saving time data in usable serial format
byte formattedHour;
byte formattedMinute;
byte formattedSecond;

void setup()
{
  Serial.begin(115200);
  Serial.println();
  Serial.println();

  // We start by connecting to a WiFi network
  Serial.print("Connecting to ");
  Serial.println(ssid);
  WiFi.begin(ssid, pass);
  
  Wire.begin(); // Initiate the Wire library
  
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  //Serial.println("");
  
  Serial.println("WiFi connected");
  Serial.println("IP address: ");
  Serial.println(WiFi.localIP());

  //Serial.println("Starting UDP");
  udp.begin(localPort);
  //Serial.print("Local port: ");
  //Serial.println(udp.localPort());
}
byte reformatHour(unsigned long unixTime);
byte reformatMinute(unsigned long unixTime);
byte reformatSecond(unsigned long unixTime);
void loop()
{
  //first, get unsigned long time format (i.e., 4 bytes representing seconds since 1900)
  unsigned long unixTime = getTime();
  
  byte formattedHour = reformatHour(unixTime);
  byte formattedMinute = reformatMinute(unixTime);
  byte formattedSecond = reformatSecond(unixTime);
  
  updateAltera(formattedHour, formattedMinute, formattedSecond);
  
  delay(500);
  
}

unsigned long getTime(){
    //get a random server from the pool
  WiFi.hostByName(ntpServerName, timeServerIP); 

  sendNTPpacket(timeServerIP); // send an NTP packet to a time server
  // wait to see if a reply is available
  delay(1000);
  
  int cb = udp.parsePacket();
  while (!cb) {
    cb = udp.parsePacket();
    //Serial.println("no packet yet");
    //do nothing, no packet yet
  }
  
    //Serial.print("packet received, length=");
    //Serial.println(cb);
    // We've received a packet, read the data from it
    udp.read(packetBuffer, NTP_PACKET_SIZE); // read the packet into the buffer

    //the timestamp starts at byte 40 of the received packet and is four bytes,
    // or two words, long. First, esxtract the two words:

    unsigned long highWord = word(packetBuffer[40], packetBuffer[41]);
    unsigned long lowWord = word(packetBuffer[42], packetBuffer[43]);
    // combine the four bytes (two words) into a long integer
    // this is NTP time (seconds since Jan 1 1900):
    unsigned long secsSince1900 = highWord << 16 | lowWord;
    //Serial.print("Seconds since Jan 1 1900 = " );
    //Serial.println(secsSince1900);

    // now convert NTP time into everyday time:
    //Serial.print("Unix time = ");
    // Unix time starts on Jan 1 1970. In seconds, that's 2208988800:
    const unsigned long seventyYears = 2208988800UL;
    // subtract seventy years:
    unsigned long epoch = secsSince1900 - seventyYears;
    // print Unix time:
    Serial.println(epoch);
  
  return epoch;
}

// send an NTP request to the time server at the given address
unsigned long sendNTPpacket(IPAddress& address)
{
  //Serial.println("sending NTP packet...");
  // set all bytes in the buffer to 0
  memset(packetBuffer, 0, NTP_PACKET_SIZE);
  // Initialize values needed to form NTP request
  // (see URL above for details on the packets)
  packetBuffer[0] = 0b11100011;   // LI, Version, Mode
  packetBuffer[1] = 0;     // Stratum, or type of clock
  packetBuffer[2] = 6;     // Polling Interval
  packetBuffer[3] = 0xEC;  // Peer Clock Precision
  // 8 bytes of zero for Root Delay & Root Dispersion
  packetBuffer[12]  = 49;
  packetBuffer[13]  = 0x4E;
  packetBuffer[14]  = 49;
  packetBuffer[15]  = 52;

  // all NTP fields have been given values, now
  // you can send a packet requesting a timestamp:
  udp.beginPacket(address, 123); //NTP requests are to port 123
  udp.write(packetBuffer, NTP_PACKET_SIZE);
  udp.endPacket();
}

boolean updateAltera(byte hour, byte minute, byte second){
  //now that we have the Unix time, need to send some serial data to the Altera FPGA
  //in the following format:
  /*
      | 8-bit hour | 8-bit minute | 8-bit second |
  */
//this is essentially just 3 bytes of data to send serially.
  //send MSB first for all bytes
Serial.println("Time sent: ");
  sendSerial(hour);
  Serial.print(hour, DEC);
  Serial.print(":");
  sendSerial(minute);
  Serial.print(minute, DEC);
  Serial.print(":");
  sendSerial(second);
  Serial.println(second, DEC);

}

byte reformatHour(unsigned long unixTime){
  byte hour = ((unixTime  % 86400L) / 3600) - 4;
  Serial.print("Hour: ");
  Serial.println(hour, DEC);
  return hour;
}

byte reformatMinute(unsigned long unixTime){
  byte minute = (unixTime  % 3600) / 60; // get the minute (3600 equals secs per minute)
  Serial.println("Minute: ");
  Serial.println(minute, DEC);
  return minute;
}

byte reformatSecond(unsigned long unixTime){
  byte second = unixTime % 60;
  Serial.println("Second: ");
  Serial.println(second, DEC);
  return second;
}

void sendSerial(byte data){
  Wire.beginTransmission(FPGA_ADDRESS);
  Wire.write(data);
  Wire.endTransmission();
  
}

