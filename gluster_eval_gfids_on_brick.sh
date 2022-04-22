#!/bin/bash
# 
# Copyright (C) 2022 D Simpson - code building upon resolve-gfid.sh to take input from 'gluster volume heal VOLNMAME info'
# Copyright (C) 2019 B Tasker - code to resolve gfid path taken from resolve-gfid.sh
#
# Before executing this, it's recommended you look at your 'gluster volume heal VOLNAME info' output
# That will tell you which bricks to get this script to run against
#
# 1. Supply a brick path and a gluster voulume name 
# 2. Obtain a list of heal entries for that brick ON THIS HOST
# 3. Work out the path it represents (i.e.where it points to if you were accessing via GlusterFS).
# 4. Print and store each path in log
# 5. You can then (elsewhere) perform ls on the mounted volume (client) to trigger healing


if [[ "$#" -lt "2" || "$#" -gt "3" ]]
then
cat << END
Glusterfs GFID resolver -- turns a GFID into a real file path

Usage: $0 <brick-path> <volume> [-q]

<brick-path> : The path to your glusterfs brick (required). ON THIS HOST.
               It is assumed brickXX/brick will be within this path.
               e.g. /mnt/VOL/brickXX/brick

<volume> : volume containing the gfids you wish to resolve to a real path (required). ON THIS HOST.

-q : quieter output (optional)
    with this option only the actual resolved path is printed.
    without this option $0 will print the GFID, 
    whether it identifies a file or directory, and the resolved
    path to the real file or directory.

Theory:
The .glusterfs directory in the brick root has files named by GFIDs
If the GFID identifies a directory, then this file is a symlink to the
actual directory.  If the GFID identifies a file then this file is a
hard link to the actual file.

END

exit

fi

# Get brick and GFID from the cmdline
BRICK="$1"
VOLUME_NAME="$2"
QUIET="$3"

#setup mktemp
BRICK_NUM=`echo ${BRICK} | egrep -o "brick[0-9][0-9]?"`
TMP_LOG=`mktemp --suffix _${VOLUME_NAME}_${BRICK_NUM}`

#NOTE LIMIT TO -A 1000 here ... meaning 1000 gfids for the brick being examined, if you have more these won't be grabbed...
ENTRIES=`gluster volume heal "${VOLUME_NAME}" info | grep -e "${HOSTNAME}.*${BRICK}" -A 1000 | awk '/^$/{exit}1' | egrep ".*gfid.*" -B1`

gfids=`echo "${ENTRIES}" | grep gfid | cut -d ':' -f 2 | cut -d '>' -f 1`


echo "Entries for ${HOSTNAME} - ${VOLUME_NAME} - ${BRICK}" | tee -a ${TMP_LOG}

for GFID in $gfids; do

	# Directories are named based on the first chars of the gfid
	# e.g. f6/b7/f6b763ec-a996-4f2a-adc9-89635b7e12dc
	#
	GP1=`cut -c 1-2 <<<"$GFID"`
	GP2=`cut -c 3-4 <<<"$GFID"`

	# Start building the path to the GFID symlink's parent directory
	GFIDPRE="$BRICK"/.glusterfs/"$GP1"/"$GP2"

	# Append the GFID
	GFIDPATH="$GFIDPRE"/"$GFID"

	if [ ! "$QUIET" == "-q" ]; then
	    echo -ne "$GFID\t==\t" | tee -a ${TMP_LOG}
	fi

	# Does the path exist, and is it a symbolic link?
	if [ -h "$GFIDPATH" ]; then
	    if [ ! "$QUIET" == "-q" ]; then
		echo -ne "Directory:\t" | tee -a ${TMP_LOG}
	    fi
	    DIRPATH="$GFIDPRE"/`readlink "$GFIDPATH"`

	    # Calculate the "real" pathname
	    #
	    # The script this is based on tried to cd and pwd it
	    # this resulted in the script failing with "Too many levels of symbolic links"
	    # whenever Gluster was having one of it's moments
	    #
	    echo $(readlink -f `dirname "$DIRPATH"`)/$(basename "$DIRPATH") | tee -a ${TMP_LOG}

	else
	    # Not a symlink - means it's a file and the path we're looking at
	    # will be a hardlink back to the file wherever on the brick it actually lives
	    if [ ! "$QUIET" == "-q" ]; then
		echo -ne "File:\t" | tee -a ${TMP_LOG}
	    fi
	    INUM=`ls -i "$GFIDPATH" | cut -f 1 -d \ `  
	    if [ "$INUM" == "" ]
	    then
		echo "Unable to get inode number for file. Do you lack appropriate permissions?" | tee -a ${TMP_LOG}
		exit 1
	    fi

	    find "$BRICK" -inum "$INUM" ! -path \*.glusterfs/\* | tee -a ${TMP_LOG}
	fi
done


echo "FINISHED FOR ${HOSTNAME} - ${VOLUME_NAME} - ${BRICK} -- Full log found at ${TMP_LOG}"
exit 0
