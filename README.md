# 🐉 Hytale Server Installer

**One-command automated installer for Hytale Dedicated Server**

Simple, fast, and fully automated setup with authentication persistence and tmux console access.

> ⚠️ Unofficial tool - not affiliated with Hypixel Studios

---

## 🚀 Quick Install

```bash
wget https://raw.githubusercontent.com/johnoclockdk/Hytale-Server-Installer/main/Hytale-Server && chmod +x Hytale-Server && ./Hytale-Server install
```

That's it! Visit the authentication URL when prompted.

---

## 📋 Commands

| Command | Description |
|---------|-------------|
| `./Hytale-Server install` | Install Hytale server |
| `./Hytale-Server start` | Start the server |
| `./Hytale-Server stop` | Stop the server |
| `./Hytale-Server restart` | Restart the server |
| `./Hytale-Server status` | Show server status & configuration |
| `./Hytale-Server console` | Open server console |
| `./Hytale-Server logs` | View live server logs |
| `./Hytale-Server update` | Update to latest version |
| `./Hytale-Server backup` | Create manual backup |
| `./Hytale-Server restore` | Restore from backup |
| `./Hytale-Server config` | Edit server configuration |
| `./Hytale-Server rotate-logs` | Manage and rotate server logs |
| `./Hytale-Server autobackup` | Toggle automatic backups |
| `./Hytale-Server autorestart` | Toggle automatic restarts |
| `./Hytale-Server mods list` | List available and installed mods |
| `./Hytale-Server mods install <name\|number>` | Install a mod |
| `./Hytale-Server mods uninstall <name\|number>` | Uninstall a mod |
| `./Hytale-Server uninstall` | Remove completely |

💡 Run `./Hytale-Server` without arguments to show all commands.

---

## ✨ Features

- 🔧 **Zero Configuration** - Installs Java 25 and all dependencies automatically
- 🔐 **Auto Authentication** - OAuth login with encrypted persistence
- 🖥️ **Tmux Console** - Persistent console access (detach with `Ctrl+B` then `D`)
- 🎯 **No Systemd Required** - Uses tmux and cron for maximum compatibility
- 🚀 **Auto-Start on Boot** - Optional cron-based auto-start
- 💾 **Smart Backups** - Manual & automatic backups with retention management (includes mods)
- 🔄 **Easy Restore** - Quick world restoration from backup archives
- 🔥 **Firewall Setup** - Automatic UFW configuration
- ⚙️ **Custom Ports** - Choose your own port during installation
- 🎮 **Mod Manager** - Install and uninstall mods by name or number
- 📝 **JVM Configuration** - Customize memory allocation during installation
- ⏰ **Auto-Restart** - Optional scheduled server restarts every 3 days
- 📊 **Status Monitoring** - View server status, logs, and configuration at a glance
- 🗂️ **Log Rotation** - Compress and manage server logs

---

### Installation Prompts

During installation, you'll be asked:

1. **Server Port** - Choose a custom port or use default (5520)
2. **Auto-Backup** - Enable daily backups at 1:00 AM (recommended)
3. **Auto-Restart** - Enable auto-start on boot and periodic restarts every 3 days (optional)
4. **JVM Memory** - Configure minimum and maximum heap size (default: 4GB min, 8GB max)

### First Start

Start the server after installation:

```bash
./Hytale-Server start
```

You'll see an authentication URL:
```
🔗 Visit: https://oauth.accounts.hytale.com/oauth2/device/verify?user_code=xxxxx
```

Authenticate **once** - your credentials persist across all restarts.

---

## 💾 Backup & Restore

### Manual Backup

Create a backup of your world and configuration:

```bash
./Hytale-Server backup
```

**What's backed up:**
- `universe/` - World data
- `mods/` - Installed mods
- `config.json` - Server configuration
- `permissions.json` - Player permissions
- `bans.json` - Banned players
- `whitelist.json` - Whitelisted players

### Automatic Backups

Enable daily backups at 1:00 AM:

```bash
./Hytale-Server autobackup
```

