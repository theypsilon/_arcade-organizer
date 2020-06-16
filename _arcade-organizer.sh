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
SKIPALTS=AAA
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

#####Extract MRA Info######

organize_mra() {
echo ""
MRA="${1}"
MRB="`echo $MRA | sed 's/.*\///'`"
NAME=`grep "<name>" "$MRA" | sed -ne '/name/{s/.*<name>\(.*\)<\/name>.*/\1/p;q;}'`
CORE=`grep "<rbf" "$MRA" | sed 's/<\/rbf>//' | sed 's/<rbf.*>//' | sed -e 's/^[[:space:]]*//'`
CORE=`grep "<rbf" "$MRA" | sed 's/ alt=.*"//' | sed -ne '/rbf/{s/.*<rbf>\(.*\)<\/rbf>.*/\1/p;q;}'`
YEAR=`grep "<year>" "$MRA" | sed -ne '/year/{s/.*<year>\(.*\)<\/year>.*/\1/p;q;}'`
MANU=`grep "<manufacturer>" "$MRA" | sed -ne '/manufacturer/{s/.*<manufacturer>\(.*\)<\/manufacturer>.*/\1/p;q;}'`
CAT=`grep "<category>" "$MRA" | sed -ne '/category/{s/.*<category>\(.*\)<\/category>.*/\1/p;q;}' | tr -d '[:punct:]'`

echo "path:"$MRA""
echo "mra: `basename "$MRA"`"
echo "Name: $NAME"
echo "Core: $CORE"
echo "Year: $YEAR"
echo "Manufacturer: $MANU"
echo "Category: $CAT"

echo 

#####Create symlinks for A-Z######

if [[ "`basename "$MRA"`" == [A-Ea-e0-9]* ]] 
   then
        cd "$ORGDIR/_1 A-E"
        [ -e ./"$MRB" ] || echo $PWD && ln -sv "$MRA" "`basename "$MRA"`" 2>/dev/null 

elif [[ "`basename "$MRA"`" == [F-Kf-k]* ]] 
   then
        cd "$ORGDIR/_1 F-K"
        [ -e ./"$MRB" ] || echo $PWD && ln -sv "$MRA" "`basename "$MRA"`" 2>/dev/null 

elif [[ `basename "$MRA"` == [L-Ql-q]* ]] 
   then
        cd "$ORGDIR/_1 L-Q"
        [ -e ./"$MRB" ] || echo $PWD && ln -sv "$MRA" "`basename "$MRA"`" 2>/dev/null 

elif [[ `basename "$MRA"` == [R-Tr-t]* ]] 
   then
        cd "$ORGDIR/_1 R-T"
        [ -e ./"$MRB" ] || echo $PWD && ln -sv "$MRA" "`basename "$MRA"`" 2>/dev/null 

elif [[ `basename "$MRA"` == [U-Zu-z]* ]] 
   then
        cd "$ORGDIR/_1 U-Z"
        [ -e ./"$MRB" ] || echo $PWD && ln -sv "$MRA" "`basename "$MRA"`" 2>/dev/null 
fi


#####Create symlinks for Core#####

if [ ! -e "$ORGDIR/_2 Core/_$CORE/$MRB" ] 
   then
      [ ! -z "$YEAR" ] && mkdir -p "$ORGDIR/_2 Core/_$CORE"
      [ ! -z "$YEAR" ] && echo && cd "$ORGDIR/_2 Core/_$CORE"
      [ ! -z "$YEAR" ] && echo $PWD && ln -v -s "$MRA" "$MRB"
fi 

#####Create symlinks for Year#####

if [ ! -e "$ORGDIR/_3 Year/_$YEAR/$MRB" ] 
   then
      [ ! -z "$YEAR" ] && mkdir -p "$ORGDIR/_3 Year/_$YEAR"
      [ ! -z "$YEAR" ] && echo && cd "$ORGDIR/_3 Year/_$YEAR"
      [ ! -z "$YEAR" ] && echo $PWD && ln -v -s "$MRA" "$MRB"
fi 

#####Create symlinks for Manufacturer#####

if [ ! -e "$ORGDIR/_4 Manufacturer/_$MANU/$MRB" ]
   then
      [ ! -z "$MANU" ] && mkdir -p "$ORGDIR/_4 Manufacturer/_$MANU"
      [ ! -z "$MANU" ] && echo && cd "$ORGDIR/_4 Manufacturer/_$MANU"
      [ ! -z "$MANU" ] && echo $PWD && ln -v -s "$MRA" "$MRB"
fi 

#####Create symlinks for Category#####

if [ ! -e "$ORGDIR/_5 Category/_$CAT/$MRB" ]
   then
      [ ! -z "$CAT" ] && mkdir -p "$ORGDIR/_5 Category/_$CAT"
      [ ! -z "$CAT" ] && echo && cd "$ORGDIR/_5 Category/_$CAT"
      [ ! -z "$CAT" ] && echo $PWD && ln -v -s "$MRA" "$MRB"
fi 

echo "###############################################"
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
   printf '%s\n' "${MRA_FROM_FILE[@]}" | while read i
   do
      organize_mra "${i}"
   done
elif [ ${#} -ge 1 ] ; then
   echo "Invalid arguments."
   echo "Usage: ./${0} --input-file file"
   exit 1
else

   if [[ ${SKIPALTS^^} == *FALSE* ]] 
   	then 
		find $MRADIR -type f -name *.mra -not -path "$ORGDIR"/\* | sort | while read i
   		do
      			organize_mra "${i}"
		done
		
   elif [[ ${SKIPALTS^^} != *TRUE* ]] 
   	then 
		find $MRADIR -type f -name *.mra -not -ipath \*_Alternatives\* -not -path "$ORGDIR"/\* | sort | while read i
   		do
      			organize_mra "${i}"
		done
   fi
fi
