# gluster_scripts
Scripts for Gluster filesystem administration


# In this repo (USE AT OWN RISK!):

- <b>gluster_eval_gfids_on_brick.sh</b> - Script to examine GFIDs from the ```gluster volume heal VOLNAME info``` output. The script has to be run on the host which has the brick mounted. It will run ```gluster volume heal VOLNAME info``` and work through the entries relating to the brick specified on invocation of the script. It will then provide the full path on the server's brick (which can then be used relatively on a client) printed to stdout and also in an ```mktemp``` log file. Using part of this path, one can then run ```ls -l``` to achieve a ```stat``` on the file/folder from the gluster client and invoke a heal. **The script will take some time to run as it is trawling through a brick for each GFID entry it has obtianed for that brick in the heal list - the time will also depend on your brick size and backend storage device**. This script is based upon Ben Tasker's script: https://snippets.bentasker.co.uk/page-1912061505-Resolving-Gluster-GFIDs-back-to-real-files-and-directories-BASH.html

Example running on bricks 5,8 on the storage server (advise within screen/tmux):

```for i in {5,8}; do ./gluster_eval_gfids_on_brick.sh /mnt/VOLNAME/brick$i/brick VOLNAME; done```
<br>
<br>
- <b>gluster_simple_status.sh</b> - Rudimentary script to print out  ```gluster {volume,peer} status```.
<br>
<br>


# Other useful scripts:

- heal_gluster.sh - <i>"This script looks for gluster volumes, checks their heal statuses and tries to fix all the unhealed files/dirs."</i><br>
  https://gist.githubusercontent.com/pulecp/99f3b89c2c5f3c4ff0fa052b4531cdf2/raw/heal_gluster.sh

- gfid-resolver.sh - <i>"Glusterfs GFID Resolver Turns a GFID into a real path in the brick"</i><br>
  https://gist.githubusercontent.com/louiszuckerman/4392640/raw/gfid-resolver.sh

# Misc - useful commands

Count outstanding heal entries for a VOLNAME:

```gluster volume heal VOLNAME info | grep entries | awk '{sum +=$4} END {print sum}'```

or summary count for each brick:

```gluster volume heal VOLNAME statistics heal-count```

On a storage server, search for bricks that contain GFIDs, supplying multiple GFIDs - potentially useful for understanding heal problems

```for GFID in {11111111-2222-3333-4444-555555555555,11111111-2222-3333-4444-555555555555}; do GFIDC12=`echo "$GFID" | cut -c1,2`; GFIDC34=`echo "$GFID" | cut -c3,4`; find /mnt/VOLNAME/brick*/brick/.glusterfs/${GFIDC12}/${GFIDC34}/ -iname ${GFID}; done```



# Misc - useful links or bug reports

USE INFORMATION IN THIS SECTION AT OWN RISK!

https://bugzilla.redhat.com/show_bug.cgi?id=1303153 - Bug 1303153 - Gluster creating 0 byte files 
