#!/bin/bash
set -e

# ================= CONFIG =================
USER_NAME=$(whoami)
BASE_DIR="$(pwd)/hytale_server"
SERVER_DIR="$BASE_DIR/server"
DOWNLOADER_URL="https://downloader.hytale.com/hytale-downloader.zip"
SERVICE_FILE="/etc/systemd/system/hytale.service"
RESTART_CRON="0 0 */3 * * /usr/bin/systemctl restart hytale"
PORT=5520
# =========================================

show_menu() {
  echo "=========================================="
  echo "   Hytale Dedicated Server Manager"
  echo "=========================================="
  echo ""
  echo "1) Install Hytale Server"
  echo "2) Update Hytale Server"
  echo "3) Uninstall Hytale Server"
  echo "4) Exit"
  echo ""
  read -p "Select an option [1-4]: " choice
  
  case $choice in
    1) install_server ;;
    2) update_server ;;
    3) uninstall_server ;;
    4) echo "Exiting..."; exit 0 ;;
    *) echo "Invalid option. Please try again."; show_menu ;;
  esac
}

uninstall_server() {
  echo ""
  echo "=== Uninstalling Hytale Server ==="
  echo ""
  
  # Stop and disable service
  if systemctl is-active --quiet hytale 2>/dev/null; then
    echo "Stopping Hytale service..."
    sudo systemctl stop hytale
  fi
  
  if systemctl is-enabled --quiet hytale 2>/dev/null; then
    echo "Disabling Hytale service..."
    sudo systemctl disable hytale
  fi
  
  # Remove service file
  if [ -f "$SERVICE_FILE" ]; then
    echo "Removing service file..."
    sudo rm -f "$SERVICE_FILE"
    sudo systemctl daemon-reload
  fi
  
  # Remove cron job
  echo "Removing cron job..."
  ( sudo crontab -l 2>/dev/null | grep -v "systemctl restart hytale" ) | sudo crontab - 2>/dev/null || true
  
  # Remove server files
  if [ -d "$BASE_DIR" ]; then
    echo "Removing server files from $BASE_DIR..."
    rm -rf "$BASE_DIR"
  fi
  
  # Remove firewall rule
  if command -v ufw >/dev/null 2>&1; then
    echo "Removing firewall rule..."
    sudo ufw delete allow ${PORT}/udp 2>/dev/null || true
  fi
  
  echo ""
  echo "=========================================="
  echo "Uninstall complete!"
  echo "=========================================="
}

