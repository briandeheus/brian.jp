#!/bin/bash

# Zola publish script
# Usage: ./publish.sh hostname target
# Example: ./publish.sh example.com /var/www/mysite

# Check if parameters are provided
if [ $# -ne 2 ]; then
    echo "Usage: $0 hostname target"
    echo "Example: $0 example.com /var/www/mysite"
    exit 1
fi

HOSTNAME=$1
TARGET=$2

echo "📝 Building Zola site..."
zola build

# Check if build was successful
if [ $? -ne 0 ]; then
    echo "❌ Zola build failed! Aborting."
    exit 1
fi

echo "🚚 Transferring files to $HOSTNAME:$TARGET..."
scp -r ./public/* "$HOSTNAME:$TARGET"

# Check if scp was successful
if [ $? -ne 0 ]; then
    echo "❌ File transfer failed!"
    exit 1
fi

echo "✅ Success! Your site has been published to $HOSTNAME:$TARGET"