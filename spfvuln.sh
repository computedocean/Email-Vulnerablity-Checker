#!/bin/bash

# Function to display help message
function display_help {
    echo -e "\033[1;33mUsage: $0 [-h] [-v] [-t <file>] [-d <domain>] [-o <output.txt>]\033[0m"
    echo -e "\033[1;34mOptions:\033[0m"
    echo -e "  \033[1;36m-h, --help               Show this help section\033[0m"
    echo -e "  \033[1;36m-v                       Show the tool version\033[0m"
    echo -e "  \033[1;36m-t, --target <file>      Use a text file containing a list of domains to check\033[0m"
    echo -e "  \033[1;36m-d <domain>              The domain to check (if not using the -t option)\033[0m"
    echo -e "  \033[1;36m-o <output.txt>          Save output to a file\033[0m"
    exit 0
}

# Function to display tool version
function display_version {
    echo -e "\033[1;34mEmail Vulnerability Checker Version 2.1\033[0m"
    exit 0
}

# Function to display banner
function banner {
    echo ""
    echo -e "\033[1;33m============================================================\033[0m"
    echo -e "\033[1;36m       This Email Vulnerability Checker is created by\033[0m"
    echo -e "\033[1;32m                  BLACK-SCORP10\033[0m"
    echo ""
    echo -e "\e[1;34m               For Any Queries Join Me!!!\e[0m"
    echo -e "\e[1;32m           Telegram: https://t.me/BLACK-SCORP10 \e[0m"
    echo ""
    echo -e "\033[1;33m============================================================\033[0m"
    echo ""
}

# Function to check SPF and DMARC configurations and determine vulnerability status
function check_vulnerability {
    local domain=$1
    local spf_response=$(nslookup -type=TXT "$domain" | grep -Eo '\s*-all|\s*~all|\s*\+all|\s*\?all|\s*redirect' || echo "no spf")

    local dmarc_response=$(nslookup -type=TXT "_dmarc.$domain" | grep -Eo '\s* p=reject|\s* p=quarantine|\s* p=none|\s*no answer' || echo "no answer")

    # Trim leading and trailing spaces from SPF and DMARC responses
    spf_response=$(echo "$spf_response" | sed -e 's/^[[:space:]]//' -e 's/[[:space:]]$//')
    dmarc_response=$(echo "$dmarc_response" | sed -e 's/^[[:space:]]//' -e 's/[[:space:]]$//')

    # Determine vulnerability status based on trimmed SPF and DMARC responses
    case "$spf_response $dmarc_response" in
        "-all p=reject")       vulnerability_status="Not Vulnerable"; color="\033[0;32m";;
        "-all p=quarantine")   vulnerability_status="Less Vulnerable"; color="\033[1;33m";;
        "-all p=none")         vulnerability_status="Vulnerable"; color="\033[0;31m";;
        "-all no answer")    vulnerability_status="Vulnerable"; color="\033[0;31m";;
        "~all p=reject")       vulnerability_status="Less Vulnerable"; color="\033[1;33m";;
        "~all p=quarantine")   vulnerability_status="More Vulnerable"; color="\033[0;31m";;
        "~all p=none")         vulnerability_status="Vulnerable"; color="\033[0;31m";;
        "~all no answer")    vulnerability_status="Vulnerable"; color="\033[0;31m";;
        "+all p=reject")       vulnerability_status="Vulnerable"; color="\033[0;31m";;
        "+all p=quarantine")   vulnerability_status="More Vulnerable"; color="\033[0;31m";;
        "+all p=none")         vulnerability_status="Vulnerable"; color="\033[0;31m";;
        "+all no answer")    vulnerability_status="Vulnerable"; color="\033[0;31m";;
        "?all p=reject")       vulnerability_status="Vulnerable"; color="\033[0;31m";;
        "?all p=quarantine")   vulnerability_status="More Vulnerable"; color="\033[0;31m";;
        "?all p=none")         vulnerability_status="Vulnerable"; color="\033[0;31m";;
        "?all no answer")    vulnerability_status="Vulnerable"; color="\033[0;31m";;
        "no spf p=reject")     vulnerability_status="Vulnerable"; color="\033[0;31m";;
        "no spf p=quarantine") vulnerability_status="More Vulnerable"; color="\033[0;31m";;
        "no spf p=none")       vulnerability_status="Highly Vulnerable"; color="\033[0;31m";;
        "no spf no answer")  vulnerability_status="Highly Vulnerable"; color="\033[0;31m";;
        *)                   vulnerability_status="Consider Redirect Mechanism"; color="\033[1;34m";;
    esac

    echo -e "\033[1;36mDomain: $domain - SPF: $spf_response - DMARC: $dmarc_response - Vulnerability Status: $color$vulnerability_status\033[0m"
}

# Main script
if [[ $# -eq 0 ]]; then
    echo -e "\033[0;31mError: No arguments provided.\033[0m"
    display_help
fi

while [[ $# -gt 0 ]]; do
    key="$1"

    case $key in
        -h|--help)
            display_help
            ;;
        -v)
            display_version
            ;;
        -t|--target)
            target_file="$2"
            shift
            ;;
        -d)
            domain="$2"
            shift
            ;;
        -o)
            output_file="$2"
            exec > "$output_file"  # Redirect stdout to output file
            shift
            ;;
        *)
            echo -e "\033[0;31mError: Invalid argument: $key\033[0m"
            display_help
            ;;
    esac
    shift
done

banner

if [[ -n $target_file ]]; then
    while IFS= read -r line; do
        check_vulnerability "$line"
    done < "$target_file"
elif [[ -n $domain ]]; then
    check_vulnerability "$domain"
else
    echo -e "\033[0;31mError: No domain specified.\033[0m"
    display_help
fi

# This code is made and owned by BLACK-SCORP10.
# Feel free to contact me at https://t.me/BLACK_SCORP10
