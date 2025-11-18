#!/bin/bash
set -e

echo "🗑️  Removing existing GDAL installation..."

# Remove the active gdal-config file found in PATH
GDAL_CONFIG_PATH=$(command -v gdal-config 2>/dev/null || true)
if [ -n "$GDAL_CONFIG_PATH" ] && [ -f "$GDAL_CONFIG_PATH" ]; then
    echo "🗑️  Removing active gdal-config: $GDAL_CONFIG_PATH"
    sudo rm -f "$GDAL_CONFIG_PATH"
else
    echo "No active gdal-config found in PATH."
fi

# Purge GDAL and related packages
sudo apt purge -y gdal-bin || true
sudo apt purge -y libgdal-dev || true
sudo apt purge -y libproj-dev || true
sudo apt purge -y libgeos-dev || true
sudo apt purge -y libsqlite3-dev || true
sudo apt purge -y libcurl4-openssl-dev || true
sudo apt autoremove -y

# Remove manually installed GDAL files (if any)
sudo rm -rf /usr/local/bin/gdal* || true
sudo rm -rf /usr/local/lib/libgdal* || true
sudo rm -rf /usr/local/include/gdal || true
sudo rm -rf /usr/local/share/gdal || true

sudo ldconfig

echo "✅ GDAL cleanup complete."