#!/bin/bash
# This file is managed by Ansible

SLEEP=30
MAX_TRIES=60
SERVERS="auth-dns.xjupiter.net."
DIG_OPT="+tcp +time=1 +tries=1 +short"

group_args() {
    local nl=$'\n'
    ARGS=''
    while [ "$1" ]; do ARGS="$ARGS$1 $2 $3$nl"; shift 3; done
    export ARGS
}

action=$1
shift

case $action in
    deploy_challenge)
        group_args "$@"
        echo -ne "$ARGS" | while read domain filename token; do
            echo "   >  updating DNS for $domain"
            username=''
            password=''
            . /usr/local/scripts/dehydrated-credentials.sh
            echo -n "   >  result from API: "
            curl -sS https://api.ddns.xjupiter.net/update -X POST -d "contents=$token" -K- <<< "--user $username:$password"
            echo "   >  waiting $SLEEP seconds for DNS to propagate"
            sleep $SLEEP
            echo "   >  checking DNS for $domain"
            i=0
            s=''
            for i in $(seq $MAX_TRIES); do
                for s in $SERVERS; do
                    if ! dig $DIG_OPT @$s $username TXT | grep -q -e $token; then
                        sleep $SLEEP
                        continue 2
                    fi
                done
                break
            done
            if [ "$i" -eq "$MAX_TRIES" ]; then
                echo "   >  challenge record not found in DNS"
                exit 1
            fi
        done
        ;;
    clean_challenge)
        systemctl reload apache2
        exit 0
        ;;
esac
