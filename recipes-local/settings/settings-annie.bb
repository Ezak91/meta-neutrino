DESCRIPTION = "Sortierte Senderliste SAT 19.2E-13.0E-23.5E-28.2E-26.0E-0.8W-5.0W von Annie"
LICENSE = "BSD-2-Clause"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/BSD-2-Clause;md5=8bef8e6712b1be5aa76af1ebde9d6378"
HOMEPAGE = "https://github.com/neutrino-hd/settings-annie"

S = "${WORKDIR}/git"

SRCREV = "${AUTOREV}"

RREPLACES_${PN} = "settings-matze-astra settings-matze-astra+hb settings-pathauf"
RCONFLICTS_${PN} = "settings-pathauf settings-matze-astra+hb settings-matze-astra"

SRC_URI = "git://github.com/neutrino-hd/settings-annie.git;protocol=https"

do_install () {
	install -d ${D}/etc/neutrino/config/zapit  
        install -m 644 ${S}/*.xml ${D}/etc/neutrino/config/zapit
}

FILES_${PN} = "\
    /etc/neutrino/config/zapit \
"