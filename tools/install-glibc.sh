#!/usr/bin/env sh

glibc_version=$(curl https://ftp.debian.org/debian/pool/main/g/glibc/ | \
               grep -o 'libc.*amd64\.deb\"' | \
               tr -d '"' | \
               sed -n "1p")

GLIBC_DEB_URL=${GLIBC_DEB_URL:-"https://ftp.debian.org/debian/pool/main/g/glibc/$glibc_version"}

# install_glibc [dest_dir] [bin_cache_dir]
#
# download and extract the Debian glibc runtime package, then install the
# required shared libraries into the target root filesystem. Also create the
# dynamic linker symlink expected by dynamically linked executables.
#
# args:
# - dest_dir (default=current dir): target direcory to install glibc
# - bin_cache_dir (default=$BINARIES_DIST): download and cache binaries
#
# envs:
# - GLIBC_DEB_URL: glibc binary will extracted form this debian package
# - BINARIES_DIST: default path for caching downloaded binaries
install_glibc() {
	dest_dir=$1
	bin_cache_dir=${2:-$BINARIES_DIST}

	wget "$GLIBC_DEB_URL" --no-clobber -O "$bin_cache_dir"/glibc.deb
	tmp=$(mktemp -d libc.XXXX)
	cd "${tmp}" || exit
	ar x "$bin_cache_dir"/glibc.deb
	tar xf data.tar.xz

	mkdir -p "${dest_dir}"/lib64
	cp --parents -r usr/lib/x86_64-linux-gnu/*.* "$dest_dir"/
	cp --parents -r usr/lib64/* "$dest_dir"/
	ln -sfn /usr/lib64/ld-linux-x86-64.so.2  "$dest_dir/lib64/ld-linux-x86-64.so.2"
	cd ..
	rm -rf "${tmp}"
}

install_glibc "$@"
