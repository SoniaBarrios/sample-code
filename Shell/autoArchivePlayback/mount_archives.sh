#! /bin/sh -

# Author:       Michael Dean
# Organization: CKUT 90.3FM
# Date:         April 2015

# DESCRIPTION
# Automatically mount the archives folder (stored on the server, "delay") on MCR computer 1
# Assumes that SSH keys are setup for $host as $user for this machine's root user (sudo ssh-keygen)
# Assumes this file is owned/executable by root (chown root:wheel, chmod 700), and added to visudo file for MCR user
#	username  ALL=(ALL) NOPASSWD: /Scripts/mount_archives.sh
# Script is launched when Mac computer boots (from launchd .plist file)
# 	launchd file stored here: /Library/LaunchAgents/com.volunteers.mount_archives.plist
# This allows the automatic archive playback system to function when dead air is detected
# 	The automatic archive playback system is found at: /etc/ckut-liq/remote_play_archive.sh

user="ckutsys"
host="delay.ckut.ca"
remote_dir_to_mount="/mnt/tank/903fm_archives/128/"
mount_point="/Volumes/archives"

mkdir $mount_point
sudo sshfs -o allow_other $user@$host:$remote_dir_to_mount $mount_point
