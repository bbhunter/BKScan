#!/bin/bash
#
# BlueKeep scanner
#
# Copyright 2019 NCC Group

usage()
{
    echo "Usage:"
    echo "./bkscan.sh -t <target_ip> [-P <target_port>] [-u <user>] [-p <password>] [--debug]"
    exit
}

if [ "$(whoami)" != "root" ]; then
    echo "[!] You need to be root to use the 'docker' command"
    exit 1
fi

RDP_USER=
RDP_PASSWORD=
TARGET_IP=
TARGET_PORT=3389
DEBUG=/log-level:OFF
while [[ $# -gt 0 ]]
do
    key="$1"

    case $key in
        -u|--user)
        RDP_USER="$2"
        shift # past argument
        ;;
        -p|--password)
        RDP_PASSWORD="$2"
        shift # past argument
        ;;
        -t|--target-ip)
        TARGET_IP="$2"
        shift # past argument
        ;;
        -P|--target-port)
        TARGET_PORT="$2"
        shift # past argument
        ;;
        -d|--debug)
        DEBUG=/log-level:TRACE
        ;;
        *)
        # unknown option
        usage
        ;;
    esac
    shift # past argument or value
done

if [[ -z $TARGET_IP ]]
then
    echo [!] Need a target IP
    usage
    exit 1
fi

echo [+] Targeting ${TARGET_IP}:${TARGET_PORT}...

if [[ ! -z $RDP_USER && ! -z $RDP_PASSWORD ]]
then
    echo [+] Using provided credentials, will support NLA
    docker run -it --rm --privileged \
      -e DISPLAY=$DISPLAY \
      -v /tmp/.X11-unix:/tmp/.X11-unix \
      bkscan \
      xfreerdp /cve-2019-0708 /cert-ignore /v:${TARGET_IP}:${TARGET_PORT} /u:${RDP_USER} /p:${RDP_PASSWORD} ${DEBUG}
else
    echo [+] No credential provided, won\'t support NLA
    docker run -it --rm --privileged \
      -e DISPLAY=$DISPLAY \
      -v /tmp/.X11-unix:/tmp/.X11-unix \
      bkscan \
      xfreerdp /cve-2019-0708 /cert-ignore /v:${TARGET_IP}:${TARGET_PORT} ${DEBUG}
fi