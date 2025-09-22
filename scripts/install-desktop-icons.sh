#!/bin/bash

# Install QryptChat icons to Linux desktop environment
# This script installs icons to the system icon theme for proper desktop integration

echo "🎨 Installing QryptChat icons for Linux desktop environments..."

# Define icon install paths
ICON_THEME_DIR="$HOME/.local/share/icons/hicolor"
DESKTOP_DIR="$HOME/.local/share/applications"

# Create icon theme directories
mkdir -p "$ICON_THEME_DIR"/{16x16,32x32,48x48,64x64,96x96,128x128,256x256,512x512}/apps

# Create hicolor theme index file (CRITICAL for desktop environments)
cat > "$ICON_THEME_DIR/index.theme" << 'EOF'
[Icon Theme]
Name=Hicolor
Comment=Fallback icon theme
Hidden=true
Directories=16x16/apps,32x32/apps,48x48/apps,64x64/apps,96x96/apps,128x128/apps,256x256/apps,512x512/apps

[16x16/apps]
Size=16
Context=Applications
Type=Fixed

[32x32/apps]
Size=32
Context=Applications
Type=Fixed

[48x48/apps]
Size=48
Context=Applications
Type=Fixed

[64x64/apps]
Size=64
Context=Applications
Type=Fixed

[96x96/apps]
Size=96
Context=Applications
Type=Fixed

[128x128/apps]
Size=128
Context=Applications
Type=Fixed

[256x256/apps]
Size=256
Context=Applications
Type=Fixed

[512x512/apps]
Size=512
Context=Applications
Type=Fixed
EOF
echo "✅ Created hicolor theme index file"

# Copy icons to proper locations
echo "📁 Installing icons to $ICON_THEME_DIR..."

# Install proper icon sizes for Linux desktop environments
cp ./static/icons/icon-48x48.png "$ICON_THEME_DIR/48x48/apps/qryptchat.png" 2>/dev/null || echo "⚠️  48x48 icon not found"
cp ./static/icons/apple-touch-icon-72x72.png "$ICON_THEME_DIR/64x64/apps/qryptchat.png" 2>/dev/null || echo "⚠️  64x64 icon not found"
cp ./static/icons/icon-96x96.png "$ICON_THEME_DIR/96x96/apps/qryptchat.png" 2>/dev/null || echo "⚠️  96x96 icon not found"
cp ./static/icons/apple-touch-icon-152x152.png "$ICON_THEME_DIR/128x128/apps/qryptchat.png" 2>/dev/null || echo "⚠️  128x128 icon not found"
cp ./static/icons/icon-256x256.png "$ICON_THEME_DIR/256x256/apps/qryptchat.png" 2>/dev/null || echo "⚠️  256x256 icon not found"
cp ./static/icons/icon-512x512.png "$ICON_THEME_DIR/512x512/apps/qryptchat.png" 2>/dev/null || echo "⚠️  512x512 icon not found"

# Try to copy smaller sizes as fallbacks
if [ -f "./static/favicon-32.png" ]; then
    cp ./static/favicon-32.png "$ICON_THEME_DIR/32x32/apps/qryptchat.png"
    echo "✅ Installed 32x32 icon"
fi

if [ -f "./static/favicon-16.png" ]; then
    cp ./static/favicon-16.png "$ICON_THEME_DIR/16x16/apps/qryptchat.png"
    echo "✅ Installed 16x16 icon"
fi

echo "✅ Installed QryptChat icons to hicolor icon theme"

# Install desktop file
echo "📋 Installing desktop file to $DESKTOP_DIR..."
mkdir -p "$DESKTOP_DIR"
cp ./static/qryptchat.desktop "$DESKTOP_DIR/" 2>/dev/null || echo "⚠️  Desktop file not found"

if [ -f "$DESKTOP_DIR/qryptchat.desktop" ]; then
    chmod +x "$DESKTOP_DIR/qryptchat.desktop"
    echo "✅ Installed QryptChat desktop file"
else
    echo "❌ Failed to install desktop file"
fi

# Update icon cache
echo "🔄 Updating icon cache..."
if command -v gtk-update-icon-cache >/dev/null 2>&1; then
    gtk-update-icon-cache -f -t "$ICON_THEME_DIR" 2>/dev/null || echo "⚠️  Could not update GTK icon cache"
    echo "✅ Updated GTK icon cache"
fi

if command -v update-desktop-database >/dev/null 2>&1; then
    update-desktop-database "$DESKTOP_DIR" 2>/dev/null || echo "⚠️  Could not update desktop database"
    echo "✅ Updated desktop database"
fi

echo "
🎉 Installation complete!

📱 The QryptChat PWA should now display proper icons in:
   • KDE desktop environment
   • GNOME desktop environment  
   • System application menus
   • Taskbar/dock when installed

🔧 Manual steps (if icons still don't appear):
   1. Log out and log back in
   2. Clear browser cache and reinstall PWA
   3. Run: gtk-update-icon-cache -f ~/.local/share/icons/hicolor
   
📂 Icons installed to:
   • $ICON_THEME_DIR/*/apps/qryptchat.png
   • $DESKTOP_DIR/qryptchat.desktop
"