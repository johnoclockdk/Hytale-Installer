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
| `./Hytale-Server console` | Open server console |
| `./Hytale-Server update` | Update to latest version |
| `./Hytale-Server uninstall` | Remove completely |

💡 Run `./Hytale-Server` without arguments for an interactive menu.

---

## ✨ Features

- 🔧 **Zero Configuration** - Installs Java 25 and all dependencies automatically
- 🔐 **Auto Authentication** - OAuth login with encrypted persistence
- 🖥️ **Tmux Console** - Persistent console access (detach with `Ctrl+B` then `D`)
- 🚀 **Systemd Service** - Auto-start on boot, automatic restarts
- 🔥 **Firewall Setup** - Automatic UFW configuration
- ⚙️ **Custom Ports** - Choose your own port during installation

---

## 🔑 First Time Setup

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

## 🖥️ System Requirements

| Requirement | Details |
|-------------|---------|
| **OS** | Ubuntu 20.04+ or Debian 10+ |
| **Disk** | 5 GB minimum |
| **Access** | sudo/root |
| **Account** | Valid Hytale account |

### Supported Distributions

| Distribution | Versions | Status |
|--------------|----------|--------|
| Ubuntu | 20.04, 22.04, 24.04 | ✅ |
| Debian | 10, 11, 12, 13 | ✅ |

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

**Default server location:** `~/hytale_server/`

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

---

## 💬 Support

Need help? Join the [Hytale Discord](https://discord.gg/hytale)

---

## 📜 License & Disclaimer

This project is **not affiliated** with Hypixel Studios or the official Hytale project.

All trademarks and copyrights belong to their respective owners.
