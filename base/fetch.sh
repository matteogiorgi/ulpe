#!/usr/bin/env bash

# System information Bash script, thought as
# welcome message for interactive shells.




### Info
########

MYNAME=$(whoami)
MYHOST=$(cat /proc/sys/kernel/hostname)
MYOSYS=$(. /etc/os-release; echo "${NAME}")
MYKERNEL=$(awk -F- '{print $1}' /proc/sys/kernel/osrelease)
MYSHELL=$(basename "${SHELL}")




### Palette
###########

C0='[00m'
CB='[01m'
C4='[1;34m'
C5='[1;35m'
C6='[1;36m'




### Output
##########

printf '%s\n' "${C5}  .   .   ${C4}${MYNAME}${C0}${CB}@${C4}${MYHOST}"
printf '%s\n' "${C5}  |\_/|   ${C6}OS${C0}      ${MYOSYS}"
printf '%s\n' "${C5}  (${C0}${CB}O${C5}.${C0}${CB}o${C5})   ${C6}Kernel${C0}  ${MYKERNEL}"
printf '%s\n' "${C5}  (> <)   ${C6}Shell${C0}   ${MYSHELL}"
printf "\n"
