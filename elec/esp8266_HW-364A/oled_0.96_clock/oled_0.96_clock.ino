#include <ESP8266WiFi.h>
#include <U8g2lib.h>
#include <time.h>
#include "cred.h"  // #define WIFI_SSID and WIFI_PASSWORD

#define OLED_RESET     U8X8_PIN_NONE // Reset pin (not used)
#define OLED_SDA 14                  // D6
#define OLED_SCL 12                  // D5

U8G2_SSD1306_128X64_NONAME_F_HW_I2C u8g2(U8G2_R0, OLED_RESET, OLED_SCL, OLED_SDA);

const char *ntpServer = "ntp.aliyun.com";
const long gmtOffsetSec = 8 * 3600;      // UTC+8
const int daylightOffsetSec = 0;

const char *daysOfWeek[] = {"Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"};

void drawOled(const char *line1, const char *line2) {
  u8g2.clearBuffer();

  // Date line - small font at top
  u8g2.setFont(u8g2_font_ncenB10_tr);
  if (line1) u8g2.drawStr(0, 15, line1);

  // Time line - large font, centered horizontally
  u8g2.setFont(u8g2_font_inr16_mf); 
  if (line2) {
    int x = (128 - u8g2.getStrWidth(line2)) / 2;
    u8g2.drawStr(x, 50, line2);
  }

  u8g2.sendBuffer();
}

void setup() {
  Serial.begin(115200);
  u8g2.begin();

  drawOled("Connecting WiFi...", WIFI_SSID);

  WiFi.mode(WIFI_STA);
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
  }

  drawOled("WiFi Connected", "Syncing NTP...");

  configTime(gmtOffsetSec, daylightOffsetSec, ntpServer);

  // Wait for NTP time to be valid
  time_t now = time(nullptr);
  while (now < 8 * 3600 * 2) {
    delay(500);
    now = time(nullptr);
  }
}

void loop() {
  time_t now = time(nullptr);
  struct tm *tm = localtime(&now);

  char dateLine[32];
  char timeLine[32];
  snprintf(dateLine, sizeof(dateLine), "%04d-%02d-%02d %s",
           tm->tm_year + 1900,
           tm->tm_mon + 1,
           tm->tm_mday,
           daysOfWeek[tm->tm_wday]);
  snprintf(timeLine, sizeof(timeLine), "%02d:%02d:%02d",
           tm->tm_hour,
           tm->tm_min,
           tm->tm_sec);

  drawOled(dateLine, timeLine);

  delay(1000);
}
