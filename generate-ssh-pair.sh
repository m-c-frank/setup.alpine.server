#!/bin/bash

# Function to generate an SSH key pair
generate_ssh_key() {
    echo "Starting SSH key pair generation process using Ed25519 algorithm for enhanced security..."
    SSH_DIR="$HOME/.ssh"
    mkdir -p "$SSH_DIR" && echo "SSH directory set up successfully."

    read -rp "Enter a name for the SSH key file (without path): " SSH_KEY_FILENAME
    SSH_KEY_PATH="$SSH_DIR/$SSH_KEY_FILENAME"

    if [[ -f "$SSH_KEY_PATH" ]]; then
        echo "Error: A file already exists at $SSH_KEY_PATH. Please choose a different name."
        exit 1
    fi

    echo "Generating the SSH key pair..."
    ssh-keygen -t ed25519 -f "$SSH_KEY_PATH" && echo "SSH key pair generated successfully."

    PUB_KEY_PATH="$SSH_DIR/${SSH_KEY_FILENAME}.pub"
    echo "Public key path: $PUB_KEY_PATH"
}

# Function to list devices and get user input for the partition
select_partition() {
    echo "Available block devices and their partitions:"
    lsblk -p -o NAME,SIZE,TYPE,MOUNTPOINT,MODEL
    read -e -rp "Enter the partition path to write the SSH key (e.g., /dev/sdx1): " PARTITION

    if [[ ! -b "$PARTITION" ]]; then
        echo "Error: The specified partition does not exist."
        exit 1
    fi
}

# Function to write the SSH public key to the specified partition
write_key_to_partition() {
    MOUNT_POINT="/mnt/usb_ssh"
    sudo mkdir -p "$MOUNT_POINT"
    sudo mount "$PARTITION" "$MOUNT_POINT"

    sudo cp "$PUB_KEY_PATH" "$MOUNT_POINT/authorized_keys"
    echo "SSH public key has been copied to $PARTITION."

    sudo umount "$MOUNT_POINT"
}

# Main function
main() {
    generate_ssh_key
    select_partition
    write_key_to_partition
    echo "SSH key generation and placement on partition completed."
}

main

