# gluster_scripts
Scripts for Gluster filesystem administration


# In this repo (USE AT OWN RISK!):

- <b>gluster_eval_gfids_on_brick.sh</b> - Script to examine GFIDs from the ```gluster volume heal VOLNAME info``` output. The script has to be run on the host which has the brick mounted. It will run ```gluster volume heal VOLNAME info``` and work through the entries relating to the brick specified on invocation of the script. It will then provide the full path (as seen on a gluster client). Using this path one can then run ```ls``` on the file/folder from the gluster client and invoke a heal. **The script will take some time to run as it is trawling through a brick for each GFID entry it has obtianed for that brick in the heal list - the time will also depend on your brick size and backend storage device**. This script is based upon Ben Tasker's script: https://snippets.bentasker.co.uk/page-1912061505-Resolving-Gluster-GFIDs-back-to-real-files-and-directories-BASH.html


# Other useful scripts:

- heal_gluster.sh - <i>"This script looks for gluster volumes, checks their heal statuses and tries to fix all the unhealed files/dirs."</i>
  https://gist.githubusercontent.com/pulecp/99f3b89c2c5f3c4ff0fa052b4531cdf2/raw/heal_gluster.sh


# Misc - useful commands

Count outstanding heal entries for a VOLNAME:

```gluster volume heal VOLNAME info | grep entries | awk '{sum +=$4} END {print sum}'```

or summary count for each brick:

```gluster volume heal VOLNAME statistics heal-count```
