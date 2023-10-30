#!/bin/bash

usage() {
    echo "Usage: MACLookup [MAC ADDRESS]"
    echo ""
    echo "Accepted formats:"
    echo "  - MACLookup FC:FB:FB:01:FA:21"
    echo "  - MACLookup FC-FB-FB-01-FA-21"
    echo "  - MACLookup FCFBFB01FA21"
}

download() {
    echo "Downloading.."
    
    while IFS= read -r line; do
        if [[ $line == *"(base 16)"* ]]; then
            echo "${line:0:6}${line:21}"
        fi
    done < <(curl -s "http://standards-oui.ieee.org/oui.txt")
    
    echo "Download finished!"
}

matchMAC() {
    local MAC="$1"
    
    while IFS= read -r address; do
        if [[ "${address:0:6}" == "$MAC" ]]; then
            echo "${address:8}"
            break
        fi
    done < "MAC_ADDRESS.txt"
}

main() {
    if [ $# -ne 1 ]; then
        usage
        return
    fi

    MAC=$(echo "$1" | tr -d ':' | tr -d '-')
    
    if ! [[ $MAC =~ ^[0-9A-Fa-f]{12}$ ]]; then
        echo "Invalid MAC address format!"
        echo ""
        usage
        return
    fi

    if [ ! -f "MAC_ADDRESS.txt" ]; then
        echo "MAC_ADDRESS.txt not found, would you like to download it? [y/n]: "
        read -r answer
        if [ "$answer" != "y" ]; then
            return
        else
            download > "MAC_ADDRESS.txt"
        fi
    fi

    matchMAC "${MAC:0:6}"
}

main "$@"
