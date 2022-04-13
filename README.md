# gluster_scripts
Scripts for Gluster filesystem administration


# In this repo:



# Other useful scripts:

- heal_gluster.sh - <i>"This script looks for gluster volumes, checks their heal statuses and tries to fix all the unhealed files/dirs."</i>
  https://gist.githubusercontent.com/pulecp/99f3b89c2c5f3c4ff0fa052b4531cdf2/raw/heal_gluster.sh


# Misc - useful commands

Count outstanding heal entries for a VOLNAME

```gluster volume heal VOLNAME info | grep entries | awk '{sum +=$4} END {print sum}'```
