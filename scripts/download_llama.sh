#!/bin/bash
set -e

# Go to ios directory
cd "$(dirname "$0")/../ios"

echo "Downloading llama.xcframework..."
curl -L -o llama.zip https://github.com/ggml-org/llama.cpp/releases/download/b5046/llama-b5046-xcframework.zip

echo "Extracting..."
unzip -q llama.zip -d llama_temp

echo "Moving xcframework..."
rm -rf llama.xcframework
mv llama_temp/build-apple/llama.xcframework .

echo "Cleaning up..."
rm -rf llama_temp llama.zip

echo "Done! llama.xcframework is ready in ios/"
