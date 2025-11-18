#!/bin/bash
set -e

echo "🚀 Installing GDAL and related packages..."

# Add UbuntuGIS-unstable PPA
sudo add-apt-repository ppa:ubuntugis/ubuntugis-unstable

# Update package lists
sudo apt update

# Install GDAL and related packages
sudo apt install -y gdal-bin libudunits2-dev libgdal-dev libgeos-dev libproj-dev libsqlite3-dev


# Verify installation
if command -v gdal-config >/dev/null 2>&1; then
    echo "✅ GDAL installation successful."
    gdal-config --version
else
    echo "❌ GDAL installation failed."
    exit 1
fi    