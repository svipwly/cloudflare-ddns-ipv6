#!/bin/bash

# Cloudflare API Token (set this as an environment variable or pass as argument)
CF_API_TOKEN="${CF_API_TOKEN:-<YOUR_CLOUDFLARE_API_TOKEN>}"
ZONE_NAME="<YOUR_ZONE_NAME>"
RECORD_NAME="<YOUR_DNS_RECORD_NAME>"  # e.g., home.example.com

# 获取Zone ID
ZONE_INFO=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones?name=${ZONE_NAME}" \
  -H "Authorization: Bearer ${CF_API_TOKEN}" \
  -H "Content-Type: application/json")

if [[ $(echo "$ZONE_INFO" | jq -r '.success') != "true" ]]; then
  echo "获取Zone ID失败: $ZONE_INFO"
  exit 1
fi
ZONE_ID=$(echo "$ZONE_INFO" | jq -r '.result[0].id')

# 获取DNS记录ID
RECORD_INFO=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/${ZONE_ID}/dns_records?name=${RECORD_NAME}" \
  -H "Authorization: Bearer ${CF_API_TOKEN}" \
  -H "Content-Type: application/json")

if [[ $(echo "$RECORD_INFO" | jq -r '.success') != "true" ]]; then
  echo "获取DNS记录ID失败: $RECORD_INFO"
  exit 1
fi
RECORD_ID=$(echo "$RECORD_INFO" | jq -r '.result[] | select(.type=="AAAA") | .id')

if [[ -z "$RECORD_ID" ]]; then
  echo "未找到指定的DNS记录"
  exit 1
fi

# 获取当前主机IPv6地址（公网）
IPV6=$(ip -6 addr | grep 'global' | grep -v 'temporary' | awk '{print $2}' | cut -d'/' -f1 | head -n 1)

if [[ -z "$IPV6" ]]; then
  echo "未检测到IPv6地址"
  exit 1
fi

# 更新DNS记录
RESULT=$(curl -s -X PATCH "https://api.cloudflare.com/client/v4/zones/${ZONE_ID}/dns_records/${RECORD_ID}" \
  -H "Authorization: Bearer ${CF_API_TOKEN}" \
  -H "Content-Type: application/json" \
  --data "{\"type\":\"AAAA\",\"name\":\"${RECORD_NAME}\",\"content\":\"${IPV6}\",\"ttl\":120,\"proxied\":false}")

echo "更新结果: $RESULT"

if [[ $(echo "$RESULT" | jq -r '.success') != "true" ]]; then
  echo "更新DNS记录失败: $RESULT"
  exit 1
fi

echo "DNS记录更新成功"
