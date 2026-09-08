#!/usr/bin/env sh

gpgv_version=$(curl https://ftp.debian.org/debian/pool/main/g/gnupg2/ | \
               grep -o 'gpgv-static.*_amd64\.deb\"' | \
               tr -d '"' | \
               sed -n "1p")

GPGV_DEB_URL=${GPGV_DEB_URL:-"https://ftp.debian.org/debian/pool/main/g/gnupg2/$gpgv_version"}

# install_gpgv [dest_dir] [bin_cache_dir]
#
# install gpgv binary on specified directpry.
# Download and cache kernel binary on bin_cache_dir
# path for later runs of script.
#
# args:
# - dest_dir (default=current dir): target direcory to install gpgv
# - bin_cache_dir (default=$BINARIES_DIST): download and cache binaries
#
# envs:
# - GPGV_DEB_URL: gpgv binary will extracted form this debian package
# - BINARIES_DIST: default path for caching downloaded binaries
install_gpgv() {
	dest_dir=${1:-$PWD}
	bin_cache_dir=${2:-$BINARIES_DIST}

	mkdir -p bin

	wget "$GPGV_DEB_URL" --no-clobber -O "$bin_cache_dir"/gpgv.deb
	tmp=$(mktemp -d gpgv.XXXX)
	cd "${tmp}" || exit
	ar x "$bin_cache_dir"/gpgv.deb
	tar xf data.tar.xz

	cp usr/bin/gpgv-static "$dest_dir"/bin/gpgv

	cd ..
	rm -rf "${tmp}"
}

install_gpgv "$@"
