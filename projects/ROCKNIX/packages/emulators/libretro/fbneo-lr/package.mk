# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2019-present Shanti Gilbert (https://github.com/shantigilbert)
# Maintenance 2020 351ELEC team (https://github.com/fewtarius/351ELEC)
# Copyright (C) 2023 JELOS (https://github.com/JustEnoughLinuxOS)

PKG_NAME="fbneo-lr"
PKG_VERSION="fd3e1b9c0983eab2c499044592b47d5da1c4b41a" # DsNo (260831)
PKG_SHA256="36b38fafdb2e343394a4895f53c62dabd2375872749127cbacb79992f98febb9"
PKG_LICENSE="Non-commercial"
PKG_SITE="https://github.com/aleksei74/FBNeo"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="Port of Final Burn Neo to Libretro (v0.2.97.38)."
PKG_TOOLCHAIN="make"

pre_configure_target() {
sed -i "s|LDFLAGS += -static-libgcc -static-libstdc++|LDFLAGS += -static-libgcc|" "${PKG_BUILD}/src/burner/libretro/Makefile"

PKG_MAKE_OPTS_TARGET=" -C ${PKG_BUILD}/src/burner/libretro USE_CYCLONE=0 profile=performance GIT_VERSION=${PKG_VERSION:0:10}"

if [[ "${TARGET_FPU}" =~ "neon" ]]; then
	PKG_MAKE_OPTS_TARGET+=" HAVE_NEON=1"
fi

}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
  cp ${PKG_BUILD}/src/burner/libretro/fbneo_libretro.so ${INSTALL}/usr/lib/libretro/
}
