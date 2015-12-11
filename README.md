# sysstat-journald

Take advantage of journald's stuctured logging to dump your system info.  This script runs uses sysstat (sar and frieds) to collect system information for a period of time then dumps the results into the journal after some name mangeling to make journald happy.

Note that because there is no `MESSAGE` field it wouldn't show up by default, you can use `journalctl MESSAGE_ID=847dc86c90f14ba7a864b05afdffd5d7 -overbsoe` to see the statistics.

This tool works great on a timer or in a loop to collect periodic information about system load, disk usage or whatever else sysstat can monitor. I run it every 10 seconds so I can make some pretty graphs.

# Requirements

On nixos the following packages are required:
- coreutils
- gawk
- sysstat
- utillinux (built with systemd support)
