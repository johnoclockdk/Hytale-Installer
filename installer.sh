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
  echo -e "${CYAN}==========================================${NC}"
  echo -e "${BOLD}${CYAN}   Hytale Dedicated Server Manager${NC}"
  echo -e "${CYAN}==========================================${NC}"
  echo ""
  echo -e "${BLUE}1)${NC} Install Hytale Server"
  echo -e "${BLUE}2)${NC} Update Hytale Server"
  echo -e "${BLUE}3)${NC} Uninstall Hytale Server"
  echo -e "${BLUE}4)${NC} Exit"
  echo ""
  read -p "Select an option [1-4]: " choice
  
  case $choice in
    1) install_server ;;
    2) update_server ;;
    3) uninstall_server ;;
    4) echo -e "${CYAN}Exiting...${NC}"; exit 0 ;;
    *) echo -e "${RED}Invalid option. Please try again.${NC}"; show_menu ;;
  esac
}

uninstall_server() {
  echo ""
  echo -e "${BOLD}${YELLOW}=== Uninstalling Hytale Server ===${NC}"
  echo ""
  
  # Use default port if CUSTOM_PORT is not set
  UNINSTALL_PORT=${CUSTOM_PORT:-$PORT}
  
  # Stop and disable service
  if systemctl is-active --quiet hytale 2>/dev/null; then
    echo -e "${BLUE}Stopping Hytale service...${NC}"
    sudo systemctl stop hytale
  fi
  
  if systemctl is-enabled --quiet hytale 2>/dev/null; then
    echo -e "${BLUE}Disabling Hytale service...${NC}"
    sudo systemctl disable hytale
  fi
  
  # Remove service file
  if [ -f "$SERVICE_FILE" ]; then
    echo -e "${BLUE}Removing service file...${NC}"
    sudo rm -f "$SERVICE_FILE"
    sudo systemctl daemon-reload
  fi
  
  # Remove cron job
  echo -e "${BLUE}Removing cron job...${NC}"
  ( sudo crontab -l 2>/dev/null | grep -v "systemctl restart hytale" ) | sudo crontab - 2>/dev/null || true
  
  # Remove server files
  if [ -d "$BASE_DIR" ]; then
    echo -e "${BLUE}Removing server files from $BASE_DIR...${NC}"
    rm -rf "$BASE_DIR"
  fi
  
  # Remove firewall rule
  if command -v ufw >/dev/null 2>&1; then
    echo -e "${BLUE}Removing firewall rule...${NC}"
    sudo ufw delete allow ${UNINSTALL_PORT}/udp 2>/dev/null || true
  fi
  
  echo ""
  echo -e "${GREEN}==========================================${NC}"
  echo -e "${BOLD}${GREEN}Uninstall complete!${NC}"
  echo -e "${GREEN}==========================================${NC}"
}

update_server() {
  echo ""
  echo -e "${BOLD}${YELLOW}=== Updating Hytale Server ===${NC}"
  echo ""
  
  # Check if server is installed
  if ! systemctl list-unit-files | grep -q hytale.service; then
    echo -e "${RED}ERROR: Hytale server is not installed.${NC}"
    echo -e "${YELLOW}Please install it first using option 1.${NC}"
    exit 1
  fi
  
  echo -e "${CYAN}[1/5]${NC} Stopping Hytale service..."
  sudo systemctl stop hytale
  
  echo -e "${CYAN}[2/5]${NC} Downloading Hytale Downloader..."
  cd "$BASE_DIR" || { echo -e "${RED}Failed to change to $BASE_DIR.${NC}" >&2; exit 1; }
  
  if [ ! -f "hytale-downloader-linux-amd64" ]; then
    if wget --no-cookies --no-cache --show-progress -O hytale-downloader.zip "$DOWNLOADER_URL"; then
      if unzip -q hytale-downloader.zip; then
        chmod +x hytale-downloader-linux-amd64
        rm -f hytale-downloader-windows-amd64.exe hytale-downloader.zip
      fi
    fi
  fi
  
  echo -e "${CYAN}[3/5]${NC} Downloading latest server files..."
  if ./hytale-downloader-linux-amd64; then
    echo -e "${GREEN}Server files downloaded.${NC}"
  else
    echo -e "${RED}Failed to download server files.${NC}" >&2
    exit 1
  fi
  
  DOWNLOADED_ZIP=$(ls -t *.zip 2>/dev/null | head -1)
  
  if [ -z "$DOWNLOADED_ZIP" ]; then
    echo -e "${RED}No zip file found after download.${NC}" >&2
    exit 1
  fi
  
  echo -e "${CYAN}[4/5]${NC} Extracting and updating server files..."
  echo -e "${BLUE}Extracting files:${NC}"
  if unzip -o "$DOWNLOADED_ZIP" | grep -E "(inflating|extracting):" | sed "s/^/  ${CYAN}→${NC} /"; then
    echo -e "${GREEN}✓ Extraction complete.${NC}"
  else
    echo -e "${RED}Failed to extract server files.${NC}" >&2
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
  
  echo -e "${CYAN}[5/5]${NC} Starting Hytale service..."
  sudo systemctl start hytale
  
  echo ""
  echo -e "${GREEN}==========================================${NC}"
  echo -e "${BOLD}${GREEN}Update complete!${NC}"
  echo -e "${BLUE}Check logs with: ${NC}journalctl -u hytale -f"
  echo -e "${GREEN}==========================================${NC}"
}

