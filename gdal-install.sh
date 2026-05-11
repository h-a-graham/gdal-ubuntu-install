#!/bin/bash
set -e

echo "🌍 GDAL Latest Version Installer"
echo "=================================="

# Check if running as root
if [[ $EUID -eq 0 ]]; then
   echo "❌ This script should not be run as root directly."
   echo "   Run it as a regular user with sudo access."
   exit 1
fi

# Check if sudo is available
if ! command -v sudo &> /dev/null; then
    echo "❌ sudo is required but not installed."
    exit 1
fi

echo "🔍 Fetching latest GDAL version..."

GDAL_PAGE=$(curl -s https://download.osgeo.org/gdal/CURRENT/)
if [ $? -ne 0 ]; then
    echo "❌ Failed to fetch GDAL version page"
    exit 1
fi

GDAL_TAR=$(echo "$GDAL_PAGE" | grep -o 'gdal-[0-9]\+\.[0-9]\+\.[0-9]\+\.tar\.gz' | head -1)
if [ -z "$GDAL_TAR" ]; then
    echo "❌ Could not find GDAL tar.gz file in the current directory"
    exit 1
fi

GDAL_VERSION=$(echo "$GDAL_TAR" | sed 's/gdal-\([0-9]\+\.[0-9]\+\.[0-9]\+\)\.tar\.gz/\1/')
GDAL_DIR="gdal-$GDAL_VERSION"
GDAL_URL="https://download.osgeo.org/gdal/CURRENT/$GDAL_TAR"

echo "✅ Found latest GDAL version: $GDAL_VERSION"
echo "📦 Download URL: $GDAL_URL"

echo "📦 Updating package list..."
sudo apt update
sudo ldconfig

echo "Adding arrow certificates repository..."
sudo apt install -y -V ca-certificates lsb-release wget
ARROW_DEB="apache-arrow-apt-source-latest-$(lsb_release --codename --short).deb"
ARROW_URL="https://packages.apache.org/artifactory/arrow/$(lsb_release --id --short | tr 'A-Z' 'a-z')/${ARROW_DEB}"

if dpkg -s apache-arrow-apt-source &>/dev/null; then
    echo "apache-arrow-apt-source already installed ($(dpkg-query -W -f='${Version}' apache-arrow-apt-source)); skipping repo config install."
else
    wget -N "$ARROW_URL"
    sudo apt install -y -V "./${ARROW_DEB}"
fi
sudo apt update
sudo apt install -y --only-upgrade libarrow-dev libparquet-dev || true


echo "🔨 Installing build dependencies..."
sudo apt install -y build-essential cmake git

# GDAL dependencies
sudo apt install -y libproj-dev libgeos-dev libsqlite3-dev libcurl4-openssl-dev
# Image format libraries
sudo apt install -y libtiff5-dev libgeotiff-dev libpng-dev libjpeg-dev libgif-dev
# NetCDF support
sudo apt install -y libnetcdf-dev libhdf5-dev

# Compression libraries
sudo apt install -y libblosc-dev
sudo apt install -y libblosc1 python3-blosc
sudo apt install -y liblz4-1 liblz4-dev libzstd1 libzstd-dev

# Parquet/Arrow support (may not be available in all repositories)
sudo apt install -y libarrow-dev libparquet-dev

# ExprTk and muparser support for VRT expression pixel functions 
sudo apt install -y libexprtk-dev libmuparser-dev


BUILD_DIR=$(mktemp -d)
cd "$BUILD_DIR"
echo "🏗️  Building in temporary directory: $BUILD_DIR"

echo "⬇️  Downloading GDAL $GDAL_VERSION..."
wget "$GDAL_URL"
if [ ! -f "$GDAL_TAR" ]; then
    echo "❌ Failed to download $GDAL_TAR"
    exit 1
fi

echo "📂 Extracting source code..."
tar -xzf "$GDAL_TAR"
if [ ! -d "$GDAL_DIR" ]; then
    echo "❌ Failed to extract GDAL source"
    exit 1
fi

cd "$GDAL_DIR"
mkdir build && cd build

echo "🔧 Running CMake configuration..."
cmake .. \
    -DCMAKE_BUILD_TYPE=Release \
    -DGDAL_USE_MUPARSER=ON \
    -DGDAL_USE_NETCDF=ON \
    -DGDAL_USE_ARROW=ON \
    -DGDAL_USE_EXPRTK=ON \
    -DGDAL_USE_PARQUET=ON 

echo "🔨 Building GDAL (this may take a while)..."
make -j$(nproc)

echo "📦 Installing GDAL..."
sudo make install

echo "🔗 Updating library cache..."
sudo ldconfig

echo "🧹 Cleaning up temporary files..."
cd /
sudo rm -rf "$BUILD_DIR"

echo "✅ Verifying installation..."
if command -v gdalinfo &> /dev/null; then
    INSTALLED_VERSION=$(gdalinfo --version | cut -d' ' -f2 | cut -d',' -f1)
    echo "🎉 GDAL successfully installed!"
    echo "   Version: $INSTALLED_VERSION"
    echo "   Location: $(which gdalinfo)"
else
    echo "❌ GDAL installation verification failed"
    exit 1
fi

echo ""
echo "🌟 Installation complete!"
echo "   You can now use GDAL commands."