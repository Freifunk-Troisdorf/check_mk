#!/bin/bash
#/usr/lib/check_mk_agent/plugins

# based upon 'qemu' from
# 12/2010 Matthias Henze
# Lizenz: GPL v2
#
# updated for libvirtd (virsh) by
# Jonathan Mills 09/2011
#
# updated by
# Christian Burmeister 05/2015
# updated by
# adorfer 01/2017 for proxmox 4 pve

if which qm >/dev/null ; then
        echo '<<<qemu>>>'
        qm list | grep -v VMID | while read L
        do
                if [[ ! -z $L ]]; then
                        ID=$(echo $L | awk '{print $1}')
                        NAME=$(echo $L | awk '{print $2}')
                        STATE=$(echo $L | awk '{print $3}')
                        PID=$(ps aux | grep kvm | grep $NAME | head -1 | tail -1| awk '{print $2}')
                        if [[ ! -z $PID ]] && [ "$PID" -gt "0" ]; then
                                PS=$(ps aux | grep kvm | grep $PID | head -1|tail -1)
                                MEM=$(echo $PS|awk -- '{print $5}')
                                MEM=$(echo $MEM / 1024 | bc)
                                DATA=$(top -p $PID -n 1 -b | tail -1)
                                PCPU=$(echo $DATA | awk -- '{print $9}'|tr , .)
                                PMEM=$(echo $DATA | awk -- '{print $10}'|tr , .)
                                MCPU=$(echo $PS | sed 's/.*maxcpus=\([^ ]*\)\ .*/\1/' )
                                RCPU=$(echo "scale=1; $PCPU / $MCPU"| bc)
                        else
                                DATA=""
                        fi
                        echo $ID" "$NAME" "$STATE" "$MEM" "$RCPU" "$PMEM
                fi
        done
fi