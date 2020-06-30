#!/bin/bash
#USE AT YOUR OWN RISK - THIS COMES WITHOUT WARRANTE AND MAY NEUTER EVERYTHING.
#A /media/fat/Scripts/update_arcade-organizer.ini file may be used to set custom location for your MRA files (Scans recursivly) and Organized files.
#Add the following line to the ini file to set a directory for MRA files: MRADIR=/top/path/to/mra/files
#Add the following line to the ini file to set a directory for Organized files: ORGDIR=/path/to/_Organized 
###############################################################################
#set -x

######VARS#####

INIFILE="/media/fat/Scripts/update_arcade-organizer.ini"
MRADIR="/media/fat/_Arcade/"
ORGDIR="/media/fat/_Arcade/_Organized"
SKIPALTS="true"
#####INI FILES VARS######

INIFILE_FIXED=$(mktemp)
if [ -f "${INIFILE}" ] ; then
	dos2unix < "${INIFILE}" 2> /dev/null > ${INIFILE_FIXED}
fi

if [ `grep -c "ORGDIR=" "${INIFILE_FIXED}"` -gt 0 ]
   then
      ORGDIR=`grep "ORGDIR" "${INIFILE_FIXED}" | awk -F "=" '{print$2}' | sed -e 's/^ *//' -e 's/ *$//' -e 's/^ *"//' -e 's/" *$//'`
fi 2>/dev/null


if [ `grep -c "MRADIR=" "${INIFILE_FIXED}"` -gt 0 ]
   then
      MRADIR=`grep "MRADIR=" "${INIFILE_FIXED}" | awk -F "=" '{print$2}' | sed -e 's/^ *//' -e 's/ *$//' -e 's/^ *"//' -e 's/" *$//'`
fi 2>/dev/null

 
if [ `grep -c "SKIPALTS=" "${INIFILE_FIXED}"` -gt 0 ]
   then
      SKIPALTS=`grep "SKIPALTS=" "${INIFILE_FIXED}" | awk -F "=" '{print$2}' | sed -e 's/^ *//' -e 's/ *$//' -e 's/^ *"//' -e 's/" *$//'`
fi 2>/dev/null
 
rm ${INIFILE_FIXED}

#####Create A-Z Directoies#####

mkdir -p "$ORGDIR/_1 A-E"
mkdir -p "$ORGDIR/_1 F-K"
mkdir -p "$ORGDIR/_1 L-Q"
mkdir -p "$ORGDIR/_1 R-T"
mkdir -p "$ORGDIR/_1 U-Z"

#####Build names.txt Dictionary#####

declare -A NAMES_TXT
if [ -f /media/fat/names.txt ]
   then
      IFS=$'\n'
      for LINE in $(grep ':' /media/fat/names.txt)
      do
         if [[ $LINE =~ ^[[:space:]]*([a-zA-Z0-9\_-]+)[[:space:]]*:[[:space:]]*([[:graph:]]+([[:space:]]+[[:graph:]]+)*)[[:space:]]*$ ]]
            then
               NAMES_TXT[${BASH_REMATCH[1]}]="${BASH_REMATCH[2]}"
         fi
      done
      unset IFS
fi

#####Extract MRA Info######

header() {
   printf '%-44s' "MRA"
   printf ' %-10s' "Core"
   printf ' %-4s' "Year"
   printf ' %-10s' "Manufactu."
   printf ' %-8s' "Category"
   echo
   echo "################################################################################"
}

