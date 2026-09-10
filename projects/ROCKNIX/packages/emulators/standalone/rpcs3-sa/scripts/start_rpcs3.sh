#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2022-present JELOS (https://github.com/JustEnoughLinuxOS)

. /etc/profile

# Check if rpcs3 exists in .config
if [ ! -d "/storage/.config/rpcs3" ]; then
  cp -r "/usr/config/rpcs3" "/storage/.config/"
fi

# Link certain RPCS3 folders to a location in /storage/roms/bios
FOLDER_LINKS=("dev_flash" "dev_hdd0" "dev_hdd1" "custom_configs")
for FOLDER_LINK in "${FOLDER_LINKS[@]}"; do
  TARGET_FOLDER="/storage/roms/bios/rpcs3/$FOLDER_LINK"
  SOURCE_FOLDER="/storage/.config/rpcs3/$FOLDER_LINK"

  # Create the target folder if it doesn't exist
  if [ ! -d "$TARGET_FOLDER" ]; then
      mkdir -p "$TARGET_FOLDER"
  fi

  # Remove existing source folder
  rm -rf "$SOURCE_FOLDER"

  # Create symbolic link
  ln -sf "$TARGET_FOLDER" "$SOURCE_FOLDER"
done

#Emulation Station Features
GAME=$(echo "${1}"| sed "s#^/.*/##")
PLATFORM=$(echo "${2}"| sed "s#^/.*/##")
ASPECT=$(get_setting aspect_ratio "${PLATFORM}" "${GAME}")
ATEXTURE=$(get_setting async_texture_streaming "${PLATFORM}" "${GAME}")
FLIMIT=$(get_setting frame_limit "${PLATFORM}" "${GAME}")
GRENDERER=$(get_setting graphics_backend "${PLATFORM}" "${GAME}")
IPS3RES=$(get_setting internal_ps3_resolution "${PLATFORM}" "${GAME}")
IRES_SCALE=$(get_setting internal_resolution_scale "${PLATFORM}" "${GAME}")
MULTIRSX=$(get_setting multithreaded_rsx "${PLATFORM}" "${GAME}")
PERFOVERLAY=$(get_setting performance_overlay "${PLATFORM}" "${GAME}")
SPREC=$(get_setting shader_precision "${PLATFORM}" "${GAME}")
SPUXFLOAT=$(get_setting spu_xfloat_accuracy "${PLATFORM}" "${GAME}")
VSYNC=$(get_setting vsync "${PLATFORM}" "${GAME}")
WCOLORB=$(get_setting write_color_buffers "${PLATFORM}" "${GAME}")
ZCULLA=$(get_setting zcull_accuracy "${PLATFORM}" "${GAME}")
SUI=$(get_setting start_ui "${PLATFORM}" "${GAME}")
CONFIG_YML="/storage/.config/rpcs3/config.yml"

# Aspect Ratio. Leave RPCS3's current value untouched when ES has no override.
case "${ASPECT}" in
  4x3)
    sed -i "s#Aspect ratio:.*\$#Aspect ratio: 4:3#g" "${CONFIG_YML}"
    ;;
  16x9)
    sed -i "s#Aspect ratio:.*\$#Aspect ratio: 16:9#g" "${CONFIG_YML}"
    ;;
esac

# Asynchronous Texture Streaming
case "${ATEXTURE}" in
  true)
    sed -i "s#Asynchronous Texture Streaming 2:.*\$#Asynchronous Texture Streaming 2: true#g" "${CONFIG_YML}"
    ;;
  false)
    sed -i "s#Asynchronous Texture Streaming 2:.*\$#Asynchronous Texture Streaming 2: false#g" "${CONFIG_YML}"
    ;;
esac

# Graphics Backend
case "${GRENDERER}" in
  vulkan)
    sed -i '/Video:/ {n; s/Renderer: .*/Renderer: Vulkan/}' "${CONFIG_YML}"
    ;;
  opengl)
    sed -i '/Video:/ {n; s/Renderer: .*/Renderer: OpenGL/}' "${CONFIG_YML}"
    ;;
esac

# Frame Limit
case "${FLIMIT}" in
  30|60)
    sed -i "s#Frame limit:.*\$#Frame limit: ${FLIMIT}#g" "${CONFIG_YML}"
    ;;
  auto)
    sed -i "s#Frame limit:.*\$#Frame limit: Auto#g" "${CONFIG_YML}"
    ;;
esac

# Internal Resolution
case "${IPS3RES}" in
  480)
    sed -i "s#Resolution:.*\$#Resolution: 720x480#g" "${CONFIG_YML}"
    ;;
  576)
    sed -i "s#Resolution:.*\$#Resolution: 720x576#g" "${CONFIG_YML}"
    ;;
  720)
    sed -i "s#Resolution:.*\$#Resolution: 1280x720#g" "${CONFIG_YML}"
    ;;
  1080)
    sed -i "s#Resolution:.*\$#Resolution: 1920x1080#g" "${CONFIG_YML}"
    ;;
  native)
    sed -i "s#Resolution:.*\$#Resolution: $(fbwidth)x$(fbheight)#g" "${CONFIG_YML}"
    ;;
esac

# Internal Resolution Scale
case "${IRES_SCALE}" in
  25|50|75|100)
    sed -i "s#Resolution Scale:.*\$#Resolution Scale: ${IRES_SCALE}#g" "${CONFIG_YML}"
    ;;
