ls -l /etc/config/gl-client
grep -E "option (mac|alias)" /etc/config/gl-client | sed ':a;N;s/\n\s*option alias/, alias/g;'