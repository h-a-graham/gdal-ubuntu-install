echo "🔍 Searching for GDAL plugin directories..."
GDAL_PLUGIN_DIRS=$(find / -type d -name "gdalplugins" 2>/dev/null)
for dir in $GDAL_PLUGIN_DIRS; do
  echo "Checking $dir..."
  if find "$dir" -type f -name "*.so" -exec ldd {} \; | grep -q libgdal.so.30; then
    echo "⚠️  Plugins referencing libgdal.so.30 found in: $dir"
  fi
done
echo "✅ GDAL plugin scan complete."