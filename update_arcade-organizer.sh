#!/bin/bash
#set -x
#
#Simple scripts to automate organizing MiSTers _Arcade directory based on you MRA files.
#
#Instuctions:
#Download the update_arcade-organizer.sh to the Scripts directory and run.
#This script looks at what MRA files you have and the information in them to organize MiSTer's _Arcade directory.#
#If the XLM tags for Year, Manufacturer, and Category are included in the MRA file, this script will create an "_Organized" Directory in "_Arcade" and will create the following sub-directories with soft sysmlinks to organize it:
#
# _Organized
# ├── _1 A-E
# ├── _1 F-K
# ├── _1 L-Q
# ├── _1 R-T
# ├── _1 U-Z
# ├── _2 Year
# ├── _3 Manufacturer
# └── _4 Category
#
#These scripts DO NOT DUPLICATE any cores or mra files, only soft symlinks are used.
#THESE SYMLINKS ONLY WORK ON MISTER! IF YOU MOUNT YOUR SD CARD OUTSIDE OF MISTER THESE SYMLINKS WILL NOT WORK.
#
#Q: Can I set my own custom locations for MRA and _Organized Directories?
#A: A /media/fat/Scripts/update_arcade-organizer.ini file may be used to set custom location for your MRA files (Scans recursivly) and _Organized files. Add the following line to the ini file to set a directory for MRA files: MRADIR=/top/path/to/mra/files Add the following line to the ini file to set a directory for Organized files: ORGDIR=/path/to/organized/files/_Organized
#
#Q:Will this script over write files I already have?
#A: NO, This script will not clober files you already have.
#
#Q: What If I get new MRA/Core files?
#A: You need to re-run the script to have them included in the Organized files.
#
#You should back up your _Arcade directory before running this script.
#USE AT YOUR OWN RISK - THIS COMES WITHOUT WARRANTE AND MAY NEUTER EVERYTHING.
###############################################################################
# ========= OPTIONS ==================
ALLOW_INSECURE_SSL="true"
CURL_RETRY="--connect-timeout 15 --max-time 60 --retry 3 --retry-delay 5 --show-error"
# ========= CODE STARTS HERE =========

ORIGINAL_SCRIPT_PATH="${0}"
[[ "${ORIGINAL_SCRIPT_PATH}" == "bash" ]] && \
	ORIGINAL_SCRIPT_PATH="$(ps -o comm,pid | awk -v PPID=${PPID} '$2 == PPID {print $1}')"

INI_PATH="${ORIGINAL_SCRIPT_PATH%.*}.ini"
if [ -f "${INI_PATH}" ] ; then
    TMP=$(mktemp)
    dos2unix < "${INI_PATH}" 2> /dev/null | grep -v "^exit" > ${TMP} || true

    if [ $(grep -c "ALLOW_INSECURE_SSL=" "${TMP}") -gt 0 ] ; then
        ALLOW_INSECURE_SSL=$(grep "ALLOW_INSECURE_SSL=" "${TMP}" | awk -F "=" '{print$2}' | sed -e 's/^ *// ; s/ *$// ; s/^"// ; s/"$//')
    fi 2> /dev/null

    if [ $(grep -c "CURL_RETRY=" "${TMP}") -gt 0 ] ; then
        CURL_RETRY=$(grep "CURL_RETRY=" "${TMP}" | awk -F "=" '{print$2}' | sed -e 's/^ *// ; s/ *$// ; s/^"// ; s/"$//')
    fi 2> /dev/null

    rm ${TMP}
fi

SSL_SECURITY_OPTION=""

set +e
curl ${CURL_RETRY} "https://github.com" > /dev/null 2>&1
RET_CURL=$?
set -e

case ${RET_CURL} in
    0)
        ;;
    *)
        if [[ "${ALLOW_INSECURE_SSL}" == "true" ]]
        then
            SSL_SECURITY_OPTION="--insecure"
        else
            echo "CA certificates need"
            echo "to be fixed for"
            echo "using SSL certificate"
            echo "verification."
            echo "Please fix them i.e."
            echo "using security_fixes.sh"
            exit 2
        fi
        ;;
    *)
        echo "No Internet connection"
        exit 1
        ;;
esac

export SSL_SECURITY_OPTION
export CURL_RETRY

echo "STARTING: _ARCADE-ORGANIZER"
echo ""

echo "Downloading the most recent _arcade-organizer script."
echo " "
curl ${CURL_RETRY} ${SSL_SECURITY_OPTION} --location -o /tmp/_arcade-organizer.sh https://github.com/MAME-GETTER/_arcade-organizer/raw/master/_arcade-organizer.sh
echo

chmod +x /tmp/_arcade-organizer.sh
/tmp/_arcade-organizer.sh
rm /tmp/_arcade-organizer.sh

echo "FINISHED: _ARCADE-ORGANIZER"
