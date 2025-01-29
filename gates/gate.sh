#!/bin/bash

# Check if OpenSSL is installed
if ! command -v openssl &> /dev/null
then
    echo "OpenSSL is not installed. Please install it and try again."
    exit 1
fi

# Usage function
usage() {
    echo "Usage: $0 -e|-d -f <directory> -p <password>"
    echo "  -e: Encrypt files"
    echo "  -d: Decrypt files"
    echo "  -f: Directory containing files"
    echo "  -p: Password for encryption/decryption"
    echo "  -h: Show this help message"
    exit 1
}

# Parse arguments
while getopts ":edf:p:h" opt; do
    case $opt in
        e) ENCRYPT=true ;;
        d) DECRYPT=true ;;
        f) DIR=$OPTARG ;;
        p) PASSWORD=$OPTARG ;;
        h) usage ;;
        *) usage ;;
    esac
done

# Ensure -e and -d are not called together
if [ "$ENCRYPT" == "true" ] && [ "$DECRYPT" == "true" ]; then
    echo "Error: -e and -d cannot be used together."
    usage
fi

# Ensure either -e or -d is provided
if [ -z "$ENCRYPT" ] && [ -z "$DECRYPT" ]; then
    echo "Error: Either -e or -d must be specified."
    usage
fi

# Ensure all required arguments are provided
if [ -z "$DIR" ] || [ -z "$PASSWORD" ]; then
    usage
fi

# Ensure the password is a non-empty string
if [ -z "$PASSWORD" ]; then
    echo "The -p flag requires a non-empty string as the password."
    exit 1
fi

# Ensure the directory exists
if [ ! -d "$DIR" ]; then
    echo "Directory $DIR does not exist."
    exit 1
fi

# Encrypt function
encrypt_files() {
    for file in "$DIR"/*; do
        if [ -f "$file" ]; then
            TEMP_FILE="$file.temp"
            openssl enc -aes-256-cbc -salt -in "$file" -out "$TEMP_FILE" -pass pass:"$PASSWORD"
            mv "$TEMP_FILE" "$file"
            echo "Encrypted: $file"
        fi
    done
}

# Decrypt function
decrypt_files() {
    for file in "$DIR"/*; do
        if [ -f "$file" ]; then
            TEMP_FILE="$file.temp"
            openssl enc -d -aes-256-cbc -in "$file" -out "$TEMP_FILE" -pass pass:"$PASSWORD"
            mv "$TEMP_FILE" "$file"
            echo "Decrypted: $file"
        fi
    done
}

# Perform the action
if [ "$ENCRYPT" == "true" ]; then
    encrypt_files
elif [ "$DECRYPT" == "true" ]; then
    decrypt_files
else
    usage
fi