- Keeps last 7 backups automatically
- Compressed archives save disk space
- Toggle on/off anytime

### Restore from Backup

Restore your world from a previous backup:

```bash
./Hytale-Server restore
```

Select from available backups - safety backup created automatically before restore.

---
## 🎮 Mod Management

The server includes a built-in mod manager to easily install and manage mods.

### List Available Mods

```bash
./Hytale-Server mods list
```

**Shows:**
- Numbered list of available mods
- Installation status (installed/not installed)
- Currently installed mod sizes

### Install a Mod

Install by name:
```bash
./Hytale-Server mods install example-mod
```

Or by number:
```bash
./Hytale-Server mods install 1
```

**Process:**
- [1/3] Preparing installation
- [2/3] Downloading mod
- [3/3] Verifying installation

### Uninstall a Mod

Uninstall by name:
```bash
./Hytale-Server mods uninstall example-mod
```

Or by number:
```bash
./Hytale-Server mods uninstall 1
```

### Adding Custom Mods

Edit the script and add your mods to the `MOD_URLS` array:

```bash
MOD_URLS=(
  ["my-mod"]="https://example.com/downloads/my-mod.jar"
  ["another-mod"]="https://cdn.example.com/another-mod.jar"
)
```

Mods are automatically saved as `<mod-name>.jar` in the `mods/` directory.

---
## �🖥️ System Requirements

| Requirement | Details |
|-------------|---------|
| **OS** | Ubuntu 20.04+ or Debian 10+ (any Linux with cron) |
| **Disk** | 5 GB minimum |
| **Access** | sudo/root (for installation only) |
| **Account** | Valid Hytale account |

### Supported Distributions

| Distribution | Versions | Status |
|--------------|----------|--------|
| Ubuntu | 20.04, 22.04, 24.04 | ✅ |
| Debian | 10, 11, 12, 13 | ✅ |
| Other Linux | With cron and tmux | ✅ |
```

---

## 📊 Monitoring

### Quick Status Check

View server status, enabled features, and configuration:

```bash
./Hytale-Server status
```

**Shows:**
- Server running/stopped state
- Auto-start on boot status
- Auto-backup enabled/disabled
- Auto-restart enabled/disabled
- Server IP and port
- Backup count
- Authentication status
- Installed mods count

### Live Logs

View server logs in real-time:

```bash
./Hytale-Server logs
```

### Console Access

Access the server console:

```bash
./Hytale-Server console
```

Detach from console: `Ctrl+B` then `D`

---

## 📁 Directory Structure

```
~/hytale_server/          # Main server files
├── HytaleServer.jar
├── Assets.zip
├── universe/             # World data
├── config.json
├── permissions.json
├── backups/              # Backup archives
└── logs/

~/.hytale-tools/          # Tools (isolated)
├── hytale-downloader-linux-amd64
└── .hytale-downloader-credentials.json

~/.hytale-temp/           # Temporary downloads
```

---

## 🔧 Troubleshooting

<details>
<summary><b>Server won't start</b></summary>

```bash
systemctl status hytale
journalctl -u hytale -f
```
</details>

<details>
<summary><b>Console not accessible</b></summary>

```bash
tmux ls                      # Check if session exists
./Hytale-Server console   # Reconnect
```
</details>

<details>
<summary><b>Re-authenticate manually</b></summary>

```bash
./Hytale-Server console
# Then in console:
/auth persistence Encrypted
/auth login device
```
</details>

<details>
<summary><b>Backup failed or restore issues</b></summary>

```bash
# Check backup directory
ls -lh ~/hytale_server/backups/

# Check disk space
df -h

# Manual backup location
~/hytale_server/backups/hytale-backup-YYYYMMDD-HHMMSS.tar.gz
```
</details>

---

## 💬 Support

Need help? Join the [Hytale Discord](https://discord.gg/hytale)

---

## 📜 License & Disclaimer

This project is **not affiliated** with Hypixel Studios or the official Hytale project.

All trademarks and copyrights belong to their respective owners.
