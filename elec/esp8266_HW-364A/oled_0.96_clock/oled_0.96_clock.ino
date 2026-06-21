#include <ESP8266WiFi.h>
#include <U8g2lib.h>
#include <time.h>
#include <string.h>
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

  if (line2) {
    size_t len = strlen(line2);
    // Render time with large HH:MM and small :SS
    if (len == 8 && line2[2] == ':' && line2[5] == ':') {
      char hhmm[6];
      char ss[4];
      strncpy(hhmm, line2, 5);
      hhmm[5] = '\0';
      strncpy(ss, line2 + 5, 3);
      ss[3] = '\0';

      const int timeBaseY = 55; // below 3/4 of 64px screen

      u8g2.setFont(u8g2_font_inr19_mf);
      int hhmmWidth = u8g2.getStrWidth(hhmm);
      u8g2.setFont(u8g2_font_ncenB10_tr);
      // 用固定占位符计算秒数宽度，避免秒数变化导致 line2 整体水平偏移
      int ssWidth = u8g2.getStrWidth(":00");
      int x = (128 - (hhmmWidth + ssWidth)) / 2;

      u8g2.setFont(u8g2_font_inr19_mf);
      u8g2.drawStr(x, timeBaseY, hhmm);
      x += hhmmWidth;
      u8g2.setFont(u8g2_font_ncenB10_tr);
      u8g2.drawStr(x, timeBaseY, ss);
    } else {
      // Status/other message - small font, centered, below 3/4 height
      u8g2.setFont(u8g2_font_ncenB10_tr);
      int x = (128 - u8g2.getStrWidth(line2)) / 2;
      u8g2.drawStr(x, 55, line2);
    }
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
