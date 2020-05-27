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

echo "STARTING: _ARCADE-ORGANIZER"
echo ""

echo "Downloading the most recent _arcade-organizer script."
echo " "
wget -q -t 3 --output-file=/tmp/wget-log --show-progress -O /tmp/_arcade-organizer.sh https://raw.githubusercontent.com/MAME-GETTER/-------

chmod +x /tmp/_arcade-organizer.sh

/tmp/_arcade-organizer.sh

rm /tmp/_arcade-organizer.sh

echo "FINISHED: _ARCADE-ORGANIZER"
