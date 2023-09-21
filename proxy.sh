#!/bin/bash

hostip=$(cat /etc/resolv.conf | grep nameserver | awk '{ print $2 }')
wslip=$(hostname -I | awk '{print $1}')
port=7890
PROXY_HTTP="http://${hostip}:${port}"
PROXY_SOCKS5="socks5://${hostip}:${port}"

set_proxy() {
	export http_proxy="${PROXY_HTTP}"
	export HTTP_PROXY="${PROXY_HTTP}"
	export https_proxy="${PROXY_HTTP}"
	export HTTPS_PROXY="${PROXY_HTTP}"
	export all_proxy="${PROXY_SOCKS5}"
	export ALL_PROXY="${PROXY_SOCKS5}"
	git config --global http.proxy ${PROXY_SOCKS5}
	echo "Proxy has been opened."
}

unset_proxy() {
	unset http_proxy
	unset HTTP_PROXY
	unset https_proxy
	unset HTTPS_PROXY
	unset all_proxy
	unset ALL_PROXY
	git config --global --unset http.proxy
	echo "Proxy has been closed."
}

test_setting() {
	echo "Host IP:" ${hostip}
	echo "WSL IP:" ${wslip}
	echo "Try to connect to Google..."
	resp=$(curl -I -s --connect-timeout 5 -m 5 -w "%{http_code}" -o /dev/null www.google.com)
	if [ ${resp} = 200 ]; then
		echo "Proxy setup succeeded!"
	else
		echo "Proxy setup failed!"
	fi
}

if [ "$1" = "set" ]; then
	set_proxy
elif [ "$1" = "unset" ]; then
	unset_proxy
elif [ "$1" = "test" ]; then
	test_setting
else
	echo "Unsupported arguments."
fi
