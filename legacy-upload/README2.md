# Systemd Service Files for Techdocs

The `techdocs` application project is designed to facilitate various operations that constitute the overall techdocs authoring and publishing process. This directory contains systemd service files that are essential for the operation of the application.

## Directory Overview

This directory (`/techdocs/system/systemd-services/`) is the designated location for systemd service files specific to the `techdocs` application project. Storing these files here facilitates easier maintenance, version control, and ensures that service configurations are part of the overall project repository.

## Symbolic Links

After creating or modifying a systemd service file in this directory, you must create a symbolic link in `/etc/systemd/system/` to ensure that systemd recognizes the service.

### Creating a Symbolic Link:

1. Open a terminal and navigate to the `/etc/systemd/system/` directory.
2. Use the following command to create a symbolic link:

   ```bash
   sudo ln -s /techdocs/system/systemd-services/your-service-file.service /etc/systemd/system/your-service-file.service
    ```

## Notes

- **Maintaining Symlinks:** If a service is renamed or if the filepath to this directory is changed, the symbolic links in the `/etc/systemd/system/` directory must be updated accordingly. Accurate and up-to-date symlinks are crucial for systemd to recognize and manage the services.

- **Updating Symlinks:**
  - If you rename a service (e.g., from `service1.service` to `new_service1.service`), you must delete the old symlink and create a new one pointing to the updated service file:
    ```bash
    sudo rm /etc/systemd/system/service1.service
    sudo ln -s /techdocs/system/systemd-services/new_service1.service /etc/systemd/system/new_service1.service
    ```
  - Similarly, if the filepath to the service files' directory changes, you'll need to update the symlinks to reflect the new path.

- **Reloading systemd:** After updating the symlinks, always run `sudo systemctl daemon-reload` to ensure systemd reloads the configuration and recognizes the changes.

- **Periodic Checks:** It’s a good practice to periodically verify that all symbolic links in `/etc/systemd/system/` are correct and point to the existing service files. This can prevent potential issues with service management.