esac

# Multithreaded RSX
case "${MULTIRSX}" in
  true|false)
    sed -i "s#Multithreaded RSX:.*\$#Multithreaded RSX: ${MULTIRSX}#g" "${CONFIG_YML}"
    ;;
esac

# Shader Precision
case "${SPREC}" in
  low)
    sed -i "s#Shader Precision:.*\$#Shader Precision: Low#g" "${CONFIG_YML}"
    ;;
  high)
    sed -i "s#Shader Precision:.*\$#Shader Precision: High#g" "${CONFIG_YML}"
    ;;
  ultra)
    sed -i "s#Shader Precision:.*\$#Shader Precision: Ultra#g" "${CONFIG_YML}"
    ;;
esac

# SPU XFloat Accuracy
case "${SPUXFLOAT}" in
  approximate)
    sed -i "s#XFloat Accuracy:.*\$#XFloat Accuracy: Approximate#g" "${CONFIG_YML}"
    ;;
  accurate)
    sed -i "s#XFloat Accuracy:.*\$#XFloat Accuracy: Accurate#g" "${CONFIG_YML}"
    ;;
  relaxed)
    sed -i "s#XFloat Accuracy:.*\$#XFloat Accuracy: Relaxed#g" "${CONFIG_YML}"
    ;;
esac

# Write Color Buffers
case "${WCOLORB}" in
  true|false)
    sed -i "s#Write Color Buffers:.*\$#Write Color Buffers: ${WCOLORB}#g" "${CONFIG_YML}"
    ;;
esac

# VSync
case "${VSYNC}" in
  true|false)
    sed -i "s#VSync:.*\$#VSync: ${VSYNC}#g" "${CONFIG_YML}"
    ;;
esac

# ZCULL Accuracy
case "${ZCULLA}" in
  precise)
    sed -i "s#Relaxed ZCULL Sync:.*\$#Relaxed ZCULL Sync: false#g" "${CONFIG_YML}"
    sed -i "s#Accurate ZCULL stats:.*\$#Accurate ZCULL stats: true#g" "${CONFIG_YML}"
    ;;
  approximate)
    sed -i "s#Relaxed ZCULL Sync:.*\$#Relaxed ZCULL Sync: false#g" "${CONFIG_YML}"
    sed -i "s#Accurate ZCULL stats:.*\$#Accurate ZCULL stats: false#g" "${CONFIG_YML}"
    ;;
  relaxed)
    sed -i "s#Relaxed ZCULL Sync:.*\$#Relaxed ZCULL Sync: true#g" "${CONFIG_YML}"
    sed -i "s#Accurate ZCULL stats:.*\$#Accurate ZCULL stats: false#g" "${CONFIG_YML}"
    ;;
esac

# Performance Overlay
case "${PERFOVERLAY}" in
  true|false)
    sed -i "/Performance Overlay:/ {n; s/Enabled: .*/Enabled: ${PERFOVERLAY}/}" "${CONFIG_YML}"
    ;;
esac

#Set the cores to use
CORES=$(get_setting "cores" "${PLATFORM}" "${GAME}")
if [ "${CORES}" = "little" ]
then
  EMUPERF="${SLOW_CORES}"
elif [ "${CORES}" = "big" ]
then
  EMUPERF="${FAST_CORES}"
else
  ### All..
  unset EMUPERF
fi

#Check if its a PSN game
GAME_PATH=""
PSNID=""
if [[ "${1}" == *.psn ]]; then
  # Hardcoded now for testing
  read -r PSNID < "${1}"
  GAME_PATH="/storage/.config/rpcs3/dev_hdd0/game/${PSNID}/USRDIR/EBOOT.BIN"
elif [[ "${1}" == *.m3u ]]; then
  #check if path is M3U
  read -r M3UPATH < "${1}"
  echo ${M3UPATH}
  GAME_PATH="/roms/ps3/${M3UPATH}"
else
  GAME_PATH="${1}"
fi

#Log Settings
cat <<EOF >/var/log/rpcs3-sa.log
GAME: ${GAME}
PLATFORM: ${PLATFORM}
ASPECT RATIO: ${ASPECT}
GPU BACKEND: ${GRENDERER}
INTERNAL RESOLUTION: ${IPS3RES}
INTERNAL RESOLUTION SCALE: ${IRES_SCALE}
MULTITHREADED RSX: ${MULTIRSX}
PERFORMANCE OVERLAY: ${PERFOVERLAY}
SHADER PRECISION: ${SPREC}
SPU XFLOAT ACCURACY: ${SPUXFLOAT}
WRITE COLOR BUFFERS: ${WCOLORB}
ZCULL ACCURACY: ${ZCULLA}
ASYNC TEXTURE STREAMING: ${ATEXTURE}
VSYNC: ${VSYNC}
SHOW UI: ${SUI}
CONFIG_YML: ${CONFIG_YML}
EOF

# Run rpcs3
if [ "$SUI" = "true" ]; then
  export QT_QPA_PLATFORM=wayland
  set_kill set "-9 rpcs3-sa"
  ${EMUPERF} /usr/bin/rpcs3-sa
else
  export QT_QPA_PLATFORM=xcb
  set_kill set "-9 rpcs3-sa"
  ${EMUPERF} /usr/bin/rpcs3-sa --no-gui "$GAME_PATH"
fi
