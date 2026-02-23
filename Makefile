# nvqctl Makefile
#
# Usage:
#   make install      Install nvqctl
#   make uninstall    Remove nvqctl (preserves configs)
#   make check        Syntax check (POSIX sh)

PREFIX?=	/usr/local
CONFDIR?=	${PREFIX}/etc/nvqctl
MANDIR?=	${PREFIX}/share/man
EXAMPLEDIR?=	${PREFIX}/share/examples/nvqctl
RCDIR?=		/etc/rc.d

INSTALL?=	install
INSTALL_PROGRAM=	${INSTALL} -m 755
INSTALL_DATA=		${INSTALL} -m 644
INSTALL_DIR=		${INSTALL} -d -m 755

.PHONY: all install uninstall check clean

all:
	@echo "Run 'make install' to install nvqctl."

install:
	${INSTALL_DIR} ${DESTDIR}${PREFIX}/sbin
	${INSTALL_DIR} ${DESTDIR}${CONFDIR}/vm
	${INSTALL_DIR} ${DESTDIR}${EXAMPLEDIR}
	${INSTALL_DIR} ${DESTDIR}${MANDIR}/man8
	${INSTALL_DIR} ${DESTDIR}${RCDIR}
	${INSTALL_DIR} ${DESTDIR}/var/run/nvqctl
	${INSTALL_PROGRAM} bin/nvqctl ${DESTDIR}${PREFIX}/sbin/nvqctl
	sed 's|@PREFIX@|${PREFIX}|g' rc.d/nvqctl > ${DESTDIR}${RCDIR}/nvqctl
	chmod 755 ${DESTDIR}${RCDIR}/nvqctl
	${INSTALL_DATA} share/examples/example.conf ${DESTDIR}${EXAMPLEDIR}/example.conf
	@if [ ! -f ${DESTDIR}${CONFDIR}/nvqctl.conf ]; then \
		${INSTALL_DATA} etc/nvqctl.conf ${DESTDIR}${CONFDIR}/nvqctl.conf; \
		echo "Installed default config: ${CONFDIR}/nvqctl.conf"; \
	else \
		echo "Preserved existing config: ${CONFDIR}/nvqctl.conf"; \
	fi
	@if [ -f share/man/man8/nvqctl.8 ]; then \
		${INSTALL_DATA} share/man/man8/nvqctl.8 ${DESTDIR}${MANDIR}/man8/nvqctl.8; \
	fi
	@echo ""
	@echo "nvqctl installed successfully."
	@echo ""
	@echo "  Binary:   ${PREFIX}/sbin/nvqctl"
	@echo "  Config:   ${CONFDIR}/nvqctl.conf"
	@echo "  VM dir:   ${CONFDIR}/vm/"
	@echo "  Examples: ${EXAMPLEDIR}/"
	@echo "  rc.d:     ${RCDIR}/nvqctl"
	@echo ""
	@echo "Quick start:"
	@echo "  nvqctl create myvm"
	@echo "  nvqctl config myvm"
	@echo "  nvqctl start myvm"

uninstall:
	rm -f ${DESTDIR}${PREFIX}/sbin/nvqctl
	rm -f ${DESTDIR}${RCDIR}/nvqctl
	rm -f ${DESTDIR}${MANDIR}/man8/nvqctl.8
	rm -rf ${DESTDIR}${EXAMPLEDIR}
	@echo "nvqctl removed. Config preserved in ${CONFDIR}/"

check:
	@echo "Checking POSIX sh syntax..."
	@sh -n bin/nvqctl && echo "bin/nvqctl: OK"
	@sh -n rc.d/nvqctl && echo "rc.d/nvqctl: OK"

clean:
	@echo "Nothing to clean."
