#! /bin/bash 
if [ -s avilable_host ] || [ -s error_conn ]; then
rm avilable_host
rm error_conn
fi

file=$(locate -b "\ssh_server.list")
hostname='(?=^.{1,254}$)(^(?:(?!\d+\.)[a-zA-Z0-9_\-]{1,63}\.?)+(?:[a-zA-Z]{2,})$)'
ip='(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)(\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)){3}'

function host_ping {
cat $file | grep -Po $hostname | xargs -r -n1 -I{} bash -c 'nc -z {} 22 2> /dev/null && echo {} >> avilable_host | echo {} enable; nc -z {} 22 2> /dev/null || echo {} >> error_conn | echo {} disable'
cat $file | grep -Po $ip | xargs -r -n1 -I{} bash -c 'nc -z {} 22 2> /dev/null && echo {} >> avilable_host | echo {} enable; nc -z {} 22 2> /dev/null || echo {} >> error_conn | echo {} disable'
}

function host_info {
case $1 in
    "mem")
        cat avilable_host | xargs -r -n1 -I{} bash -c 'echo ============ \ ; echo {} \ ; ssh -i ~/.ssh/terraform_key centos@{} free -h'
        ;;
    "cpu")
        cat avilable_host | xargs -r -n1 -I{} bash -c 'echo ============ \ ; echo {} \ ; ssh -i ~/.ssh/terraform_key centos@{} cat /proc/cpuinfo'
        ;;
esac
}

if [ -s "$file" ]; then
host_ping
else 
echo "file is not exist"
fi

if [ -s avilable_host ]; then
value=$(host_info $1)
echo "$value"
fi
