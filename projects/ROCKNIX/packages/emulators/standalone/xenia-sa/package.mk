# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="xenia-sa"
PKG_VERSION="d7a868837c9863feaeb8a1a6f8fe198d036bab41"
PKG_LICENSE="BSD-3-Clause"
PKG_SITE="https://github.com/has207/xenia-edge"
PKG_URL="${PKG_SITE}.git"
PKG_GIT_CLONE_BRANCH="edge"
PKG_GIT_SUBMODULE_DEPTH="1"
# Linux/AArch64 dependencies only. Excludes Windows DirectX, x64 JIT, tests,
# lint tooling and the unused portal backend.
PKG_GIT_SUBMODULES="third_party/FFmpeg third_party/FidelityFX-CAS third_party/FidelityFX-FSR \
                    third_party/SDL3 third_party/SPIRV-Headers third_party/SPIRV-Tools \
                    third_party/VulkanMemoryAllocator third_party/aes_128 \
                    third_party/asio third_party/boost_context/context \
                    third_party/capstone third_party/cxxopts third_party/date \
                    third_party/discord-rpc third_party/disruptorplus third_party/fmt \
                    third_party/glslang third_party/imgui third_party/miniaudio \
                    third_party/pugixml third_party/rapidjson third_party/snappy \
                    third_party/tomlplusplus third_party/utfcpp third_party/wxWidgets \
                    third_party/xbyak_aarch64 third_party/xxhash third_party/zarchive \
                    third_party/zlib-ng third_party/zstd"
PKG_LONGDESC="Xenia Edge - Xbox 360 emulator (experimental AArch64 build)."
PKG_DEPENDS_TARGET="toolchain llvm:host Python3:host glslang:host spirv-tools spirv-tools:host \
                    vulkan-loader vulkan-headers gtk3 SDL2 alsa-lib lz4 xwayland"
PKG_TOOLCHAIN="manual"

