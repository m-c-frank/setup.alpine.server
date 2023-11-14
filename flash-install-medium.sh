#!/bin/bash

# Function to get the Alpine Linux ISO path
get_iso_path() {
    read -e -rp "Enter the path to the Alpine Linux ISO: " ISO_PATH
    if [[ ! -f "$ISO_PATH" ]]; then
        echo "Error: The specified ISO file does not exist."
        exit 1
    fi
}

# Function to list and select the USB drive
select_usb_drive() {
    echo "Available block devices:"
    lsblk -p -o NAME,SIZE,MODEL
    read -e -rp "Enter the device path for the USB drive (e.g., /dev/sdx): " DEVICE

    if [[ ! -b "$DEVICE" ]]; then
        echo "Error: The specified device does not exist."
        exit 1
    fi
}

# Function to confirm the selected device
confirm_selection() {
    echo "You have selected $DEVICE. This will ERASE ALL DATA on this device."
    read -rp "Are you sure you want to continue? (yes/no): " CONFIRM
    if [[ $CONFIRM != "yes" ]]; then
        echo "Operation aborted."
        exit 1
    fi
}

# Function to clean the USB drive and create partitions
partition_drive() {
    echo "Wiping existing file system signatures on $DEVICE..."
    sudo wipefs --all $DEVICE

    echo "Partitioning $DEVICE..."

    # Create two partitions
    # First partition: 90% of the drive for Alpine Linux
    # Second partition: Remaining space, left empty for future use
    sudo parted $DEVICE --script mklabel gpt
    sudo parted $DEVICE --script mkpart primary ext4 1MiB 90%
    sudo parted $DEVICE --script mkpart primary ext4 90% 100%

    # Update the system's partition table
    sudo partprobe $DEVICE
    sleep 2
}

# Function to format the second partition
format_second_partition() {
    local second_part=$(ls ${DEVICE}* | grep -E "${DEVICE}p?2$")
    echo "Formatting ${second_part} as ext4..."
    sudo mkfs.ext4 $second_part
}

# Function to flash the ISO to the first partition
flash_iso() {
    local first_part=$(ls ${DEVICE}* | grep -E "${DEVICE}p?1$")
    echo "Flashing Alpine Linux to ${first_part}..."
    sudo dd if="$ISO_PATH" of="$first_part" bs=4M status=progress oflag=sync
    sync
}

# Main function
main() {
    get_iso_path
    select_usb_drive
    confirm_selection
    partition_drive
    format_second_partition
    flash_iso
    echo "Alpine Linux setup completed on $DEVICE. The second partition is formatted and ready for use."
}

main

