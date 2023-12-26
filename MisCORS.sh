#!/bin/bash


N='\033[0m'
R='\033[0;31m'
G='\033[0;32m'
O='\033[0;33m'
B='\033[0;34m'
Y='\033[0;38m'
C='\033[0;36m'
W='\033[0;37m'


function banner() {
    echo "******************************************"
    echo "*                MisCORS                 *"
    echo "*    CORS Hunter / Vulnerability Tool    *"
    echo "*      ----------------------------      *"
    echo "*                        by @ImKKingshuk *"
    echo "* Github- https://github.com/ImKKingshuk *"
    echo "******************************************"
    echo
}


function check_internet() {
    echo -e "${O}[+] Checking Internet Connectivity\n"
    sleep 2
    if [[ "$(ping -c 1 8.8.8.8 | grep '100% packet loss')" != "" ]]; then
        echo "No Internet Connection"
        exit 1
    else
        echo "Internet is present"
        sleep 2
    fi
}


function cors_check_advanced() {
    local site="$1"
    local output_format="$2"
    local output_file="output.$output_format"
    local timeout=5  

    echo -e -n "${CNC}\n[+] Searching For CORS Misconfiguration on $site\n"
    
  
    ICT=$(curl -s --max-time "$timeout" -Iv "$site" -H "Origin: evil.com" 2>&1)

   
    case $output_format in
        "json")
            echo -e "{ \"url\": \"$site\", \"result\": {" > "$output_file"
            ;;
        *)
            echo -e "\nURL: $site" > "$output_file"
            ;;
    esac
    echo "$ICT" >> "$output_file"

  
    if grep -q evil <<<"$ICT"; then
        echo -e "${R}URL: $site  [Vulnerable]\n"
        grep -e evil -e access-control-allow-credentials: "$output_file"
    else
        echo -e "${G}URL: $site  [Not Vulnerable]\n"
    fi

    case $output_format in
        "json")
            echo -e "}}}" >> "$output_file"
            ;;
    esac
}


function interactive_mode() {
    local option

    echo -e "${O}[+] Interactive Mode"
    echo -e "${O}[+] Options:"
    echo -e "${O}[1] Perform CORS check"
    echo -e "${O}[2] Exit"

    read -r -p "[?] Choose an option: " option

    case $option in
        1)
            echo -e -n "${CNC}\n[+] Enter Site (e.g https://site-url.com) : "
            read -r site

            echo -e "${O}[+] Choose Output Format:"
            echo -e "${O}[1] Normal text"
            echo -e "${O}[2] JSON"
            
            read -r -p "[?] Choose an option: " output_option

            case $output_option in
                1)
                    output_format="txt"
                    ;;
                2)
                    output_format="json"
                    ;;
                *)
                    echo -e "${R}[!] Invalid output format option. Defaulting to normal text."
                    output_format="txt"
                    ;;
            esac

            cors_check_advanced "$site" "$output_format"
            ;;
        2)
            echo -e "${O}[+] Exiting..."
            exit 0
            ;;
        *)
            echo -e "${R}[!] Invalid option. Exiting..."
            exit 1
            ;;
    esac
}


trap 'printf "\e[1;77m \n Ctrl+C was pressed, exiting...\n\n \e[0m"; exit 0' 2

banner
check_internet

clear
banner


while true; do
    interactive_mode
done
