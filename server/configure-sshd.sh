#!/bin/sh

# Path to SSH configuration
SSH_CONFIG="/etc/ssh/sshd_config"

# Function to configure SSH for key-based authentication
configure_ssh() {
    echo "Configuring SSH for key-based authentication..."

    # Backup the original SSH configuration file
    cp $SSH_CONFIG "${SSH_CONFIG}.backup"

    # Disable password authentication
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' $SSH_CONFIG
    sed -i 's/PasswordAuthentication yes/PasswordAuthentication no/' $SSH_CONFIG

    # Disable challenge-response authentication
    sed -i 's/#ChallengeResponseAuthentication yes/ChallengeResponseAuthentication no/' $SSH_CONFIG
    sed -i 's/ChallengeResponseAuthentication yes/ChallengeResponseAuthentication no/' $SSH_CONFIG

    # Disable PAM (Pluggable Authentication Modules) if necessary
    sed -i 's/UsePAM yes/UsePAM no/' $SSH_CONFIG

    # Restart SSH service to apply changes
    echo "Restarting SSH service..."
    /etc/init.d/sshd restart
}

# Main function
main() {
    # Ensure the script is run as root
    if [ "$(id -u)" -ne 0 ]; then
        echo "This script must be run as root."
        exit 1
    fi

    configure_ssh
    echo "SSH has been configured for key-based authentication."
}

main

