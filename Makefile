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
STAF_REL_DIR=	${WRKDIR}/rel/freebsd/staf/${STAF_BUILD_TYPE}

MAKEFILE=	makefile
MAKE_ARGS=	OS_NAME="freebsd" \
		CC_CC=${CXX} \
		CC_C=${CC} \
		STAF_USE_SSL=${STAF_USE_SSL} \
		STAF_USE_IPV6=${STAF_USE_IPV6} \
		BUILD_TYPE=${STAF_BUILD_TYPE} \
		PROJECTS="${STAF_PROJECTS}"

STAF_PROJECTS=	staf connprov_tcp connprov_localipc

MAKE_JOBS_UNSAFE=	yes
USES=		gmake:lite
LD_CONFIG=	yes

OPTIONS_DEFINE=	DEBUG IPV6 OPENSSL PYTHON
OPTIONS_DEFAULT=DEBUG

DEBUG_VARS=	staf_build_type=debug
DEBUG_VARS_OFF=	staf_build_type=retail

IPV6_VARS=	staf_use_ipv6=1

OPENSSL_VARS=	staf_use_ssl=1

PYTHON_USES=	python
PYTHON_VARS=	staf_projects+=python
PYTHON_MAKE_ARGS=	PYTHON_V${PYTHON_SUFFIX}_ROOT=${LOCALBASE} \
			PYTHON_BUILD_V${PYTHON_SUFFIX}=1
.for i in 22 23 24 25 26 30 31 32 33 34
.if i != PYTHON_SUFFIX
PYTHON_MAKE_ARGS+=	PYTHON_BUILD_V${i}=0
.endif
.endfor

post-patch:
	${REINPLACE_CMD} "s|%%DATADIR%%|${DATADIR}|" \
		${WRKSRC}/stafif/STAFConverter.cpp
	${REINPLACE_CMD} "s|%%PREFIX%%|${PREFIX}|g" \
		${WRKSRC}/stafproc/STAFProc.cpp

do-install:
	cd ${STAF_REL_DIR}/include && ${COPYTREE_SHARE} . ${STAGEDIR}${PREFIX}/include

.include <bsd.port.mk>
