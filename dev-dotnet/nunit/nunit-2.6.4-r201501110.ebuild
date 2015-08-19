# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5
inherit mono-env nuget dotnet

NAME="nunitv2"
HOMEPAGE="https://github.com/nunit/${NAME}"

EGIT_COMMIT="1b549f4f8b067518c7b54a5b263679adb83ccda4"
SRC_URI="${HOMEPAGE}/archive/${EGIT_COMMIT}.zip -> ${PF}.zip"
S="${WORKDIR}/${NAME}-${EGIT_COMMIT}"

SLOT="2" # NUnit V2 IS NO LONGER MAINTAINED OR UPDATED.

DESCRIPTION="NUnit test suite for mono applications"
LICENSE="BSD" # actually not, it is NUnit license - http://nunit.org/nuget/license.html
KEYWORDS="~amd64 ~ppc ~x86"
#USE_DOTNET="net20 net40 net45"
USE_DOTNET="net45"
IUSE="developer nupkg debug doc net45"
USE="${USE} net45" # force FRAMEWORK=4.5

RDEPEND=">=dev-lang/mono-4.0.2.5
	dev-dotnet/nant[nupkg]
"
DEPEND="${RDEPEND}
"

S="${WORKDIR}/${NAME}-${EGIT_COMMIT}"
FILE_TO_BUILD=nunit.sln
METAFILETOBUILD="${S}/${FILE_TO_BUILD}"

src_prepare() {
	chmod -R +rw "${S}" || die
	enuget_restore "${METAFILETOBUILD}"
}

src_compile() {
	exbuild "${METAFILETOBUILD}"
	enuspec "${FILESDIR}/${PN}-${PV}.nuspec"
	# PN = Package name, for example vim.
	# PV = Package version (excluding revision, if any), for example 6.3.
}

src_install() {
	DIR=""
	if use debug; then
		DIR="Debug"
	else
		DIR="Release"
	fi

	SLOTTEDDIR="/usr/share/nunit-${SLOT}/"
	insinto "${SLOTTEDDIR}"
	doins bin/${DIR}/*.{config,dll,exe}
	# install: cannot stat 'bin/Release/*.mdb': No such file or directory
	if use developer; then
		doins bin/${DIR}/*.mdb
	fi

#	into /usr
#	dobin ${FILESDIR}/nunit-console
	make_wrapper nunit264 "mono ${SLOTTEDDIR}/nunit-console.exe"

	if use doc; then
#		dodoc ${WORKDIR}/doc/*.txt
#		dohtml ${WORKDIR}/doc/*.html
#		insinto /usr/share/${P}/samples
#		doins -r ${WORKDIR}/samples/*
		doins license.txt
	fi

	enupkg "${WORKDIR}/NUnit.${PV}.nupkg"
}
