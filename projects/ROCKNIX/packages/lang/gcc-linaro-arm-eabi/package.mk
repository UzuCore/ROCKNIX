PKG_NAME="gcc-linaro-arm-eabi"
PKG_VERSION="4.9.4-2017.01"
PKG_LICENSE="GPL"
PKG_SITE="https://sources.libreelec.tv/mirror/gcc-linaro-arm-eabi"
PKG_URL="${PKG_SITE}/gcc-linaro-arm-eabi-${PKG_VERSION}.tar.xz"
PKG_SHA256="5fa170a74db172dca098c70ae58f4c08d2fca0232ce135530b2ef4996326b4bd"
PKG_DEPENDS_HOST="ccache:host"
PKG_LONGDESC="Linaro ARM GNU Linux Binary Toolchain"
PKG_TOOLCHAIN="manual"

makeinstall_host() {
  mkdir -p $TOOLCHAIN/lib/gcc-linaro-arm-eabi/
    cp -a * $TOOLCHAIN/lib/gcc-linaro-arm-eabi
}
