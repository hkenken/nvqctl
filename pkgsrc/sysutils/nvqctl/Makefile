# $NetBSD$

DISTNAME=	nvqctl-0.1.2
CATEGORIES=	sysutils
MASTER_SITES=	${MASTER_SITE_GITHUB:=hkenken/}
GITHUB_TAG=	v${PKGVERSION_NOREV}

MAINTAINER=	hkenken@NetBSD.org
HOMEPAGE=	https://github.com/hkenken/nvqctl
COMMENT=	NVMM/QEMU virtual machine control for NetBSD
LICENSE=	2-clause-bsd

DEPENDS+=	qemu-[0-9]*:../../emulators/qemu

ONLY_FOR_PLATFORM=	NetBSD-*-x86_64

USE_LANGUAGES=	# none
NO_BUILD=	yes
NO_CONFIGURE=	yes

USE_TOOLS+=	sed

PKG_SYSCONFSUBDIR=	nvqctl

EGDIR=			${PREFIX}/share/examples/nvqctl
CONF_FILES+=		${EGDIR}/nvqctl.conf \
			${PKG_SYSCONFDIR}/nvqctl.conf

INSTALLATION_DIRS+=	sbin
INSTALLATION_DIRS+=	share/examples/nvqctl
INSTALLATION_DIRS+=	share/examples/rc.d

CONF_FILES+=		${PREFIX}/share/examples/rc.d/nvqctl \
			/etc/rc.d/nvqctl

OWN_DIRS+=		${PKG_SYSCONFDIR}/vm
OWN_DIRS+=		/var/run/nvqctl

SUBST_CLASSES+=		paths
SUBST_STAGE.paths=	pre-install
SUBST_MESSAGE.paths=	Fixing hardcoded paths.
SUBST_FILES.paths=	bin/nvqctl
SUBST_FILES.paths+=	rc.d/nvqctl
SUBST_SED.paths=	-e 's,/usr/local/etc/nvqctl,${PKG_SYSCONFDIR},g'
SUBST_SED.paths+=	-e 's,/usr/local/share/examples/nvqctl,${PREFIX}/share/examples/nvqctl,g'
SUBST_SED.paths+=	-e 's,@PREFIX@,${PREFIX},g'

do-install:
	${INSTALL_SCRIPT} ${WRKSRC}/bin/nvqctl \
		${DESTDIR}${PREFIX}/sbin/nvqctl
	${INSTALL_DATA} ${WRKSRC}/etc/nvqctl.conf \
		${DESTDIR}${EGDIR}/nvqctl.conf
	${INSTALL_DATA} ${WRKSRC}/share/examples/example.conf \
		${DESTDIR}${EGDIR}/example.conf
	${INSTALL_SCRIPT} ${WRKSRC}/rc.d/nvqctl \
		${DESTDIR}${PREFIX}/share/examples/rc.d/nvqctl

.include "../../mk/bsd.pkg.mk"

