#!/bin/bash

# README
# This script applies ownership and permission settings to the entire /techdocs directory and its contents. Instead of manually changing file/directory settings when permissions issues arise, an admin can simply edit and re-run this script. This ensures consistent and transparent permission and ownership structures throughout the directory.
# This script is structured in a general -> specific sequence, applying recursive settings at each stage and then overwriting them as needed later in the script.
# Note that prior to going live with the techdocs environment, I recursively set the owner (user) of the entire directory and its contents as root. I'm not going to include that operation in this script, because I want to preserve user ownership of source files in future executions of the script.



# stop script execution if any command fails
set -e

# main function
update-settings_techdocs() {
    echo "Updating ownership and permissions settings for '/techdocs/' directory..."
    chgrp -R server-techdocs-sudo /techdocs
    chmod -R u=rwx,g=rx,o=rx /techdocs

    # call subdirectory functions
    update-settings_techdocs-system
    update-settings_techdocs-build
    update-settings_techdocs-source

    # apply global exceptions
    global-exceptions

    echo "Ownership and permissions updates complete."
}

# system subdirectory function
update-settings_techdocs-system() {
    echo "Updating settings for '/techdocs/system/' directory..."
    # set owner of system directory to root
    chown -R root:server-techdocs-sudo /techdocs/system
    # allow admin to write in system directory
    chmod -R g+w /techdocs/system
    # /techdocs/system/log/ exceptions - need to add chown command for every log folder created
    chgrp -R server-techdocs-services /techdocs/system/log
    chmod -R g-w /techdocs/system/log
    chown -R optipng-bot /techdocs/system/log/optipng-bot
    # protect python scripts from renaming/deletion
    chmod -R +t /techdocs/system/python
    # set ownership and/or restrict execute permissions for python scripts as needed, maybe?
}

# build subdirectory function
update-settings_techdocs-build() {
    echo "Updating settings for '/techdocs/build/' directory..."
    # give services group ownership of build directory
    chgrp -R server-techdocs-services /techdocs/build
    # gonna have to add settings here once i've created user(s) and scripts for build process
}

# source subdirectory function
update-settings_techdocs-source() {
    echo "Updating settings for '/techdocs/source/' directory..."
    # give contributor group ownership of source directory and full permissions to manipulate its' contents
    chgrp -R server-techdocs-contribute /techdocs/source
    chmod g=rwx /techdocs/source
    # add sudo group using access control lists to grant admins the same access that is being granted to contributors - now all authors can do author shit
    setfacl -R -m g:server-techdocs-sudo:rwx /techdocs/source
    setfacl -R -m d:g:server-techdocs-sudo:rwx /techdocs/source
    # define exceptions
    # optipng-bot exceptions
    chown -R optipng-bot:server-techdocs-services /techdocs/source/images/png_opti
    chmod -R u=rwx,g=rx,o=rx /techdocs/source/images/png_opti
}

# global exceptions function
global-exceptions() {
    echo "Applying global exceptions..."
    # using chmod +t to protect directories and README.md files from deletion or rename by anyone other than root or owner
    find /techdocs -type d -exec chmod +t {} \;
    find /techdocs -type f -name "README.md" -exec chmod u=rwx,g=rx,o=rx,+t {} \;
}

# execute main function
update-settings_techdocs