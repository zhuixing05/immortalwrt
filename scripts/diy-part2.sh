#!/bin/bash
# DIY Part 2 - ImmortalWrt 25.12-SNAPSHOT

sed -i 's/root:::0:99999:7:::/root:$1$V4UetPzk$CYXluq4wUazHjmCDBCqXF.::0:99999:7:::/g' package/base-files/files/etc/shadow

sed -i "s|DISTRIB_REVISION='.*'|DISTRIB_REVISION='R$(date +%Y.%m.%d)'|g" package/base-files/files/etc/openwrt_release
echo "DISTRIB_SOURCECODE='immortalwrt'" >> package/base-files/files/etc/openwrt_release

sed -i "s/192.168.1.1/192.168.133.1/g" package/base-files/files/bin/config_generate

rm -rf package/luci-theme-argon
git clone https://github.com/jerrykuku/luci-theme-argon.git package/luci-theme-argon

rm -rf package/luci-app-argon-config
git clone https://github.com/jerrykuku/luci-app-argon-config.git package/luci-app-argon-config

rm -rf package/frp
rm -rf package/luci-app-frpc
git clone https://github.com/breakertian/luci-app-frpc.git package/luci-app-frpc
git clone https://github.com/fatedier/frp.git package/frp

mkdir -p package/base-files/files/etc/uci-defaults

cat > package/base-files/files/etc/uci-defaults/99-custom-setup << 'EOF'
#!/bin/sh
exec >/tmp/setup.log 2>&1

# 主机名
uci set system.@system[0].hostname='KANTANROUTER'

# LAN IP
uci set network.lan.ipaddr='192.168.133.1'
uci commit network

# WiFi 配置
uci set wireless.@wifi-device[0].disabled='0'
uci set wireless.@wifi-iface[0].disabled='0'
uci set wireless.@wifi-iface[0].encryption='psk2'
uci set wireless.@wifi-iface[0].ssid='IkantanlWrt'
uci set wireless.@wifi-iface[0].key='kantanvpn'
uci commit wireless

# WAN 动态获取 IP
uci set network.wan.proto='dhcp'
uci commit network

# frpc 配置
uci -q delete frpc.main
uci set frpc.main=server
uci set frpc.main.server_addr='frp.zhixiang.us'
uci set frpc.main.server_port='7000'
uci set frpc.main.token='asdfghjkl'
uci set frpc.main.log_file='/var/log/frpc.log'
uci set frpc.main.log_level='info'

uci -q delete frpc.kantan_web
uci set frpc.kantan_web=proxy
uci set frpc.kantan_web.name='kantan_web'
uci set frpc.kantan_web.type='http'
uci set frpc.kantan_web.local_ip='127.0.0.1'
uci set frpc.kantan_web.local_port='880'
uci set frpc.kantan_web.custom_domains='kantan.zhixiang.us'
uci set frpc.kantan_web.use_encryption='1'
uci set frpc.kantan_web.use_compression='1'

uci commit frpc
/etc/init.d/frpc enable

echo "All done!"
EOF

chmod +x package/base-files/files/etc/uci-defaults/99-custom-setup
