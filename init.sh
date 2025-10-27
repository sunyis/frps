#!/bin/sh
echo "检查配置文件..."
if [ ! -f /frp/config/frps.ini ]; then
    echo "初始化 frps.ini 配置文件..."
    cp /frp/default-config/frps.ini /frp/config/frps.ini
else
    echo "使用现有的 frps.ini 配置文件"
fi
echo "添加自定义 hosts 条目..."
cat /frp/default-config/custom-hosts >> /etc/hosts
echo "启动 frps..."
exec /frp/frps -c /frp/config/frps.ini