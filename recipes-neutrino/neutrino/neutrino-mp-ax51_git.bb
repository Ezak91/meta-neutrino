SUMMARY = "Neutrino MP"
DESCRIPTION = "Neutrino-MP for AX HD51 Platform."
HOMEPAGE = "http://www.tuxbox.org"
SECTION = "libs"
LICENSE = "GPLv2"
LIC_FILES_CHKSUM = "file://${WORKDIR}/COPYING.GPL;md5=751419260aa954499f7abaabaa882bbe"

SRCREV = "${AUTOREV}"
PV = "${SRCPV}"

PATCHTOOL = "git"

SRC_URI = " \
	file://neutrino.ttf \
	file://neutrino.service \
	file://neutrino-log.service \
	file://neutrino.sh \
	file://timezone.xml \
	file://custom-poweroff.init \
	file://COPYING.GPL \
	file://pre-wlan0.sh \
	file://post-wlan0.sh \
	file://mount.mdev \
	file://etc.tar.gz \
	file://tobackup.conf \
	file://update.jpg \
"

include neutrino.inc
include ${FLAVOUR}.inc

do_configure_prepend() {
	cp ${WORKDIR}/neutrino.ttf ${S}/data/fonts
}
