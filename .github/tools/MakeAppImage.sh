#!/bin/bash

set -x
set -v

# Vars
PACKAGE=PrusaSlicer
DESKTOP=/usr/resources/applications/${PACKAGE}.desktop
ICON=/usr/resources/icons/${PACKAGE}.png
APP_DIR="$PRUSA_REPO_DIR/AppDir"

export ARCH="$(uname -m)"
export APPIMAGE_EXTRACT_AND_RUN=1

APPIMAGETOOL="https://github.com/AppImage/appimagetool/releases/download/continuous/appimagetool-$ARCH.AppImage"
UPINFO="gh-releases-zsync|$(echo $GITHUB_REPOSITORY | tr '/' '|')|latest|*$ARCH*.AppImage.zsync"
LIB4BN="https://raw.githubusercontent.com/VHSgunzo/sharun/refs/tags/v0.4.4/lib4bin"

# Prepare AppDir
cd "$PRUSA_REPO_DIR"
mkdir -p "./AppDir/shared/lib" \
  "./AppDir/usr/share/applications" \
  "./AppDir/etc"

cd "$APP_DIR"

cp -r "/usr/resources"	./usr/

cp "$DESKTOP"		./usr/share/applications
cp "$DESKTOP"		./
cp "$ICON"              ./

ln -s ./usr/share        ./share
ln -s ./usr/resources    ./resources

# ADD LIBRARIES
rm -f ./lib4bin
wget "https://raw.githubusercontent.com/VHSgunzo/sharun/refs/tags/v0.4.4/lib4bin" -O ./lib4bin
chmod +x ./lib4bin
export ARCH="$(uname -m)"
xvfb-run -a -- ./lib4bin -p -v -e -s -k \
  /usr/bin/prusa-slicer \
  /usr/bin/OCCTWrapper.so \
  /usr/lib/"$ARCH"-linux-gnu/libwebkit2gtk* \
  /usr/lib/"$ARCH"-linux-gnu/gdk-pixbuf-*/*/*/* \
  /usr/lib/"$ARCH"-linux-gnu/gio/modules/* \
  /usr/lib/"$ARCH"-linux-gnu/*libnss*.so* \
  /usr/lib/"$ARCH"-linux-gnu/libGL* \
  /usr/lib/"$ARCH"-linux-gnu/libvulkan* \
  /usr/lib/"$ARCH"-linux-gnu/dri/*

# Prusa installs this library in bin normally, so we will place a symlink just in case it is needed
if [ -f ./shared/lib/bin/OCCTWrapper.so ]; then
  ln -s ./shared/lib/bin/OCCTWrapper.so ./bin/OCCTWrapper.so
fi

# NixOS does not have /usr/lib/locale nor /usr/share/locale, which PrusaSlicer expects
cp -r /usr/lib/locale ./lib/
sed -i -e 's|/usr/lib/locale|././/lib/locale|g' ./bin/prusa-slicer # Since we cannot get LOCPATH to work properly
cp -r /usr/share/locale ./share/
sed -i -e 's|/usr/share/locale|././/share/locale|g' ./shared/lib/libc.so.6 # Since we cannot get LOCPATH to work properly
sed -i -e 's|/usr/lib/locale|././/lib/locale|g' ./shared/lib/libc.so.6  # Since we cannot get LOCPATH to work properly

# Create environment
echo 'SHARUN_WORKING_DIR=${SHARUN_DIR}
GSETTINGS_BACKEND=memory
unset LD_LIBRARY_PATH
unset LD_PRELOAD' > ./.env
# LOCPATH=${SHARUN_DIR}/lib/locale:${SHARUN_DIR}/share/locale # This makes PrusaSlicer fail

# Prepare sharun
ln ./sharun ./AppRun
./sharun -g

# Get AppImageTool
cd "$GITHUB_WORKSPACE"
rm -f ./appimagetool
wget -q "$APPIMAGETOOL" -O ./appimagetool
chmod +x ./appimagetool

# Make AppImage with static runtime
#UNUSED_APPIMAGETOOL_OPTS=" --comp zstd --mksquashfs-opt -Xcompression-level --mksquashfs-opt 22 "
cd "${THIS_REPO_DIR}"
../appimagetool -n -u "$UPINFO" "$APP_DIR" "${THIS_REPO_DIR}/${PACKAGE}-${VERSION}-${ARCH}_GN.AppImage"

# Upload to GitHub Releases
list=$(gh release list -R "$1" --json tagName | jq -r 'map(select(true))[] | (.tagName)');
for i in $list; do
  if [ "$i" = "${VERSION}" ]; then
    gh release delete $VERSION -y
  fi
done
gh release create $VERSION *.AppImage* --title "$VERSION"
