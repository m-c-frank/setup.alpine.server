#!/bin/bash

# Base URL
BASE_URL="https://dl-cdn.alpinelinux.org/alpine/v3.18/releases/x86_64/"
KEY_URL="https://www.alpinelinux.org/keys/ncopa.asc"
VERSION="3.18.4"
ARCH="x86_64"
ISO_NAME="alpine-standard-${VERSION}-${ARCH}.iso"

# Define the files and their corresponding URLs
declare -A FILE_URLS=(
  ["$ISO_NAME"]="${BASE_URL}${ISO_NAME}"
  ["${ISO_NAME}.sha256"]="${BASE_URL}${ISO_NAME}.sha256"
  ["${ISO_NAME}.asc"]="${BASE_URL}${ISO_NAME}.asc"
  ["ncopa.asc"]="$KEY_URL"
)

PATH_OUT="./output"

create_output_dir() {
  mkdir -p "$PATH_OUT" && cd "$PATH_OUT" || exit 1
}

download_file() {
  local file=$1
  local url=$2
  echo "Downloading $file..."
  curl -o "$file" "$url" || { echo "Failed to download $file"; exit 1; }
}

download_files() {
  for file in "${!FILE_URLS[@]}"; do
    download_file "$file" "${FILE_URLS[$file]}"
  done
}

import_gpg_key() {
  echo "Importing GPG key..."
  gpg --import "ncopa.asc" || { echo "GPG key import failed"; exit 1; }
}

verify_checksum() {
  echo "Verifying the SHA256 checksum..."
  sha256sum -c "${ISO_NAME}.sha256" || { echo "Checksum verification failed!"; exit 1; }
  echo "Checksum verified successfully."
}

verify_gpg_signature() {
  echo "Verifying the GPG signature..."
  gpg --verify "${ISO_NAME}.asc" "${ISO_NAME}" || { echo "GPG signature verification failed!"; exit 1; }
  echo "GPG signature verified successfully."
}

main() {
  create_output_dir
  echo "Downloading Alpine Linux ISO, SHA256 checksum, GPG signature, and GPG key..."
  download_files
  import_gpg_key
  verify_checksum
  verify_gpg_signature
  echo "Download and verification completed successfully."
}

main

