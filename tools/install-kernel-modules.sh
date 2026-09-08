#!/usr/bin/env sh

kernel_version=$(curl https://deb.debian.org/debian/pool/main/l/linux-signed-amd64/ | \
                    grep -o 'linux-image.*-amd64.*\amd64.deb\"' | \
                    grep -v dbg | \
                    tr -d '"' | \
                    sed -n "1p")

KERNEL_DEB_URL=${KERNEL_DEB_URL:-"https://deb.debian.org/debian/pool/main/l/linux-signed-amd64/$kernel_version"}

# install_kernel_modules <dest_dir> [bin_cache_dir]
#
# install kernel modules on specified directory.
# dest_dir should contain ${dest_dir}"/usr/share/kernel-modules.lst
# file. This file have a list of required kernel modules for your
# linux. Modules will installed on lib/modules/6.1.0-42-amd64/
# Download required binary and cache them on specified directory.
#
# args:
# - dest_dir: target direcory to install kernel modules
# - bin_cache_dir (default=$BINARIES_DIST): download and cache binaries
#
# envs:
# - KERNEL_DEB_URL: modules will extracted form this debian package
# - BINARIES_DIST: default path for caching downloaded binaries
install_kernel_modules() {
	dest_dir=$1
	bin_cache_dir=${2:-$BINARIES_DIST}

	if [ -z "$dest_dir" ]; then
		echo "Error: dest_dir is required" >&2
		exit 1
	fi
	if [ -z "$bin_cache_dir" ]; then
		echo "Error: bin_cache_dir not set and BINARIES_DIST not defined" >&2
		exit 1
	fi

	wget "${KERNEL_DEB_URL}" --no-clobber -O "${bin_cache_dir}/linux-image.deb"

	tmp=$(mktemp -d kernel.XXXX)
	cd "${tmp}" || exit
	ar x "${bin_cache_dir}/linux-image.deb"
	tar xf data.tar.xz

	kmod_dir="${dest_dir}/lib/modules/*-amd64"
	mkdir -p "$kmod_dir"

	cp -a lib/modules/*-amd64/modules.* "$kmod_dir/"

	modules=$(cat "${dest_dir}/usr/share/kernel-modules.lst")

	for mod in ${modules}; do
		find lib -type f -name "*$mod*.ko" -exec cp --parents {} "${dest_dir}/" \;
	done

	cd ..
	rm -rf "${tmp}"
}

install_kernel_modules "$@"
