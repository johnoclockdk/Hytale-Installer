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
| `./Hytale-Server status` | Show server status & configuration |
| `./Hytale-Server console` | Open server console |
| `./Hytale-Server logs` | View live server logs |
| `./Hytale-Server update` | Update to latest version |
| `./Hytale-Server backup` | Create manual backup |
| `./Hytale-Server restore` | Restore from backup |
| `./Hytale-Server autobackup` | Toggle automatic backups |
| `./Hytale-Server autorestart` | Toggle automatic restarts |
| `./Hytale-Server uninstall` | Remove completely |

💡 Run `./Hytale-Server` without arguments to show all commands.

---

## ✨ Features

- 🔧 **Zero Configuration** - Installs Java 25 and all dependencies automatically
- 🔐 **Auto Authentication** - OAuth login with encrypted persistence
- 🖥️ **Tmux Console** - Persistent console access (detach with `Ctrl+B` then `D`)
- 🚀 **Systemd Service** - Auto-start on boot, automatic restarts
- 💾 **Smart Backups** - Manual & automatic backups with retention management
- 🔄 **Easy Restore** - Quick world restoration from backup archives
- 🔥 **Firewall Setup** - Automatic UFW configuration
- ⚙️ **Custom Ports** - Choose your own port during installation
- ⏰ **Auto-Restart** - Optional scheduled server restarts every 3 days
- 📊 **Status Monitoring** - View server status, logs, and configuration at a glance

---

### Installation Prompts

During installation, you'll be asked:

1. **Server Port** - Choose a custom port or use default (5520)
2. **Auto-Backup** - Enable daily backups at 2:00 AM (recommended)
3. **Auto-Restart** - Enable server restart every 3 days at midnight (optional)

### Start the Server

Aetup

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
- `config.json` - Server configuration
- `permissions.json` - Player permissions
- `bans.json` - Banned players
- `whitelist.json` - Whitelisted players

### Automatic Backups

Enable daily backups at 2:00 AM:

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

## �🖥️ System Requirements

| Requirement | Details |
|-------------|---------|
| **OS** | Ubuntu 20.04+ or Debian 10+ |
| **Disk** | 5 GB minimum |
| **Access** | sudo/root |
| **Account** | Valid Hytale account |

### Supported Distributions
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

### Live Logs

View server logs in real-time:

```bash
./Hytale-Server logs
```

### Other Monitoring Commands

```bash
# System journalion | Versions | Status |
|--------------|----------|--------|
| Ubuntu | 20.04, 22.04, 24.04 | ✅ |
| Debian | 10, 11, 12, 13 | ✅ |
```
---

## 📊 Monitoring

```bash
# Real-time logs
journalctl -u hytale -f

# Service status
systemctl status hytale

# Access console
./Hytale-Server console
```

### 📁 Directory Structure

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
