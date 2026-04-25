#!/usr/bin/sh

# https://community.ui.com/questions/UniFi-OS-DNS-settings/0385eae1-97da-4add-aee1-32d9d4ed0074
sleep 30
echo "cat /etc/resolv.conf | sed 's/203.0.113.113/2001:8b0:dc22:faff:dea6:32ff:fe0f:eff/' > /etc/resolv.conf.edited; cat /etc/resolv.conf.edited > /etc/resolv.conf; exit" | /usr/local/bin/uosserver shell
echo "UniFi OS DNS fixup applied"