make_target() {
  local LLVM_BIN="${TOOLCHAIN}/bin"
  local BUILD_DIR="${PKG_BUILD}/.${TARGET_NAME}"
  local CPU_FLAGS=""
  local OPT_FLAGS="-O3 -fPIC"
  local TARGET_FLAGS="--target=aarch64-rocknix-linux-gnu --sysroot=${SYSROOT_PREFIX}"
  local FLAGS_CLEAN="s/-mabi=lp64//g; s/-mcpu=[^ ]*//g; s/-march=[^ ]*//g; s/-mtune=[^ ]*//g"

  case "${DEVICE}" in
    SM8250)
      CPU_FLAGS="-march=armv8.2-a+crc+crypto -mtune=cortex-a77"
      ;;
    SM8550)
      CPU_FLAGS="-march=armv9-a${TARGET_CPU_FLAGS} -mtune=cortex-x3"
      ;;
    SM8650)
      CPU_FLAGS="-march=armv9.2-a${TARGET_CPU_FLAGS} -mtune=cortex-x4"
      ;;
    SM8750)
      CPU_FLAGS="-march=armv9.2-a${TARGET_CPU_FLAGS} -mtune=oryon-1"
      ;;
    *)
      CPU_FLAGS="-march=armv8-a -mtune=generic"
      ;;
  esac

  mkdir -p "${BUILD_DIR}"
  (cd "${PKG_BUILD}" && git submodule update --init --recursive third_party/wxWidgets) || return 1
  python3 -c "import runpy; runpy.run_path('${PKG_BUILD}/xenia-build.py')['generate_version_h']('${BUILD_DIR}')" || return 1
  (cd "${PKG_BUILD}" && python3 xenia-build.py slang) || return 1

  # Compile host xenia-shader-cc tool natively for x86_64 build host
  (cd "${PKG_BUILD}" && rm -rf build-host && CFLAGS="" CXXFLAGS="" ASMFLAGS="" LDFLAGS="" PATH="/usr/bin:${PATH}" cmake -S . -B build-host -DBUILD_HOST_TOOLS_ONLY=ON -DXENIA_ENABLE_LTO=OFF -DCMAKE_BUILD_TYPE=Release -DCMAKE_C_COMPILER=/usr/bin/gcc -DCMAKE_CXX_COMPILER=/usr/bin/g++ && PATH="/usr/bin:${PATH}" cmake --build build-host --target xenia-shader-cc -j$(nproc)) || return 1

  for _v in CFLAGS CXXFLAGS ASMFLAGS; do
    export ${_v}="$(echo ${!_v} | sed -e "${FLAGS_CLEAN}") ${TARGET_FLAGS} ${OPT_FLAGS} ${CPU_FLAGS}"
  done

  export AR="${LLVM_BIN}/llvm-ar"
  export RANLIB="${LLVM_BIN}/llvm-ranlib"
  export NM="${LLVM_BIN}/llvm-nm"
  export CC="${LLVM_BIN}/clang"
  export CXX="${LLVM_BIN}/clang++"
  export LD="${LLVM_BIN}/ld.lld"

  # Shader generation must use host executables during an AArch64 cross build.
  export PATH="${TOOLCHAIN}/bin:${PATH}"
  unset VULKAN_SDK

  cmake -G Ninja \
    -S "${PKG_BUILD}" \
    -B "${BUILD_DIR}" \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_SYSTEM_NAME=Linux \
    -DCMAKE_SYSTEM_PROCESSOR=aarch64 \
    -DCMAKE_SYSROOT="${SYSROOT_PREFIX}" \
    -DCMAKE_FIND_ROOT_PATH="${SYSROOT_PREFIX}" \
    -DCMAKE_FIND_ROOT_PATH_MODE_PROGRAM=NEVER \
    -DCMAKE_FIND_ROOT_PATH_MODE_INCLUDE=ONLY \
    -DCMAKE_FIND_ROOT_PATH_MODE_LIBRARY=ONLY \
    -DCMAKE_FIND_ROOT_PATH_MODE_PACKAGE=ONLY \
    -DCMAKE_C_COMPILER="${LLVM_BIN}/clang" \
    -DCMAKE_C_COMPILER_TARGET=aarch64-rocknix-linux-gnu \
    -DCMAKE_CXX_COMPILER="${LLVM_BIN}/clang++" \
    -DCMAKE_CXX_COMPILER_TARGET=aarch64-rocknix-linux-gnu \
    -DCMAKE_ASM_COMPILER="${LLVM_BIN}/clang" \
    -DCMAKE_ASM_COMPILER_TARGET=aarch64-rocknix-linux-gnu \
    -DCMAKE_C_FLAGS="${TARGET_FLAGS} ${CPU_FLAGS} ${OPT_FLAGS}" \
    -DCMAKE_CXX_FLAGS="${TARGET_FLAGS} ${CPU_FLAGS} ${OPT_FLAGS}" \
    -DCMAKE_ASM_FLAGS="${TARGET_FLAGS} ${CPU_FLAGS} ${OPT_FLAGS}" \
    -DCMAKE_LINKER="${LLVM_BIN}/ld.lld" \
    -DCMAKE_EXE_LINKER_FLAGS="-fuse-ld=lld" \
    -DCMAKE_AR="${LLVM_BIN}/llvm-ar" \
    -DCMAKE_RANLIB="${LLVM_BIN}/llvm-ranlib" \
    -DCMAKE_NM="${LLVM_BIN}/llvm-nm" \
    -DPython3_EXECUTABLE="${TOOLCHAIN}/bin/python3" \
    -DXENIA_BUILD_TESTS=OFF \
    -DXENIA_BUILD_MISC=OFF || return 1

  ninja -C "${BUILD_DIR}" xenia-app -j$(nproc) || ninja -C "${BUILD_DIR}" xenia-app
}

makeinstall_target() {
  local XENIA_BIN="${PKG_BUILD}/.${TARGET_NAME}/bin/Linux/xenia_edge"

  if [ ! -x "${XENIA_BIN}" ]; then
    echo "Missing Xenia executable: ${XENIA_BIN}" >&2
    return 1
  fi

  mkdir -p "${INSTALL}/usr/bin"
  cp -v "${XENIA_BIN}" "${INSTALL}/usr/bin/xenia_edge"
  cp -v "${PKG_DIR}/scripts/start_xenia.sh" "${INSTALL}/usr/bin/"
  mkdir -p "${INSTALL}/usr/config/xenia"
  cp -v "${PKG_DIR}/config/xenia-edge.config.toml" "${INSTALL}/usr/config/xenia/"
  if [ -d "${PKG_DIR}/config/content" ]; then
    cp -a "${PKG_DIR}/config/content" "${INSTALL}/usr/config/xenia/"
  fi
  chmod 0755 "${INSTALL}/usr/bin/xenia_edge" "${INSTALL}/usr/bin/start_xenia.sh"
}
