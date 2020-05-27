#!/bin/bash
#USE AT YOUR OWN RISK - THIS COMES WITHOUT WARRANTE AND MAY NEUTER EVERYTHING.
#A /media/fat/Scripts/update_arcade-organizer.ini file may be used to set custom location for your MRA files (Scans recursivly) and Organized files.
#Add the following line to the ini file to set a directory for MRA files: MRADIR=/top/path/to/mra/files
#Add the following line to the ini file to set a directory for Organized files: ORGDIR=/path/to/_Organized 
############################################################################
#set -x

######VARS#####

INIFILE="/media/fat/Scripts/update_arcade-organizer.ini"
MRADIR="/media/fat/_Arcade/"
ORGDIR="/media/fat/_Arcade/_Organized"

#####INI FILES VARS######

if [ `grep -c "ORGDIR=" "${INIFILE}"` -gt 0 ] 
   then
      ORGDIR=`grep "ORGDIR" "${INIFILE}" | awk -F "=" '{print$2}'`
fi 2>/dev/null 


if [ `grep -c "MRADIR=" "${INIFILE}"` -gt 0 ] 
   then
      MRADIR=`grep "MRADIR=" "${INIFILE}" | awk -F "=" '{print$2}'`
fi 2>/dev/null

#####Create A-Z Directoies#####

mkdir -p "$ORGDIR/_1 A-E"
mkdir -p "$ORGDIR/_1 F-K"
mkdir -p "$ORGDIR/_1 L-Q"
mkdir -p "$ORGDIR/_1 R-T"
mkdir -p "$ORGDIR/_1 U-Z"

#####Extract MRA Info######

find $MRADIR -type f -name *.mra | while read i  
do
echo ""  
echo "path:"${i}"" 
MRA="$i"
echo "mra: `basename "$MRA"`"
MRB="`echo $MRA | sed 's/.*\///'`"
echo "name:`grep "<name>" "${i}" | sed -ne '/name/{s/.*<name>\(.*\)<\/name>.*/\1/p;q;}'`"
NAME=`grep "<name>" "${i}" | sed -ne '/name/{s/.*<name>\(.*\)<\/name>.*/\1/p;q;}'`
echo "year:`grep "<year>" "${i}" | sed -ne '/year/{s/.*<year>\(.*\)<\/year>.*/\1/p;q;}'`"
YEAR=`grep "<year>" "${i}" | sed -ne '/year/{s/.*<year>\(.*\)<\/year>.*/\1/p;q;}'`
echo "manufacturer:`grep "<manufacturer>" "${i}" | sed -ne '/manufacturer/{s/.*<manufacturer>\(.*\)<\/manufacturer>.*/\1/p;q;}'`"
MANU=`grep "<manufacturer>" "${i}" | sed -ne '/manufacturer/{s/.*<manufacturer>\(.*\)<\/manufacturer>.*/\1/p;q;}'`
echo "category:`grep "<category>" "${i}" | sed -ne '/category/{s/.*<category>\(.*\)<\/category>.*/\1/p;q;}'`"
CAT=`grep "<category>" "$i" | sed -ne '/category/{s/.*<category>\(.*\)<\/category>.*/\1/p;q;}' | tr -d '[:punct:]'` 

echo 

#####Create symlinks for A-Z######

if [[ "`basename "$MRA"`" == [A-Ea-e0-9]* ]] 
   then
        cd "$ORG/_1 A-E"
        [ -e ./"$MRB" ] || echo $PWD && ln -sv "$MRA" "`basename "$MRA"`" 2>/dev/null 

elif [[ "`basename "$MRA"`" == [F-Kf-k]* ]] 
   then
        cd "$ORG/_1 F-K"
        [ -e ./"$MRB" ] || echo $PWD && ln -sv "$MRA" "`basename "$MRA"`" 2>/dev/null 

elif [[ `basename "$MRA"` == [L-Ql-q]* ]] 
   then
        cd "$ORG/_1 L-Q"
        [ -e ./"$MRB" ] || echo $PWD && ln -sv "$MRA" "`basename "$MRA"`" 2>/dev/null 

elif [[ `basename "$MRA"` == [R-Tr-t]* ]] 
   then
        cd "$ORG/_1 R-T"
        [ -e ./"$MRB" ] || echo $PWD && ln -sv "$MRA" "`basename "$MRA"`" 2>/dev/null 

elif [[ `basename "$MRA"` == [U-Zu-z]* ]] 
   then
        cd "$ORG/_1 U-Z"
        [ -e ./"$MRB" ] || echo $PWD && ln -sv "$MRA" "`basename "$MRA"`" 2>/dev/null 
fi


#####Create symlinks for Year#####

if [ ! -e "$ORG/_2 Year/_$YEAR/$MRB" ] 
   then
      [ ! -z "$YEAR" ] && mkdir -p "$ORG/_2 Year/_$YEAR"
      [ ! -z "$YEAR" ] && echo && cd "$ORG/_2 Year/_$YEAR"
      [ ! -z "$YEAR" ] && echo $PWD && ln -v -s "$i" "$MRB"
fi 

#####Create symlinks for Manufacturer#####

if [ ! -e "$ORG/_3 Manufacturer/_$MANU/$MRB" ]
   then
      [ ! -z "$MANU" ] && mkdir -p "$ORG/_3 Manufacturer/_$MANU"
      [ ! -z "$MANU" ] && echo && cd "$ORG/_3 Manufacturer/_$MANU"
      [ ! -z "$MANU" ] && echo $PWD && ln -v -s "$i" "$MRB"
fi 

#####Create symlinks for Category#####

if [ ! -e "$ORG/_4 Category/_$CAT/$MRB" ]
   then
      [ ! -z "$CAT" ] && mkdir -p "$ORG/_4 Category/_$CAT"
      [ ! -z "$CAT" ] && echo && cd "$ORG/_4 Category/_$CAT"
      [ ! -z "$CAT" ] && echo $PWD && ln -v -s "$i" "$MRB"
fi 

echo "###############################################"
 #sleep 3 
done
