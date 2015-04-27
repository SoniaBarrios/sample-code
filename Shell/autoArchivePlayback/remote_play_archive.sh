#! /bin/sh -

# DESCRIPTION
# This script will automatically play an audio file on a remote machine when silence is detected from the remote streaming server.
# The audio file is the radio programme recorded from one week previous that is currently scheduled to be on air.
# The script assumes the remote machine has had the archive directory (on this server) mounted on the remote machine via SSHFS.
# The archives are stored on this server at /mnt/tank/903fm_archives/128
# In the case of CKUT, the remote machine is a Mac Mini. The audio file is launched using a Applescript stored on the remote Mac.
# SSH keys and SSH login on the Mac must be enabled for script to function.

# Variables
mcr_user="xxx"
mcr_ip="xxx.xxx.xxx.xxx"

mcr_script_path="/Scripts/play_audio_file.scpt"
sshfs_mount_point="/Volumes/archives"
sshfs_mount_root="/mnt/tank/903fm_archives/128"

# show current epoch time
time_1wkago=`date --date="7 days ago" +%s`

# find number of seconds past the half hour
sec_past_hour=`expr $time_1wkago % 1800`

# find out what the current archive would be then
archive_time=`expr $time_1wkago - $sec_past_hour`

# find the file to play on archive server (local)
archive_file="t$archive_time.mp3"
local_file_path=`find /mnt/tank/903fm_archives/128 -name "$archive_file" -print`

# determine the location of the file relative to the mount point on the remote machine
# ${local_file_path#$sshfs_mount_root} removes the $sshfs_mount_root path from $local_file_path
remote_file_path="$sshfs_mount_point${local_file_path#$sshfs_mount_root}"
echo "Playing file on remote machine from $remote_file_path..."

# launch the script to play audiofile
# SSH keys must be set-up
ssh $mcr_user@$mcr_ip "osascript \"$mcr_script_path\" \"$remote_file_path\""
