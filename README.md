# _arcade-organizer

A simple script to automate organizing MiSTer's \_Arcade directory based on your MRA files.

These scripts do not duplicate any cores or mra files; only soft symlinks are used.

_Note: These sylinks only work on MiSTer. If you mount your SD card outside of MiSTer, these symlinks will not work._

## Features

This script looks at what MRA files you have, and the information in them, to organize MiSTer's `\_Arcade` directory. 

If the XLM tags for _Year, Manufacturer, and Category_ are included in the MRA file, this script will create an `\_Organized` Directory in `\_Arcade` and will create the following sub-directories with soft sysmlinks to organize it:

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

**You can browse by:**

* Region
* Rotation (0-90-180-270 ± flip)
* Resolution (15-24-31kHz)
* Platform
* Series
* Move Inputs (8-way, 4-way, 2-way)
* Special Controls (spinner, wheel, etc)
* Number of Players
* Number of Buttons
* Decades
* Best-of Lists
* Homebrew
* Bootleg.

**"Top Additional Directories" toggle**

Allows you to include the extra folders that you choose in the top level of the organized directory: Platform, Core, Year

**"Chronological Sorting at the Botom" toggle**

By enabling this, every directory will include an additional chronologically sorted index at the bottom of the list.

**MAD metadata support**

- Support for the MAD metadata format allows improving the metadata of a game without having to change the game's MRA, being thus more flexible and lightweight.
- MAD database option: The new MAD_DB ini field allows you to you use different MAD databases with different metadata (for example, different categories).
- For resources for creating your own MAD database see: https://github.com/theypsilon/MAD_Database_MiSTer

## Instructions

Download the update_arcade-organizer.sh to the Scripts directory and run.

Alternately, run the update_all.sh script, and press Up on the keyboard to enter options, and access the arcade organizer suboptions which will look like this:

![screnshot of arcade organizer options in update all menu](https://i.imgur.com/MKGfco5.png)

You can optionally toggle to activate/deactivate specific folders. Deactivating unwanted folders will boost the speed of the script.

**_Disclaimer:_**

You should back up your \_Arcade directory before running this script. Use at your own risk. This script comes with no warranty.

**_Note if you use non-default folder paths:_**

This script uses:

a DEFAULT LOCATION for `_Arcade` at `/media/fat/_Arcade`

_and_

a DEFAULT LOCATION for `\_Organized` at `/media/fat/_Arcade/_Organized`

If your `\_Arcade` directory is in a diffrent location you MUST use a `/media/fat/Scripts/update_arcade-organizer.ini` file 

If you're not using the default locations for `\_Arcade` and `\_Organized`, you must add their locations in `/media/fat/Scripts/update_arcade-organizer.ini` 

## FAQ

**Q: How can I set my own custom locations for MRA and \_Organized Directories?**

A: A `/media/fat/Scripts/update_arcade-organizer.ini` file may be used to set custom location for your MRA files (Scans recursivly) and \_Organized files.
Add the following line to the ini file to set a directory for MRA files: `MRADIR=/top/path/to/mra/files/_Arcade`
Add the following line to the ini file to set a directory for Organized files: `ORGDIR=/path/to/organized/files/_Organized`

**Q:Will this script over write files I already have?**

A: NO, This script will not clober files you already have.


**Q: What If I get new MRA/Core files?**

A: You need to re-run the script to have them included in the Organized files.