install_server() {
  echo ""
  echo -e "${BOLD}${CYAN}=== Installing Hytale Dedicated Server ===${NC}"
  echo ""
  
  # Check if already installed
  if systemctl is-active --quiet hytale 2>/dev/null; then
    echo -e "${YELLOW}WARNING: Hytale service is already running!${NC}"
    echo -e "${YELLOW}Please uninstall first using option 3.${NC}"
    exit 1
  fi

  # Port configuration
  echo -e "${CYAN}Port Configuration${NC}"
  read -p "Enter server port (default: 5520): " CUSTOM_PORT
  
  if [ -z "$CUSTOM_PORT" ]; then
    CUSTOM_PORT=$PORT
    echo -e "${BLUE}Using default port: ${CUSTOM_PORT}${NC}"
  else
    # Validate port number
    if ! [[ "$CUSTOM_PORT" =~ ^[0-9]+$ ]] || [ "$CUSTOM_PORT" -lt 1024 ] || [ "$CUSTOM_PORT" -gt 65535 ]; then
      echo -e "${RED}Invalid port number. Must be between 1024 and 65535.${NC}"
      exit 1
    fi
    echo -e "${GREEN}Using custom port: ${CUSTOM_PORT}${NC}"
  fi
  echo ""

echo -e "${CYAN}[1/8]${NC} Checking dependencies..."

# Check and install unzip if missing
if ! command -v unzip >/dev/null 2>&1; then
  echo -e "${BLUE}Installing unzip...${NC}"
  sudo apt-get update -qq
  sudo apt-get install -y unzip
  echo -e "${GREEN}✓ unzip installed.${NC}"
else
  echo -e "${GREEN}✓ unzip is already installed.${NC}"
fi

echo -e "${BLUE}Checking Java installation...${NC}"
JAVA_VERSION_OUTPUT=$(java -version 2>&1 || true)
JAVA_VERSION=$(echo "$JAVA_VERSION_OUTPUT" | awk -F[\".] '/version/ {print $2}')

if [[ "$JAVA_VERSION_OUTPUT" == *"25."* || "$JAVA_VERSION" == "25" ]]; then
  echo -e "${GREEN}✓ Java 25 is already installed.${NC}"
else
  echo -e "${BLUE}Installing Java 25...${NC}"
  if wget --no-cookies --no-cache -q --show-progress https://download.oracle.com/java/25/latest/jdk-25_linux-x64_bin.deb; then
    if sudo dpkg -i jdk-25_linux-x64_bin.deb; then
      echo -e "${GREEN}✓ Java 25 installed successfully.${NC}"
      rm jdk-25_linux-x64_bin.deb
    else
      echo -e "${RED}Failed to install Java.${NC}" >&2
      exit 1
    fi
  else
    echo -e "${RED}Failed to download Java installer.${NC}" >&2
    exit 1
  fi
fi

java --version || { echo "Java not found in PATH." >&2; exit 1; }

# Check available disk space
echo -e "${BLUE}Checking available disk space...${NC}"
REQUIRED_SPACE_MB=5120  # 5 GB in MB
AVAILABLE_SPACE_MB=$(df -BM "$(pwd)" | awk 'NR==2 {print $4}' | sed 's/M//')

if [ "$AVAILABLE_SPACE_MB" -lt "$REQUIRED_SPACE_MB" ]; then
  echo -e "${RED}ERROR: Insufficient disk space.${NC}"
  echo -e "${YELLOW}Required: ${REQUIRED_SPACE_MB} MB (5 GB)${NC}"
  echo -e "${YELLOW}Available: ${AVAILABLE_SPACE_MB} MB${NC}"
  exit 1
else
  echo -e "${GREEN}✓ Sufficient disk space available (${AVAILABLE_SPACE_MB} MB).${NC}"
fi


# ---- 2. Create directories ----
echo -e "${CYAN}[2/8]${NC} Creating directories..."
mkdir -p "$SERVER_DIR"


# ---- 3. Install Hytale Downloader CLI ----
echo -e "${CYAN}[3/8]${NC} Downloading Hytale Downloader..."

if wget --no-cookies --no-cache --show-progress -O hytale-downloader.zip "$DOWNLOADER_URL"; then
  echo -e "${GREEN}Hytale Downloader downloaded.${NC}"
else
  echo -e "${RED}Failed to download Hytale Downloader.${NC}" >&2
  exit 1
fi
echo -e "${BLUE}Extracting Hytale Downloader...${NC}"
if unzip -q hytale-downloader.zip; then
  echo -e "${GREEN}✓ Extraction complete.${NC}"
else
  echo -e "${RED}Failed to extract Hytale Downloader.${NC}" >&2
  exit 1
fi

chmod +x hytale-downloader-linux-amd64
rm -f hytale-downloader-windows-amd64.exe hytale-downloader.zip

if [ "$(realpath QUICKSTART.md)" != "$BASE_DIR/QUICKSTART.md" ]; then
  mv QUICKSTART.md "$BASE_DIR/"
fi

if [ "$(realpath hytale-downloader-linux-amd64)" != "$BASE_DIR/hytale-downloader-linux-amd64" ]; then
  mv hytale-downloader-linux-amd64 "$BASE_DIR/"
fi


# ---- 4. Download server files ----
echo -e "${CYAN}[4/8]${NC} Downloading Hytale server files..."
cd "$BASE_DIR" || { echo -e "${RED}Failed to change to $BASE_DIR.${NC}" >&2; exit 1; }
if ./hytale-downloader-linux-amd64; then
  echo -e "${GREEN}Server files downloaded.${NC}"
else
  echo -e "${RED}Failed to download server files.${NC}" >&2
  exit 1
fi

# Expected structure: The downloader creates a zip file like "2026.01.15-c04fdfe10.zip"
# Find the most recently created zip file
DOWNLOADED_ZIP=$(ls -t *.zip 2>/dev/null | head -1)

if [ -z "$DOWNLOADED_ZIP" ]; then
  echo -e "${RED}No zip file found after download.${NC}" >&2
  exit 1
fi

echo -e "${BLUE}Extracting $DOWNLOADED_ZIP...${NC}"
echo -e "${BLUE}Extracting files:${NC}"
if unzip -o "$DOWNLOADED_ZIP" | grep -E "(inflating|extracting):" | sed "s/^/  ${CYAN}→${NC} /"; then
  echo -e "${GREEN}✓ Extraction complete.${NC}"
else
  echo -e "${RED}Failed to extract server files.${NC}" >&2
  exit 1
fi

# Expected structure after extraction: Server/ Assets.zip
echo -e "${BLUE}Copying server files to $SERVER_DIR...${NC}"
if [ -d "Server" ]; then
  FILE_COUNT=$(find Server -type f | wc -l)
  echo -e "${BLUE}Copying ${FILE_COUNT} files...${NC}"
  cp -rv Server/* "$SERVER_DIR/" 2>&1 | grep -v "^'" | sed "s/^/  ${CYAN}→${NC} /" || { echo -e "${RED}Failed to copy server files.${NC}" >&2; exit 1; }
  echo -e "${GREEN}✓ Server files copied.${NC}"
else
  echo -e "${RED}Server directory not found after extraction.${NC}" >&2
  exit 1
fi

if [ -f "Assets.zip" ]; then
  ASSETS_SIZE=$(du -h Assets.zip | cut -f1)
  echo -e "${BLUE}Copying Assets.zip (${ASSETS_SIZE})...${NC}"
  cp "Assets.zip" "$SERVER_DIR/" || { echo -e "${RED}Failed to copy Assets.zip.${NC}" >&2; exit 1; }
  echo -e "${GREEN}✓ Assets.zip copied.${NC}"
else
  echo -e "${RED}Assets.zip not found after extraction.${NC}" >&2
  exit 1
fi

# Clean up temporary files
echo -e "${BLUE}Cleaning up temporary files...${NC}"
rm -f "$DOWNLOADED_ZIP"
rm -rf Server
rm -f Assets.zip
rm -f QUICKSTART.md

echo -e "${CYAN}[5/8]${NC} Installing dependencies and creating server start script..."
# Install expect if not already installed
if ! command -v expect >/dev/null 2>&1; then
  echo -e "${BLUE}Installing expect...${NC}"
  sudo apt-get update -qq
  sudo apt-get install -y expect
fi

cat << EOF > "$SERVER_DIR/start.sh"
#!/bin/bash
SCRIPT_DIR="\$(cd "\$(dirname "\$0")" && pwd)"
cd "\$SCRIPT_DIR"
LOGS_DIR="\$SCRIPT_DIR/logs"

# Monitor auth status in background
monitor_auth() {
  # Wait for logs directory to be created
  while [ ! -d "\$LOGS_DIR" ]; do
    sleep 1
  done
  
  # Monitor the latest log file for successful authentication
  while true; do
    # Always get the most recent log file (in case server restarts)
    LATEST_LOG=\$(ls -t "\$LOGS_DIR"/*.log 2>/dev/null | head -1)
    if [ -n "\$LATEST_LOG" ]; then
      # Check for successful auth completion (look for auth success indicators)
      if grep -qE "Authenticated as|Authentication successful|Auth credential store|Server tokens configured" "\$LATEST_LOG" 2>/dev/null; then
        # Double-check it's not the initial "No server tokens" message
        if ! grep -q "No server tokens configured" "\$LATEST_LOG" 2>/dev/null || grep -qE "Authenticated as|Authentication successful" "\$LATEST_LOG" 2>/dev/null; then
          # Verify auth actually succeeded by checking for credential store after auth command
          if grep -q "Auth credential store" "\$LATEST_LOG" 2>/dev/null; then
            touch "\$SCRIPT_DIR/.authenticated"
            echo "[AUTH] Authentication successful - marked as authenticated"
            echo "[AUTH] File created: \$SCRIPT_DIR/.authenticated"
            exit 0
          fi
        fi
      fi
    fi
    sleep 3
  done
}

# Check if this is the first run (no auth token file exists)
FIRST_RUN=false
if [ ! -f "\$SCRIPT_DIR/.authenticated" ]; then
  FIRST_RUN=true
fi

while true; do
  echo "Starting Hytale Server..."
  
  if [ "\$FIRST_RUN" = true ]; then
    # Start auth monitor in background
    monitor_auth &
    MONITOR_PID=\$!
    
    # First run: auto-authenticate using expect
    expect << 'EXPECT_EOF'
set timeout -1
spawn java -jar HytaleServer.jar --assets Assets.zip

# Wait for "No server tokens configured" message and send auth command
expect {
  "No server tokens configured" {
    send "/auth login device\r"
    exp_continue
  }
  "Visit: https://oauth.accounts.hytale.com" {
    exp_continue
  }
  eof
}
EXPECT_EOF
    
    # Kill monitor if still running
    kill \$MONITOR_PID 2>/dev/null || true
    
    # Check if authentication was successful
    if [ -f "\$SCRIPT_DIR/.authenticated" ]; then
      FIRST_RUN=false
      echo "[INFO] Server authenticated successfully"
    else
      echo "[WARN] Authentication may not be complete. Check logs in \$LOGS_DIR/"
    fi
  else
    # Subsequent runs: just start the server normally
    java -jar HytaleServer.jar --assets Assets.zip
  fi
  
  echo "Server stopped. Restarting in 5 seconds..."
  sleep 5
done
EOF


chmod +x "$SERVER_DIR/start.sh"
echo -e "${GREEN}Start script created at $SERVER_DIR/start.sh.${NC}"

echo -e "${CYAN}[6/8]${NC} Creating systemd service..."
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


echo -e "${BLUE}Reloading systemd, enabling and starting service...${NC}"
sudo systemctl daemon-reload
sudo systemctl enable hytale
sudo systemctl start hytale
if systemctl is-active --quiet hytale; then
  echo -e "${GREEN}Hytale service started successfully.${NC}"
else
  echo -e "${RED}Hytale service failed to start.${NC}" >&2
  exit 1
fi


# ---- 7. Open firewall (UDP / QUIC) ----
echo -e "${CYAN}[7/8]${NC} Configuring firewall..."
if command -v ufw >/dev/null 2>&1; then
  echo -e "${BLUE}Configuring UFW firewall...${NC}"
  sudo ufw allow ${CUSTOM_PORT}/udp
  echo -e "${GREEN}UFW rule added for UDP port ${CUSTOM_PORT}.${NC}"
else
  echo -e "${YELLOW}UFW not found. Please ensure UDP port ${CUSTOM_PORT} is open.${NC}"
fi


# ---- 8. Schedule 3-day service restart ----
echo -e "${CYAN}[8/8]${NC} Scheduling automatic service restart every 3 days..."
( sudo crontab -l 2>/dev/null | grep -v "systemctl restart hytale" ; echo "$RESTART_CRON" ) | sudo crontab -
echo -e "${GREEN}Service restart cron job set.${NC}"


# ---- DONE ----
echo ""
echo -e "${CYAN}[9/9]${NC} Finalizing installation..."

# Get server IPv4 address
SERVER_IP=$(hostname -I | grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}' | head -n1)

echo "Waiting for server to start and generate authentication URL..."
AUTH_URL=""
for i in {1..6}; do
  sleep 10
  # Try to get auth URL from journalctl
  AUTH_URL=$(journalctl -u hytale -n 150 --no-pager -o cat 2>/dev/null | grep -oP 'https://oauth\.accounts\.hytale\.com/oauth2/device/verify\?user_code=[A-Za-z0-9]+' | tail -1)
  
  # If not found in journalctl, try the logs folder
  if [ -z "$AUTH_URL" ] && [ -d "$SERVER_DIR/logs" ]; then
    LATEST_LOG=$(ls -t "$SERVER_DIR/logs"/*.log 2>/dev/null | head -1)
    if [ -n "$LATEST_LOG" ]; then
      AUTH_URL=$(grep -oP 'https://oauth\.accounts\.hytale\.com/oauth2/device/verify\?user_code=[A-Za-z0-9]+' "$LATEST_LOG" 2>/dev/null | tail -1)
    fi
  fi
  
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
  echo "   OR"
  echo "   tail -f $SERVER_DIR/logs/*.log"
  echo ""
fi
echo "NEXT STEPS:"
echo "1) Complete authentication using the URL above (or in logs)"
echo "   - The .authenticated file will be created automatically after successful auth"
echo ""
echo "2) Manage the service:"
echo "   sudo systemctl status hytale"
echo "   sudo systemctl restart hytale"
echo ""
echo "3) View logs:"
echo "   journalctl -u hytale -f"
echo "   OR"
echo "   tail -f $SERVER_DIR/logs/*.log"
echo ""
echo "4) Check authentication status:"
echo "   ls -la $SERVER_DIR/.authenticated"
echo ""
echo "=========================================="
echo "SERVER DETAILS:"
echo "IP Address: $SERVER_IP:$CUSTOM_PORT"
echo "Server Directory: $SERVER_DIR"
echo "Logs Directory: $SERVER_DIR/logs"
echo "Auto-restart: Every 3 days"
echo "=========================================="
}


# ================= COLORS =================
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color
# =========================================


# ================= MAIN =================
show_menu