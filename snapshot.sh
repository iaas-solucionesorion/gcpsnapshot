#!/bin/bash
# Author: Alan Fuller, Fullworks
# loop through all disks within this project  and create a snapshot
# modified: 24-07-2018
# SSGG

#change value of [VM-NAME] for VM name to create snapshot
#if required in all VM's snapshots delete arg (--filter="name=( '[VM-NAME]' ... )")

gcloud compute disks list --format='value(name,zone)' --filter="name=( '[VM-NAME]' ... )"| while read DISK_NAME ZONE; do
  gcloud compute disks snapshot $DISK_NAME --snapshot-names autogcs-${DISK_NAME:0:31}-$(date "+%Y-%m-%d-%s") --zone $ZONE
done
#
# snapshots are incremental and dont need to be deleted, deleting snapshots will merge snapshots, so deleting doesn't loose anything
# having too many snapshots is unwiedly so this script deletes them after [DAYS] days. Example 01,02 etc.
#
if [[ $(uname) == "Linux" ]]; then
  from_date=$(date -d "-[DAYS] days" "+%Y-%m-%d")
else
  from_date=$(date -v -[DAYS]d "+%Y-%m-%d")
fi
gcloud compute snapshots list --filter="name=autogcs-[VM-NAME]-$from_date" --uri | while read SNAPSHOT_URI; do
   gcloud compute snapshots delete $SNAPSHOT_URI  --quiet
done
#