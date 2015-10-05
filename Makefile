# Created by: Sergey Kozlov <kozlov.sergey.404@gmail.com>
# $FreeBSD$

PORTNAME=	staf
PORTVERSION=	3.4.23
CATEGORIES=	devel net
MASTER_SITES=	http://prdownloads.sourceforge.net/staf/
DISTNAME=	STAF${PORTVERSION:S/.//g}-src

MAINTAINER=	kozlov.sergey.404@gmail.com
COMMENT=	Software Testing Automation Framework

LICENSE=	EPL

WRKSRC=		${WRKDIR}/src
WRKSRC_SUBDIR=	${PORTNAME}

MAKEFILE=	makefile
MAKE_ARGS=	OS_NAME="freebsd" \
		CC_CC=${CXX} \
		CC_C=${CC} \
		STAF_USE_SSL=${STAF_USE_SSL} \
		BUILD_TYPE=${STAF_BUILD_TYPE}

MAKE_JOBS_UNSAFE=	yes
USES=		gmake:lite
LD_CONFIG=	yes

OPTIONS_DEFINE=	DEBUG OPENSSL
OPTIONS_DEFAULT=DEBUG

DEBUG_VARS=	staf_build_type=debug
DEBUG_VARS_OFF=	staf_build_type=retail

OPENSSL_VARS=	staf_use_ssl=1

do-install:
	cd ${WRKDIR}/rel/freebsd/${PORTNAME}/${STAF_BUILD_TYPE} && \
		./STAFInst -noreg -acceptlicense -target ${STAGEDIR}${PREFIX}/staf
	cd ${STAGEDIR}${PREFIX}/staf && \
		${RM} STAFUninst STAFEnv.sh startSTAFProc.sh LICENSE.htm

.include <bsd.port.mk>
