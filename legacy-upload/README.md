# The Python Directory
This directory serves as the home for all Python files created for the techdocs system. Some scripts and programs in this folder are set up as background services through `systemd`, or as executable command line tools through the techdocs server's `PATH`. In both instances, symbolic links to the script are created in the required location.

## Setting the line ending format
Linux requires the `LF` line ending format, while Windows favors the `CRLF` format. Be sure to select the appropriate line ending for the operating environment from the bottom-right of the VS Code window while writing and editing Python and Shell scripts.

## Adding a python script to `systemd` services
- **Directory**: `/etc/sytemd/system/`

## Adding a python script to `PATH` for command line use
- **Directory**: `/usr/local/bin/`
