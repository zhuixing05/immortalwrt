#!/bin/bash
# DIY Part 2 - After Update feeds（ImmortalWrt Master）

# 设置 root 密码为 kantanvpn
sed -i 's/root:::0:99999:7:::/root:$1$V4UetPzk$CYXluq4wUazHjmCDBCqXF.::0:99999:7:::/g' package/base-files/files/etc/shadow

# 修改版本描述
sed -i "s|DISTRIB_REVISION='.*'|DISTRIB_REVISION='R$(date +%Y.%m.%d)'|g" package/base-files/files/etc/openwrt_release
echo "DISTRIB_SOURCECODE='immortalwrt'" >> package/base-files/files/etc/openwrt_release

# 添加 Argon 主题
rm -rf package/luci-theme-argon
git clone https://github.com/jerrykuku/luci-theme-argon.git package/luci-theme-argon

rm -rf package/luci-app-argon-config
git clone https://github.com/jerrykuku/luci-app-argon-config.git package/luci-app-argon-config

# 添加 frpc（如需）
rm -rf package/luci-app-frpc
git clone https://github.com/breakertian/luci-app-frpc.git package/luci-app-frpc

echo "diy-part2.sh 执行完成"
