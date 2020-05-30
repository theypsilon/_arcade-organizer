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

#####Create A-Z Directories#####

mkdir -p "$ORGDIR/_1 "{A-E,F-K,L-Q,R-T,U-Z}

#####Extract MRA Info######

find $MRADIR -type f -name *.mra -not -path "$ORGDIR"/\* | sort | while read i  
do
echo ""  
MRA="$i"
MRB="`echo $MRA | sed 's/.*\///'`"
NAME=`grep "<name>" "${i}" | sed -ne '/name/{s/.*<name>\(.*\)<\/name>.*/\1/p;q;}'`
CORE=`grep "<rbf" "${i}" | sed 's/<\/rbf>//' | sed 's/<rbf.*>//' | sed -e 's/^[[:space:]]*//'`
CORE=`grep "<rbf" "${i}" | sed 's/ alt=.*"//' | sed -ne '/rbf/{s/.*<rbf>\(.*\)<\/rbf>.*/\1/p;q;}'`
YEAR=`grep "<year>" "${i}" | sed -ne '/year/{s/.*<year>\(.*\)<\/year>.*/\1/p;q;}'`
MANU=`grep "<manufacturer>" "${i}" | sed -ne '/manufacturer/{s/.*<manufacturer>\(.*\)<\/manufacturer>.*/\1/p;q;}'`
CAT=`grep "<category>" "$i" | sed -ne '/category/{s/.*<category>\(.*\)<\/category>.*/\1/p;q;}' | tr -d '[:punct:]'` 

echo "path:"${i}"" 
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
      [ ! -z "$YEAR" ] && echo $PWD && ln -v -s "$i" "$MRB"
fi 

#####Create symlinks for Year#####

if [ ! -e "$ORGDIR/_3 Year/_$YEAR/$MRB" ] 
   then
      [ ! -z "$YEAR" ] && mkdir -p "$ORGDIR/_3 Year/_$YEAR"
      [ ! -z "$YEAR" ] && echo && cd "$ORGDIR/_3 Year/_$YEAR"
      [ ! -z "$YEAR" ] && echo $PWD && ln -v -s "$i" "$MRB"
fi 

#####Create symlinks for Manufacturer#####

if [ ! -e "$ORGDIR/_4 Manufacturer/_$MANU/$MRB" ]
   then
      [ ! -z "$MANU" ] && mkdir -p "$ORGDIR/_4 Manufacturer/_$MANU"
      [ ! -z "$MANU" ] && echo && cd "$ORGDIR/_4 Manufacturer/_$MANU"
      [ ! -z "$MANU" ] && echo $PWD && ln -v -s "$i" "$MRB"
fi 

#####Create symlinks for Category#####

if [ ! -e "$ORGDIR/_5 Category/_$CAT/$MRB" ]
   then
      [ ! -z "$CAT" ] && mkdir -p "$ORGDIR/_5 Category/_$CAT"
      [ ! -z "$CAT" ] && echo && cd "$ORGDIR/_5 Category/_$CAT"
      [ ! -z "$CAT" ] && echo $PWD && ln -v -s "$i" "$MRB"
fi 

echo "###############################################"
# sleep 1 
done
