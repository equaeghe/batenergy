# batenergy
Script to track laptop battery energy change during sleep states using systemd's system-sleep directory

## Installation
This script should be copied to systemd's system-sleep directory.
This directory is normally already present at `/usr/lib/systemd/system-sleep` or `/lib/systemd/system-sleep`; check your Linux distribution's information resources if it isn't clear which.
Make sure it is executable (`chmod +x batenergy.sh` as needed).

## Usage
Once installed, the script will cause informative output about battery energy change (amount and rate, in absolute units and percentages) to be added to the system logs.
This information may be useful for troubleshooting both discharging and charging of the battery during sleep states.

Example output, accessible using, e.g.,  `journalctl -u systemd-suspend.service`:

```
systemd[1]: Starting System Suspend...
systemd-sleep[2096130]: Currently on battery.
systemd-sleep[2096130]: Saving time and battery energy before sleeping (suspend).
systemd-sleep[2096128]: Suspending system...
systemd-sleep[2096128]: System resumed.
systemd-sleep[2096235]: Currently on mains.
systemd-sleep[2096235]: Duration of 0 days 3 hours 26 minutes sleeping (suspend).
systemd-sleep[2096235]: Battery energy change of -4.5 % (-2320 mWh) at an average rate of -1.30 %/h (-673 mW).
systemd[1]: systemd-suspend.service: Deactivated successfully.
systemd[1]: Finished System Suspend.
```

## Caveats
This script has been tested on one laptop model.
I may have made assumptions that do not hold for yours; use at your own risk.
Checking (for) the files referenced in the script (and other files in the containing directories) may help you adapt it to your model.

## Credits
Inspired by [Oliver Machacik's batdistrack](https://github.com/oliver-machacik/batdistrack).
