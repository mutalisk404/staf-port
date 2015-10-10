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
USES=		gmake
USE_LDCONFIG=	yes
USE_RC_SUBR=	stafproc
SUB_LIST=	STAF_VAR_DIR=${STAF_VAR_DIR}

STAF_BIN_FILES=	STAF STAFProc STAFReg STAFLoop STAFExecProxy FmtLog
STAF_LIB_FILES=	libHello.so libSTAF.so libSTAFDSLS.so libSTAFDeviceService.so \
		libSTAFEXECPROXY.so libSTAFLIPC.so libSTAFLog.so \
		libSTAFMon.so libSTAFPool.so libSTAFReg.so libSTAFTCP.so
STAF_PYLIB_FILES=	PySTAF.py PySTAFLog.py PySTAFMon.py PySTAFv3.py
STAF_SSL_FILES=	CAList.crt STAFDefault.crt STAFDefault.key
STAF_VAR_DIR?=	/var/db/STAF

OPTIONS_DEFINE=	DEBUG IPV6 OPENSSL PYTHON
OPTIONS_DEFAULT=IPV6 OPENSSL
OPTIONS_SUB=	yes

DEBUG_VARS=	staf_build_type=debug
DEBUG_VARS_OFF=	staf_build_type=retail

IPV6_VARS=	staf_use_ipv6=1

OPENSSL_VARS=	staf_use_ssl=1 use_openssl=yes
OPENSSL_MAKE_ARGS=	OPENSSL_ROOT=${OPENSSLBASE} \
			OPENSSL_LIBDIRS="${OPENSSLLIB}" \
			OPENSSL_INCLUDEDIRS=${OPENSSLINC}

PYTHON_USES=	python:-3.4
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
		${WRKSRC}/stafif/STAFConverter.cpp \
		${WRKSRC}/connproviders/tcp/STAFTCPConnProvider.cpp
	${REINPLACE_CMD} "s|%%PREFIX%%|${PREFIX}|g" \
		${WRKSRC}/stafproc/STAFProc.cpp
	${REINPLACE_CMD} "s|%%STAFVARDIR%%|${STAF_VAR_DIR}|g" \
		${WRKSRC}/stafproc/STAFProc.cpp

do-install:
.for bin in ${STAF_BIN_FILES}
	${INSTALL_PROGRAM} ${STAF_REL_DIR}/bin/${bin} ${STAGEDIR}${PREFIX}/bin/
.endfor
	${LN} -s ${PREFIX}/bin/STAF ${STAGEDIR}${PREFIX}/bin/staf
.for lib in ${STAF_LIB_FILES}
	${INSTALL_LIB} ${STAF_REL_DIR}/lib/${lib} ${STAGEDIR}${PREFIX}/lib/
.endfor
	${INSTALL_DATA} ${STAF_REL_DIR}/bin/STAF.cfg \
		${STAGEDIR}${PREFIX}/etc/STAF.cfg.sample
	cd ${STAF_REL_DIR}/include && \
		${COPYTREE_SHARE} . ${STAGEDIR}${PREFIX}/include
	${MKDIR} ${STAGEDIR}${DATADIR}/codepage
	cd ${STAF_REL_DIR}/codepage && \
		${COPYTREE_SHARE} . ${STAGEDIR}${DATADIR}/codepage
	${MKDIR} ${STAGEDIR}${EXAMPLESDIR}
	cd ${STAF_REL_DIR}/samples && \
		${COPYTREE_SHARE} . ${STAGEDIR}${EXAMPLESDIR}

do-install-OPENSSL-on:
	${MKDIR} ${STAGEDIR}${DATADIR}
.for sslfile in ${STAF_SSL_FILES}
	${INSTALL_DATA} ${STAF_REL_DIR}/bin/${sslfile} ${STAGEDIR}${DATADIR}
.endfor

do-install-PYTHON-on:
	${MKDIR} ${STAGEDIR}${PYTHON_SITELIBDIR}/${PORTNAME}
.for lib in ${STAF_PYLIB_FILES}
	${INSTALL_DATA} ${STAF_REL_DIR}/lib/${lib} ${STAGEDIR}${PYTHON_SITELIBDIR}/${PORTNAME}
.endfor
	${PYTHON_CMD} -m compileall -d ${PYTHON_SITELIBDIR}/${PORTNAME} \
		${STAGEDIR}${PYTHON_SITELIBDIR}/${PORTNAME}
	${PYTHON_CMD} -O -m compileall -d ${PYTHON_SITELIBDIR}/${PORTNAME} \
		${STAGEDIR}${PYTHON_SITELIBDIR}/${PORTNAME}
	${INSTALL_LIB} ${STAF_REL_DIR}/lib/python${PYTHON_SUFFIX}/PYSTAF.so \
		${STAGEDIR}${PYTHON_SITELIBDIR}/${PORTNAME}
	${ECHO} ${PORTNAME} > ${STAGEDIR}${PYTHON_SITELIBDIR}/${PORTNAME}.pth
	${MKDIR} ${STAGEDIR}${DOCSDIR}
	cd ${STAF_REL_DIR}/docs && \
		${COPYTREE_SHARE} . ${STAGEDIR}${DOCSDIR}

.include <bsd.port.mk>
