# :dragon: Hytale Installer

Unofficial script for installing a Hytale Dedicated Server. Works with the latest Hytale server releases!

Read more about [Hytale](https://hytale.com/) here. This script is not associated with the official Hytale project.

## Features

- Automatic installation of Java 25 (if not present)
- Automatic installation of required packages (unzip, expect)
- Automatic download and setup of Hytale server files
- Systemd service creation for easy management
- Automatic firewall configuration (UFW)
- Scheduled service restarts every 3 days

## Help and support

For help and support regarding this script, join the [Discord Chat](https://discord.gg/hytale).

## Supported installations

| Operating System | Version           | Supported          |
| --------------- | ---------------- | ------------------ |
| Ubuntu          | 20.04, 22.04, 24.04 | :white_check_mark: |
| Debian          | 10, 11, 12, 13   | :white_check_mark: |

## Using the installation script

To use the installation script, simply run this command as root or with sudo:

```bash
bash <(wget --no-cache -qO- https://raw.githubusercontent.com/johnoclockdk/Hytale-Installer/main/installer.sh)
```

_Note: You may need to be logged in as root on some systems._

## Firewall setup

The script can configure UFW to allow the Hytale server port (default: 5520/udp). If UFW is not installed, you will need to open the port manually.

## Development & Testing

To test the script, use a fresh VM or container with your preferred supported OS. Make sure to review the script before running in production environments.

## Contributors ✨

- Created and maintained by the Hytale Installer community

---

This project is not affiliated with or endorsed by Hypixel Studios or the official Hytale project. All trademarks and copyrights belong to their respective owners.
