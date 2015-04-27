Automatic Archive Playback System
- - - - - - - - - - - - - - - - -
Author: Michael Dean 2015
Organization: CKUT 90.3FM

Description:
- This script will automatically play an audio file on a remote machine when silence is detected from the remote streaming server.
- The audio file is the radio programme recorded from one week previous that is currently scheduled to be on air.
- The script assumes the remote machine has had the archive directory (on this server) mounted on the remote machine via SSHFS.
- The archives are stored on this server at /mnt/tank/903fm_archives/128
- In the case of CKUT, the remote machine is a Mac Mini. The audio file is launched using a Applescript stored on the remote Mac.
- SSH keys and SSH login on the Mac must be enabled for script to function.

Neccessary files:
com.volunteers.mount_archives.sh
mount_archives.sh
remote_play_archive.sh
play_audio_file.scpt
