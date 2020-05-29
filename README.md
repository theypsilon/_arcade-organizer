# _arcade-organizer

A Simple script to automate organizing MiSTer's \_Arcade directory based on your MRA files.

Instructions:


Download the update_arcade-organizer.sh to the Scripts directory and run.

This script looks at what MRA files you have and the information in them to organize MiSTer's \_Arcade directory. 

If the XLM tags for Year, Manufacturer, and Category are included in the MRA file, this script will create an "\_Organized" Directory in "\_Arcade" and will create the following sub-directories with soft sysmlinks to organize it:

```
_Organized
├── _1 A-E
├── _1 F-K
├── _1 L-Q
├── _1 R-T
├── _1 U-Z
├── _2 Year
├── _3 Manufacturer
└── _4 Category
```
These scripts DO NOT DUPLICATE any cores or mra files, only soft symlinks are used.

THESE SYMLINKS ONLY WORK ON MISTER! IF YOU MOUNT YOUR SD CARD OUTSIDE OF MISTER THESE SYMLINKS WILL NOT WORK.

THIS SCRIP USES A DEFAULT LOCATION FOR `_Arcade at /media/fat/_Arcade`

AND

A DEFAULT LOCATION FOR \_Organized at `/media/fat/_Arcade/_Organized`

If your \_Arcade Directory is in a diffrent location you MUST use a `/media/fat/Scripts/update_arcade-organizer.ini` file 

If your not using the default locations for \_Arcade and \_Organized you must add their locations in `/media/fat/Scripts/update_arcade-organizer.ini` 

Q: How can I set my own custom locations for MRA and \_Organized Directories?

A: A `/media/fat/Scripts/update_arcade-organizer.ini` file may be used to set custom location for your MRA files (Scans recursivly) and \_Organized files.
Add the following line to the ini file to set a directory for MRA files: `MRADIR=/top/path/to/mra/files/_Arcade`
Add the following line to the ini file to set a directory for Organized files: `ORGDIR=/path/to/organized/files/_Organized`


Q:Will this script over write files I already have?

A: NO, This script will not clober files you already have.


Q: What If I get new MRA/Core files? 

A: You need to re-run the script to have them included in the Organized files.


**You should back up your \_Arcade directory before running this script.**

**USE AT YOUR OWN RISK - THIS COMES WITHOUT WARRANTE AND MAY NEUTER EVERYTHING.**
