<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>AbandonProcessGroup</key>
	<true/>

	<key>Label</key>
	<string>com.volunteers.mount_archives.plist</string>

	<key>ProgramArguments</key>
	<array>
		<string>/bin/sh</string>
		<string>/Scripts/mount_archives.sh</string>
	</array>
	
	<key>RunAtLoad</key>
	<true/>

	<key>StandardErrorPath</key>
	<string>/tmp/com.volunteers.mount_archives.err</string>
	<key>StandardOutPath</key>
	<string>/tmp/com.volunteers.mount_archives.out</string>
</dict>
</plist>
