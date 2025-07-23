# cloudflare-ddns-ipv6

## 1 安装必要工具
```
sudo apt update
sudo apt install curl jq
```

## 2 主目录下的 bin 子目录创建脚本
```
mkdir -p ~/bin
nano ~/bin/cloudflare-ddns-ipv6.sh
```

## 3 赋予执行权限
```
chmod +x ~/bin/cloudflare-ddns-ipv6.sh
```

## 4 测试脚本
```
~/bin/cloudflare-ddns-ipv6.sh
```

## 5 配置自动定时更新
```
crontab -e
```
```
*/5 * * * * /home/yourusrname/bin/cloudflare-ddns-ipv6.sh
```
