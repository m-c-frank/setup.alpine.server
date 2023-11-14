#!/bin/bash

# URLs
ISO_URL="https://dl-cdn.alpinelinux.org/alpine/v3.18/releases/x86_64/alpine-standard-3.18.4-x86_64.iso"
SHA256_URL="https://dl-cdn.alpinelinux.org/alpine/v3.18/releases/x86_64/alpine-standard-3.18.4-x86_64.iso.sha256"
GPG_URL="https://dl-cdn.alpinelinux.org/alpine/v3.18/releases/x86_64/alpine-standard-3.18.4-x86_64.iso.asc"
GPG_KEY_URL="https://www.alpinelinux.org/keys/ncopa.asc"

# Download the ISO, SHA256, GPG files, and GPG Key
echo "Downloading Alpine Linux ISO, SHA256 checksum, GPG signature, and GPG key..."
curl -O "$ISO_URL"
curl -O "$SHA256_URL"
curl -O "$GPG_URL"
curl -O "$GPG_KEY_URL"

# Import the GPG key
echo "Importing GPG key..."
gpg --import ncopa.asc

# Verify the SHA256 checksum
echo "Verifying the SHA256 checksum..."
sha256sum -c alpine-standard-3.18.4-x86_64.iso.sha256

if [ $? -ne 0 ]; then
    echo "Checksum verification failed!"
    exit 1
else
    echo "Checksum verified successfully."
fi

# Verify the GPG signature
echo "Verifying the GPG signature..."
gpg --verify alpine-standard-3.18.4-x86_64.iso.asc alpine-standard-3.18.4-x86_64.iso

if [ $? -ne 0 ]; then
    echo "GPG signature verification failed!"
    exit 1
else
    echo "GPG signature verified successfully."
fi

echo "Download and verification completed successfully."

