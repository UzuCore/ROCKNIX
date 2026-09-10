# SPDX-License-Identifier: GPL-2.0-only
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

. ${ROOT}/packages/multimedia/gstreamer/gstreamer/package.mk

pre_configure_target() {
  PKG_MESON_OPTS_TARGET="-Dgst_debug=true \
                         -Dgst_parse=true \
                         -Dregistry=true \
                         -Dtracer_hooks=false \
                         -Doption-parsing=true \
                         -Dpoisoning=false \
                         -Dcheck=disabled \
                         -Dlibunwind=disabled \
                         -Dlibdw=disabled \
                         -Ddbghelp=disabled \
                         -Dbash-completion=disabled \
                         -Dcoretracers=disabled \
                         -Dexamples=disabled \
                         -Dtests=disabled \
                         -Dbenchmarks=disabled \
                         -Dtools=enabled \
                         -Ddoc=disabled \
                         -Dintrospection=disabled \
                         -Dnls=disabled \
                         -Dglib_debug=disabled \
                         -Dglib_assert=false \
                         -Dglib_checks=false \
                         -Dextra-checks=disabled \
                         -Dpackage-name="gstreamer"
                         -Dpackage-origin="LibreELEC.tv"
                         -Ddoc=disabled"
}
