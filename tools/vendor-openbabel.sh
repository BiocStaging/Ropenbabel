#!/bin/sh
# Refresh the vendored Open Babel source in src/openbabel-<version>.
# Run from the package root:  tools/vendor-openbabel.sh 3.2.1
set -eu
VER=${1:?usage: $0 <version, e.g. 3.2.1>}
TAG=openbabel-$(echo "$VER" | tr . -)
DEST=src/openbabel-$VER

rm -rf src/openbabel-*
TMP=$(mktemp -d)
curl -fsSL "https://github.com/openbabel/openbabel/archive/refs/tags/$TAG.tar.gz" \
  | tar -xz -C "$TMP"
mv "$TMP"/openbabel-"$TAG" "$DEST"
rmdir "$TMP"

# Drop what we never build, to keep the tarball under Bioconductor's 5 MB.
# test/ is ~220 MB on its own.
rm -rf "$DEST"/test "$DEST"/src/GUI "$DEST"/windows-* "$DEST"/.github
# The top-level CMakeLists does add_subdirectory() on doc/, scripts/ and
# tools/ unconditionally, so keep the dirs but stub them out. tools/ holds
# the obabel executables, which upstream links with -static; that fails
# against shared-only system libs such as Cairo, and R doesn't need them.
for d in doc scripts tools; do
  rm -rf "$DEST/$d" && mkdir -p "$DEST/$d"
  echo "# stubbed out by Ropenbabel tools/vendor-openbabel.sh" > "$DEST/$d/CMakeLists.txt"
done

# Local fixes (compiler warnings R CMD check flags, gcc/clang breakage, ...)
for p in tools/patches/*.patch; do
  [ -e "$p" ] || continue
  echo "applying $p"
  patch -d "$DEST" -p1 < "$p"
done

sed -i.bak "s/^OB_VERSION *=.*/OB_VERSION   = $VER/" src/Makevars.common && rm src/Makevars.common.bak
echo "Vendored Open Babel $VER into $DEST"
du -sh "$DEST"
