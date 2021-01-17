#!/bin/bash
#set -x
#
#Simple script to rebuild cached rotation information from MAME
#
#Instuctions:
#This is _only_ used by _arcade-organizer devs to build a 
#cached copy of mame-rotations.txt
#Which is then used at runtime for organizing the MRA files by the 
#native rotation of the screen
#
#It will clone the latest MAME repo, and then look in the MAME drivers folder
#and extract the rotational information, and cache it to a file in the local
#folder called mame-rotations.txt.  
#The intention is for this file to be committed to the organizer repo on rare occasions
#i.e. https://github.com/MAME-GETTER/_arcade-organizer
#
# by @j6wbs 2020
#
#You should back up your _Arcade directory before running this script.
#USE AT YOUR OWN RISK - THIS COMES WITHOUT WARRANTE AND MAY NEUTER EVERYTHING.
###############################################################################
echo "STARTING: REGENERATION-OF-MAME_ROTATIONS"
echo ""

echo "Cloning the MAME repo."
echo " "
git clone https://github.com/mamedev/mame.git

echo " "
echo "Extracting simple rotation information from the MAME driver files..."
grep GAME mame/src/mame/drivers/*|grep ROT |cut -d"," -f2,8|grep -v FLIP|sed -e 's/ //g'|grep ROT[0-9]*$|sort -u > mame-rotations.txt

echo " "
echo "Replacing MAME values with some overriden values (e.g. dkong appears to be ROT90 on MiSTer and not ROT270 as MAME reports)"
while read line; do sed -i "s/^`echo ${line}|cut -d, -f1`,.*/${line}/g" mame-rotations.txt; done < override-rotations.txt

echo " "
echo "Adding additional rotations"
cat additional-rotations.txt >> mame-rotations.txt
sort -o mame-rotations.txt mame-rotations.txt

echo "Done. The new mame-rotations.txt file should be ready for committing to the repo. "
echo " "
echo "Summary..."
cut -d"," -f2 mame-rotations.txt |sort|uniq -c

echo "FINISHED: _REGENERATION-OF-MAME_ROTATIONS"
