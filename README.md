# gluster_scripts
Scripts and notes for Gluster filesystem administration


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


On a storage server, search for bricks that contain GFIDs, supplying multiple GFIDs - potentially useful for understanding heal problems:

```for GFID in {11111111-2222-3333-4444-555555555555,11111111-2222-3333-4444-555555555555}; do GFIDC12=`echo "$GFID" | cut -c1,2`; GFIDC34=`echo "$GFID" | cut -c3,4`; find /mnt/VOLNAME/brick*/brick/.glusterfs/${GFIDC12}/${GFIDC34}/ -iname ${GFID}; done```


Find gfid on brick, if filename is known:

```find /mnt/VOLNAME/brickX/brick/.glusterfs -samefile /mnt/VOLNAME/brickX/brick/some_dir/some_file```


Heal a split brain entry using GFID (check out the file on servers first and advise taking backup of file first!)

```gluster volume heal VOLNAME split-brain bigger-file gfid:11111111-2222-3333-4444-555555555555```

See https://docs.gluster.org/en/main/Troubleshooting/resolving-splitbrain/

Get file attributes:

```getfattr -d -m . -e hex  <path_to_file_on_brick NOT client mount>```


# Misc - tips healing

<b>Scenario:</b> You've tracked a file down and you know it should be in the gluster client mount view (other files are showing without issue in the directory), but the file of interest returns the below message upon ```stat``` using ```ls -l```:

```ls: cannot access some_example file: Transport endpoint is not connected```

- Check all bricks are visible in ```gluster volume status VOLNAME```
- Check all bricks are visible in ```gluster volume heal VOLNAME info``` and none show ```Transport endpoint is not connected```
- Remount on the client
- Try access again from client and hopefully it'll stat

<b>Scenario:</b> The heal list shows an entry, but you can't navigate to an intermediate folder within the path on the client.

- Find the folder structure on the bricks, by incremtally listing e.g. ```ll /mnt/VOLNAME/brick*/brick/some/folder/```
- Once you've found the folder name, cd to it on the client, in this example ```cd /mnt/gluster/some/folder; cd the_found_folder_previous_step```
- That should invoke a heal on the directory, assuming nothing more is going on

OR if the heal list is clear, launch full heal from CLI on the volume.


# Misc - useful links or bug reports

USE INFORMATION IN THIS SECTION AT OWN RISK!

https://docs.gluster.org/en/main/Administrator-Guide/Automatic-File-Replication/ - gluster.org replication

https://docs.gluster.org/en/main/Troubleshooting/troubleshooting-afr/#ii-self-heal-is-stuck-not-getting-completed - gluster.org heal stuck

https://bugzilla.redhat.com/show_bug.cgi?id=1303153 - Bug 1303153 - Gluster creating 0 byte files 

```find . -iname "*" -perm 1000``` quick find for the above empty sticky file issue, adapt accordingly

find empty sticky (for above), confirm empty, on same brick find the GFID for this file

```find /mnt/VOLNAME/brick1/brick/some/dir/path/to/examine -perm 1000 | while read line; do echo ${line} && du -hs ${line} && find /mnt/VOLNAME/brick1/brick/.glusterfs -samefile ${line}; echo ""; done```