update_server() {
  echo ""
  echo "=== Updating Hytale Server ==="
  echo ""
  
  # Check if server is installed
  if ! systemctl list-unit-files | grep -q hytale.service; then
    echo "ERROR: Hytale server is not installed."
    echo "Please install it first using option 1."
    exit 1
  fi
  
  echo "[1/5] Stopping Hytale service..."
  sudo systemctl stop hytale
  
  echo "[2/5] Downloading Hytale Downloader..."
  cd "$BASE_DIR" || { echo "Failed to change to $BASE_DIR." >&2; exit 1; }
  
  if [ ! -f "hytale-downloader-linux-amd64" ]; then
    if wget --no-cookies --no-cache -O hytale-downloader.zip "$DOWNLOADER_URL"; then
      if unzip -o hytale-downloader.zip; then
        chmod +x hytale-downloader-linux-amd64
        rm -f hytale-downloader-windows-amd64.exe hytale-downloader.zip
      fi
    fi
  fi
  
  echo "[3/5] Downloading latest server files..."
  if ./hytale-downloader-linux-amd64; then
    echo "Server files downloaded."
  else
    echo "Failed to download server files." >&2
    exit 1
  fi
  
  DOWNLOADED_ZIP=$(ls -t *.zip 2>/dev/null | head -1)
  
  if [ -z "$DOWNLOADED_ZIP" ]; then
    echo "No zip file found after download." >&2
    exit 1
  fi
  
  echo "[4/5] Extracting and updating server files..."
  if unzip -o "$DOWNLOADED_ZIP"; then
    echo "Extraction complete."
  else
    echo "Failed to extract server files." >&2
    exit 1
  fi
  
  # Update server files
  if [ -d "Server" ]; then
    rm -rf "$SERVER_DIR"/*
    cp -r Server/* "$SERVER_DIR/" || { echo "Failed to copy server files." >&2; exit 1; }
  fi
  
  if [ -f "Assets.zip" ]; then
    cp "Assets.zip" "$SERVER_DIR/" || { echo "Failed to copy Assets.zip." >&2; exit 1; }
  fi
  
  # Clean up
  rm -f "$DOWNLOADED_ZIP"
  rm -rf Server
  rm -f Assets.zip
  rm -f QUICKSTART.md
  
  echo "[5/5] Starting Hytale service..."
  sudo systemctl start hytale
  
  echo ""
  echo "=========================================="
  echo "Update complete!"
  echo "Check logs with: journalctl -u hytale -f"
  echo "=========================================="
}

install_server() {
  echo ""
  echo "=== Installing Hytale Dedicated Server ==="
  echo ""
  
  # Check if already installed
  if systemctl is-active --quiet hytale 2>/dev/null; then
    echo "WARNING: Hytale service is already running!"
    echo "Please uninstall first using option 3."
    exit 1
  fi

echo "[1/8] Checking dependencies..."

# Check and install unzip if missing
if ! command -v unzip >/dev/null 2>&1; then
  echo "Installing unzip..."
  sudo apt-get update -qq
  sudo apt-get install -y unzip
  echo "✓ unzip installed."
else
  echo "✓ unzip is already installed."
fi

echo "Checking Java installation..."
JAVA_VERSION_OUTPUT=$(java -version 2>&1 || true)
JAVA_VERSION=$(echo "$JAVA_VERSION_OUTPUT" | awk -F[\".] '/version/ {print $2}')

if [[ "$JAVA_VERSION_OUTPUT" == *"25."* || "$JAVA_VERSION" == "25" ]]; then
  echo "✓ Java 25 is already installed."
else
  echo "Installing Java 25..."
  if wget --no-cookies --no-cache -q --show-progress https://download.oracle.com/java/25/latest/jdk-25_linux-x64_bin.deb; then
    if sudo dpkg -i jdk-25_linux-x64_bin.deb; then
      echo "✓ Java 25 installed successfully."
      rm jdk-25_linux-x64_bin.deb
    else
      echo "Failed to install Java." >&2
      exit 1
    fi
  else
    echo "Failed to download Java installer." >&2
    exit 1
  fi
fi

java --version || { echo "Java not found in PATH." >&2; exit 1; }


# ---- 2. Create directories ----
echo "[2/8] Creating directories..."
mkdir -p "$SERVER_DIR"


# ---- 3. Install Hytale Downloader CLI ----
echo "[3/8] Downloading Hytale Downloader..."

if wget --no-cookies --no-cache -O hytale-downloader.zip "$DOWNLOADER_URL"; then
  echo "Hytale Downloader downloaded."
else
  echo "Failed to download Hytale Downloader." >&2
  exit 1
fi
echo "Extracting Hytale Downloader..."
if unzip -o hytale-downloader.zip; then
  echo "✓ Extraction complete."
else
  echo "Failed to extract Hytale Downloader." >&2
  exit 1
fi

chmod +x hytale-downloader-linux-amd64
rm -f hytale-downloader-windows-amd64.exe hytale-downloader.zip

if [ "$(realpath hytale-downloader-linux-amd64)" != "$BASE_DIR/hytale-downloader-linux-amd64" ]; then
  mv hytale-downloader-linux-amd64 "$BASE_DIR/"
fi


# ---- 4. Download server files ----
echo "[4/8] Downloading Hytale server files..."
cd "$BASE_DIR" || { echo "Failed to change to $BASE_DIR." >&2; exit 1; }
if ./hytale-downloader-linux-amd64; then
  echo "Server files downloaded."
else
  echo "Failed to download server files." >&2
  exit 1
fi

# Expected structure: The downloader creates a zip file like "2026.01.15-c04fdfe10.zip"
# Find the most recently created zip file
DOWNLOADED_ZIP=$(ls -t *.zip 2>/dev/null | head -1)

if [ -z "$DOWNLOADED_ZIP" ]; then
  echo "No zip file found after download." >&2
  exit 1
fi

echo "Extracting $DOWNLOADED_ZIP..."
if unzip -o "$DOWNLOADED_ZIP"; then
  echo "Extraction complete."
else
  echo "Failed to extract server files." >&2
  exit 1
fi

# Expected structure after extraction: Server/ Assets.zip
echo "Copying server files to $SERVER_DIR..."
if [ -d "Server" ]; then
  cp -r Server/* "$SERVER_DIR/" || { echo "Failed to copy server files." >&2; exit 1; }
else
  echo "Server directory not found after extraction." >&2
  exit 1
fi

if [ -f "Assets.zip" ]; then
  cp "Assets.zip" "$SERVER_DIR/" || { echo "Failed to copy Assets.zip." >&2; exit 1; }
else
  echo "Assets.zip not found after extraction." >&2
  exit 1
fi

# Clean up temporary files
echo "Cleaning up temporary files..."
rm -f "$DOWNLOADED_ZIP"
rm -rf Server
rm -f Assets.zip
rm -f QUICKSTART.md

echo "[5/8] Installing dependencies and creating server start script..."
# Install expect if not already installed
if ! command -v expect >/dev/null 2>&1; then
  echo "Installing expect..."
  sudo apt-get update -qq
  sudo apt-get install -y expect
fi

cat << EOF > "$SERVER_DIR/start.sh"
#!/bin/bash
cd "\$(dirname "\$0")"

while true; do
  echo "Starting Hytale Server..."
  
  expect << 'EXPECT_EOF'
set timeout -1
spawn java -jar HytaleServer.jar --assets Assets.zip

# Wait for "No server tokens configured" message
expect {
  "No server tokens configured" {
    send "/auth login device\r"
    exp_continue
  }
  eof
}
EXPECT_EOF
  
  echo "Server stopped. Restarting in 5 seconds..."
  sleep 5
done
EOF


chmod +x "$SERVER_DIR/start.sh"
echo "Start script created at $SERVER_DIR/start.sh."

echo "[6/8] Creating systemd service..."
sudo tee "$SERVICE_FILE" > /dev/null << EOF
[Unit]
Description=Hytale Dedicated Server
After=network.target

[Service]
User=$USER_NAME
WorkingDirectory=$SERVER_DIR
ExecStart=$SERVER_DIR/start.sh
Restart=always
RestartSec=5
StandardOutput=journal
StandardError=journal
LimitNOFILE=1048576

[Install]
WantedBy=multi-user.target
EOF


echo "Reloading systemd, enabling and starting service..."
sudo systemctl daemon-reload
sudo systemctl enable hytale
sudo systemctl start hytale
if systemctl is-active --quiet hytale; then
  echo "Hytale service started successfully."
else
  echo "Hytale service failed to start." >&2
  exit 1
fi


# ---- 7. Open firewall (UDP / QUIC) ----
echo "[7/8] Configuring firewall..."
if command -v ufw >/dev/null 2>&1; then
  echo "Configuring UFW firewall..."
  sudo ufw allow ${PORT}/udp
  echo "UFW rule added for UDP port ${PORT}."
else
  echo "UFW not found. Please ensure UDP port ${PORT} is open."
fi


# ---- 8. Schedule 3-day service restart ----
echo "[8/8] Scheduling automatic service restart every 3 days..."
( sudo crontab -l 2>/dev/null | grep -v "systemctl restart hytale" ; echo "$RESTART_CRON" ) | sudo crontab -
echo "Service restart cron job set."


# ---- DONE ----
echo ""
echo "[9/9] Finalizing installation..."

# Get server IPv4 address
SERVER_IP=$(curl -4 -s --max-time 5 ifconfig.me || curl -4 -s --max-time 5 icanhazip.com || hostname -I | grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}' | head -n1)

echo "Waiting for server to start and generate authentication URL..."
AUTH_URL=""
for i in {1..6}; do
  sleep 10
  AUTH_URL=$(journalctl -u hytale -n 150 --no-pager -o cat 2>/dev/null | grep -oP 'https://oauth\.accounts\.hytale\.com/oauth2/device/verify\?user_code=[A-Za-z0-9]+' | tail -1)
  if [ -n "$AUTH_URL" ]; then
    break
  fi
  echo "Still waiting... ($((i*10))s)"
done

echo "=========================================="
echo "INSTALL COMPLETE!"
echo ""
if [ -n "$AUTH_URL" ]; then
  echo "AUTHENTICATION REQUIRED:"
  echo "Visit: $AUTH_URL"
  echo ""
else
  echo "The server will automatically send '/auth login device' when it starts."
  echo ""
  echo "Watch the logs for the authentication URL:"
  echo "   journalctl -u hytale -f --no-pager -o cat"
  echo ""
fi
echo "NEXT STEPS:"
echo "1) Complete authentication using the URL above (or in logs)"
echo ""
echo "2) Manage the service:"
echo "   sudo systemctl status hytale"
echo "   sudo systemctl restart hytale"
echo ""
echo "3) View logs:"
echo "   journalctl -u hytale -f"
echo ""
echo "=========================================="
echo "SERVER DETAILS:"
echo "IP Address: $SERVER_IP:$PORT"
echo "Auto-restart: Every 3 days"
echo "=========================================="
}

# ================= MAIN =================
show_menu
