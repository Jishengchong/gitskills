#!/home/linuxbrew/.linuxbrew/bin/fish

set hostip (cat /etc/resolv.conf | grep nameserver | awk '{ print $2 }')
set wslip (hostname -I | awk '{print $1}')
set port 7890
set PROXY_HTTP "http://$hostip:$port"
set PROXY_SOCKS5 "socks5://$hostip:$port"

function set_proxy
    set -gx http_proxy $PROXY_HTTP
    set -gx HTTP_PROXY $PROXY_HTTP
    set -gx https_proxy $PROXY_HTTP
    set -gx HTTPS_PROXY $PROXY_HTTP
    set -gx all_proxy $PROXY_SOCKS5
    set -gx ALL_PROXY $PROXY_SOCKS5
    git config --global http.proxy $PROXY_SOCKS5
    echo "Proxy has been opened."
end

function unset_proxy
    set -e http_proxy
    set -e HTTP_PROXY
    set -e https_proxy
    set -e HTTPS_PROXY
    set -e all_proxy
    set -e ALL_PROXY
    git config --global --unset http.proxy
    echo "Proxy has been closed."
end

function test_setting
    echo "Host IP: $hostip"
    echo "WSL IP: $wslip"
    echo "Try to connect to Google..."
    set resp (curl -I -s --connect-timeout 5 -m 5 -w "%{http_code}" -o /dev/null www.google.com)
    if [ $resp -eq 200 ]
        echo "Proxy setup succeeded!"
    else
        echo "Proxy setup failed!"
        fi
    end
end

if [ "$argv[1]" = set ]
    set_proxy
else if [ "$argv[1]" = unset ]
    unset_proxy
else if [ "$argv[1]" = test ]
    test_setting
else
    echo "Unsupported arguments."
end
