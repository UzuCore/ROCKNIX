PKG_NAME="gcc-linaro-aarch64-elf"
PKG_VERSION="4.9.4-2017.01"
PKG_SHA256="00c79aaf7ff9b1c22f7b0443a730056b3936561a4206af187ef61a4e3cab1716"
PKG_LICENSE="GPL"
PKG_SITE="https://sources.libreelec.tv/mirror/gcc-linaro-aarch64-elf/"
PKG_URL="https://sources.libreelec.tv/mirror/gcc-linaro-aarch64-elf/gcc-linaro-aarch64-elf-${PKG_VERSION}.tar.xz"
PKG_DEPENDS_HOST="ccache:host"
PKG_LONGDESC="Linaro Aarch64 GNU Linux Binary Toolchain"
PKG_TOOLCHAIN="manual"

makeinstall_host() {
  mkdir -p $TOOLCHAIN/lib/gcc-linaro-aarch64-elf/
    cp -a * $TOOLCHAIN/lib/gcc-linaro-aarch64-elf
}
