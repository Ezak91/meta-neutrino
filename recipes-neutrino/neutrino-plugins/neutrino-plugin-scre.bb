DESCRIPTION = "SC - reinit Plugin"
LICENSE = "BSD-2-Clause"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/BSD-2-Clause;md5=8bef8e6712b1be5aa76af1ebde9d6378"
HOMEPAGE = "https://github.com/neutrino-hd"
DEPENDS = "lua"
RDEPENDS_${PN} = "lua"
PV = "0.1"

SRC_URI = "file://scre.tar.gz \
"

S = "${WORKDIR}/"

do_install () {
	install -d ${D}/var/tuxbox/plugins
	install -m 644 ${S}/scre* ${D}/var/tuxbox/plugins
}