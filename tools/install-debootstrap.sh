#!/usr/bin/env sh

cdebootstrap_version=$(curl http://ftp.us.debian.org/debian/pool/main/c/cdebootstrap/ | \
                        grep -oE "cdeb.*amd64\.deb\"" | \
                        tr -d '"' | \
                        sed -n "1p")

CDEBOOTSTRAP_STATIC_DEB_URL=${CDEBOOTSTRAP_STATIC_DEB_URL:-"https://ftp.debian.org/debian/pool/main/c/cdebootstrap/$cdebootstrap_version"}

# install_debootstrap [dest_dir] [bin_cache_dir]
#
# download and extract the cdebootstrap-static Debian package, then install
# the binary and its supporting files into the target root filesystem.
# The main binary is renamed to "cdebootstrap" and placed in ${dest_dir}/usr/bin/.
#
# args:
# - dest_dir (default=current dir): target directory to install debootstrap
# - bin_cache_dir (default=$BINARIES_DIST): download and cache binaries
#
# envs:
# - CDEBOOTSTRAP_STATIC_DEB_URL: package from which cdebootstrap-static is extracted
# - BINARIES_DIST: default path for caching downloaded binaries
install_debootstrap() {
	dest_dir=${1:-$PWD}
	bin_cache_dir=${2:-$BINARIES_DIST}

	wget "$CDEBOOTSTRAP_STATIC_DEB_URL" --no-clobber -O "$bin_cache_dir/cdebootstrap-static.deb"
	tmp=$(mktemp -d debootstrap.XXXX)
	cd "$tmp" || exit
	ar x "$bin_cache_dir/cdebootstrap-static.deb"
	tar xf data.tar.xz

	cp -a usr "$dest_dir/"

	mv "$dest_dir/usr/bin/cdebootstrap-static" "$dest_dir/usr/bin/cdebootstrap"

	cd ..
	rm -rf "$tmp"
}

install_debootstrap "$@"
