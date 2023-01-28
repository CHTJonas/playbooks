#!/bin/bash
# This file is managed by Ansible

SLEEP=30
MAX_TRIES=10
SERVERS="hildebrand.xjupiter.net."
DIG_OPT="+norec +tcp +time=1 +tries=1 +short"

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
        echo "   >  running deploy_challenge hooks"
        group_args "$@"
        echo -ne "$ARGS" | while read domain filename token; do
            echo "   >  updating DNS record for $domain with $token"
            username=''
            password=''
            . /usr/local/scripts/dehydrated-credentials.sh
            echo -n "   >  result from API: "
            curl -sS https://api.ddns.xjupiter.net/update -X POST -d "contents=$token" -K- <<< "--user $username:$password"
            echo "   >  waiting $SLEEP seconds for DNS changes to propagate"
            sleep $SLEEP
            i=0
            s=''
            for i in $(seq $MAX_TRIES); do
                echo "   >  checking DNS for $domain (attempt $i of $MAX_TRIES)"
                for s in $SERVERS; do
                    if ! dig $DIG_OPT @$s $username TXT | grep -q -e $token; then
                        if [ "$i" -eq "$MAX_TRIES" ]; then
                            echo "   >  failed"
                            echo "   >  challenge record not found in DNS"
                            exit 1
                        else
                            echo "   >  failed (will retry after $SLEEP seconds)"
                            sleep $SLEEP
                            continue 2
                        fi
                    fi
                done
                echo "   >  success"
                break
            done
        done
        ;;
    deploy_cert)
        echo "   >  running deploy_cert hooks"
        exec /usr/bin/run-parts -v /etc/dehydrated/deploy_cert-hooks
        ;;
    invalid_challenge)
        echo "   >  running invalid_challenge hook"
        echo "LetsEncrypt challenge for $1 was invalid" | mail -s "Dehydrated Renewal Failed" admin@xjupiter.net
        ;;
esac