organize_mra() {
MRA="${1}"
MRB="`echo $MRA | sed 's/.*\///'`"
NAME=`grep "<name>" "$MRA" | sed -ne '/name/{s/.*<name>\(.*\)<\/name>.*/\1/p;q;}'`
CORE=`grep "<rbf" "$MRA" | sed 's/ alt=.*"//' | sed -ne '/rbf/{s/.*<rbf>\(.*\)<\/rbf>.*/\1/p;q;}'`
YEAR=`grep "<year>" "$MRA" | sed -ne '/year/{s/.*<year>\(.*\)<\/year>.*/\1/p;q;}'`
MANU=`grep "<manufacturer>" "$MRA" | sed -ne '/manufacturer/{s/.*<manufacturer>\(.*\)<\/manufacturer>.*/\1/p;q;}'`
CAT=`grep "<category>" "$MRA" | sed -ne '/category/{s/.*<category>\(.*\)<\/category>.*/\1/p;q;}' | tr -d '[:punct:]'`

local BASENAME_MRA="`basename "$MRA"`"
printf '%-44s' "${BASENAME_MRA:0:44}"
printf ' %-10s' "${CORE:0:10}"
printf ' %-4s' "${YEAR:0:4}"
printf ' %-10s' "${MANU:0:10}"
printf ' %-8s' "${CAT:0:8}"
echo

local CORE_NAME="${NAMES_TXT[$CORE]}"
if [[ "${CORE_NAME}" != "" ]]
   then
      CORE="${CORE_NAME}"
fi

#####Create symlinks for A-Z######

if [[ ""${BASENAME_MRA}"" == [A-Ea-e0-9]* ]]
   then
        cd "$ORGDIR/_1 A-E"
        [ -e ./"$MRB" ] || ln -sv "$MRA" ""${BASENAME_MRA}"" >/dev/null 2>&1

elif [[ ""${BASENAME_MRA}"" == [F-Kf-k]* ]]
   then
        cd "$ORGDIR/_1 F-K"
        [ -e ./"$MRB" ] || ln -sv "$MRA" ""${BASENAME_MRA}"" >/dev/null 2>&1

elif [[ "${BASENAME_MRA}" == [L-Ql-q]* ]]
   then
        cd "$ORGDIR/_1 L-Q"
        [ -e ./"$MRB" ] || ln -sv "$MRA" ""${BASENAME_MRA}"" >/dev/null 2>&1

elif [[ "${BASENAME_MRA}" == [R-Tr-t]* ]]
   then
        cd "$ORGDIR/_1 R-T"
        [ -e ./"$MRB" ] || ln -sv "$MRA" ""${BASENAME_MRA}"" >/dev/null 2>&1

elif [[ "${BASENAME_MRA}" == [U-Zu-z]* ]]
   then
        cd "$ORGDIR/_1 U-Z"
        [ -e ./"$MRB" ] || ln -sv "$MRA" ""${BASENAME_MRA}"" >/dev/null 2>&1
fi


#####Create symlinks for Core#####

if [ ! -z "$CORE" ] && [ ! -e "$ORGDIR/_2 Core/_$CORE/$MRB" ] 
   then
      mkdir -p "$ORGDIR/_2 Core/_${CORE//\?/X}"
      cd "$ORGDIR/_2 Core/_${CORE//\?/X}"
      ln -v -s "$MRA" "$MRB" >/dev/null 2>&1
fi 

#####Create symlinks for Year#####

if [ ! -z "$YEAR" ] && [ ! -e "$ORGDIR/_3 Year/_$YEAR/$MRB" ] 
   then
      mkdir -p "$ORGDIR/_3 Year/_${YEAR//\?/X}"
      cd "$ORGDIR/_3 Year/_${YEAR//\?/X}"
      ln -v -s "$MRA" "$MRB" >/dev/null 2>&1
fi 

#####Create symlinks for Manufacturer#####

if [ ! -z "$MANU" ] && [ ! -e "$ORGDIR/_4 Manufacturer/_$MANU/$MRB" ]
   then
      mkdir -p "$ORGDIR/_4 Manufacturer/_${MANU//\?/X}"
      cd "$ORGDIR/_4 Manufacturer/_${MANU//\?/X}"
      ln -v -s "$MRA" "$MRB" >/dev/null 2>&1
fi 

#####Create symlinks for Category#####

if [ ! -z "$CAT" ] && [ ! -e "$ORGDIR/_5 Category/_$CAT/$MRB" ]
   then
      mkdir -p "$ORGDIR/_5 Category/_${CAT//\?/X}"
      cd "$ORGDIR/_5 Category/_${CAT//\?/X}"
      ln -v -s "$MRA" "$MRB" >/dev/null 2>&1
fi 

# sleep 1
}

if [ ${#} -eq 2 ] && [ ${1} == "--input-file" ] ; then
   MRA_INPUT="${2:-}"
   if [ ! -f ${MRA_INPUT} ] ; then
      echo "Option --input-file selected, but file '${MRA_INPUT}' does not exist."
      echo "Usage: ./${0} --input-file file"
      exit 1
   fi
   echo "Organizing $(wc -l ${MRA_INPUT} | awk '{print $1}') MRAs."
   echo
   IFS=$'\n'
   MRA_FROM_FILE=($(cat ${MRA_INPUT}))
   unset IFS
   header
   printf '%s\n' "${MRA_FROM_FILE[@]}" | while read i
   do
      organize_mra "${i}"
   done
elif [ ${#} -ge 1 ] ; then
   echo "Invalid arguments."
   echo "Usage: ./${0} --input-file file"
   exit 1
else
   header
   if [[ "${SKIPALTS^^}" == "FALSE" ]]
   	then 
		find $MRADIR -type f -name *.mra -not -path "$ORGDIR"/\* | sort | while read i
   		do
      			organize_mra "${i}"
		done
		
   else
		find $MRADIR -type f -name *.mra -not -ipath \*_Alternatives\* -not -path "$ORGDIR"/\* | sort | while read i
   		do
      			organize_mra "${i}"
		done
   fi
fi
echo "################################################################################"