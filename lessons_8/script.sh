#! /bin/bash 

function host_ping {
cat ssh_server.list | grep -Po '(?=^.{1,254}$)(^(?:(?!\d+\.)[a-zA-Z0-9_\-]{1,63}\.?)+(?:[a-zA-Z]{2,})$)' | xargs -r -n1 -I{} -t bash -c 'nc -z {} 22 2> /dev/null && echo {} >> avilable_host'
cat ssh_server.list | grep -Po '(?=^.{1,254}$)(^(?:(?!\d+\.)[a-zA-Z0-9_\-]{1,63}\.?)+(?:[a-zA-Z]{2,})$)' | xargs -r -n1 -I{} -t bash -c 'nc -z {} 22 2> /dev/null || echo {} >> error_conn'
cat ssh_server.list | grep -Po '(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)(\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)){3}' | xargs -r -n1 -I{} -t bash -c 'nc -z {} 22 2> /dev/null && echo {} >> avilable_host'
cat ssh_server.list | grep -Po '(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)(\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)){3}' | xargs -r -n1 -I{} -t bash -c 'nc -z {} 22 2> /dev/null || echo {} >> error_conn'
}

function host_info {
case $1 in
    "mem")
        cat avilable_host | xargs -r -t -n1 -I{} bash -c 'ssh -i ~/.ssh/terraform_key centos@{} free -h'
        ;;
    "cpu")
        cat avilable_host | xargs -r -t -n1 -I{} bash -c 'ssh -i ~/.ssh/terraform_key centos@{} cat /proc/cpuinfo'
        ;;
esac
}

if [ -s ssh_server.list ]; then
host_ping
else 
echo "file is emty or not found"
fi

if [ -s avilable_host ]; then
value=$(host_info $1)
echo "$value"
fi
