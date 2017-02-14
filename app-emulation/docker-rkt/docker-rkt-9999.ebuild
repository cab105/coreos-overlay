# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

DESCRIPTION="Wrapper for docker hosted inside rkt"
HOMEPAGE=""
SRC_URI=""

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="amd64 ~arm64"
IUSE=""

DEPEND=""
RDEPEND="
	app-emulation/rkt
	!app-emulation/containerd
	!app-emulation/runc
	!app-emulation/docker
	!app-emulation/docker-bin
	!app-emulation/docker-proxy
"

inherit systemd

# Even though we ship all of the critical artifacts as a part of this ebuild,
# we need to ensure the source directory exists for ebuild to function properly
src_unpack() {
	mkdir "${S}"
}

src_install() {
	# copy wrapper files into place
	exeinto /usr/lib/coreos
	doexe "${FILESDIR}/containerd_wrapper"
	doexe "${FILESDIR}/dockerd_wrapper"

	exeinto /usr/bin
	doexe "${FILESDIR}/docker"

	systemd_dounit "${FILESDIR}/containerd.service"
	systemd_dounit "${FILESDIR}/docker.service"

	systemd_enable_service multi-user.target docker.service

	insinto /usr/lib/systemd/network
	doins "${FILESDIR}"/50-docker.network
	doins "${FILESDIR}"/90-docker-veth.network

	# Copy aci images into the package
	insinto /usr/lib/rkt/docker-images
	doins "${FILESDIR}"/runc.aci
	doins "${FILESDIR}"/containerd.aci
	doins "${FILESDIR}"/dockerd.aci
}
