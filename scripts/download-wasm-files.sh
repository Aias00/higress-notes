#!/usr/bin/env bash

PLUGIN_NAME=${PLUGIN_NAME:-ai-proxy}
IMAGE_URL="higress-registry.cn-hangzhou.cr.aliyuncs.com/plugins/$PLUGIN_NAME:1.0.0"
if [ "$PLUGIN_NAME" == "mcp-server" ]; then
  IMAGE_URL="higress-registry.cn-hangzhou.cr.aliyuncs.com/mcp-server/all-in-one:1.0.0"
fi

set -e

trap "
  rm $PLUGIN_NAME.json > /dev/null
  rm $PLUGIN_NAME.tar.gz > /dev/null
" 0

oras manifest fetch $IMAGE_URL > $PLUGIN_NAME.json

WASM_SHA256=$(jq -r '.layers[] | select(.mediaType == "application/vnd.module.wasm.content.layer.v1+wasm") | .digest' $PLUGIN_NAME.json)
if [ -n "$WASM_SHA256" ]; then
  echo "Downloading wasm file from $WASM_SHA256 blob..."
  oras blob fetch $IMAGE_URL@$WASM_SHA256 --output $PLUGIN_NAME.wasm
  echo "Done"
  exit 0
fi

WASM_SHA256=$(jq -r '.layers[] | select(.mediaType == "application/vnd.docker.image.rootfs.diff.tar.gzip") | .digest' $PLUGIN_NAME.json)
if [ -z "$WASM_SHA256" ]; then
  WASM_SHA256=$(jq -r '.layers[] | select(.mediaType == "application/vnd.oci.image.layer.v1.tar+gzip") | .digest' $PLUGIN_NAME.json)
fi
if [ -n "$WASM_SHA256" ]; then
  echo "Downloading tgz from $WASM_SHA256 blob..."
  oras blob fetch $IMAGE_URL@$WASM_SHA256 --output $PLUGIN_NAME.tar.gz
  plugin_file_name=$(tar -zxvf $PLUGIN_NAME.tar.gz)
  mv $plugin_file_name $PLUGIN_NAME.wasm
  # rm -f $PLUGIN_NAME.tar.gz
  echo "Done"
  exit 0
fi

echo "Unsupport image format"
cat $PLUGIN_NAME.json | jq
exit 1
