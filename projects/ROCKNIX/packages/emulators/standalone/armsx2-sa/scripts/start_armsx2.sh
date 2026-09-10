#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2022-present JELOS (https://github.com/JustEnoughLinuxOS)

. /etc/profile

#Check if ARMSX2 exists in .config
if [ ! -d "/storage/.config/ARMSX2" ]; then
    mkdir -p "/storage/.config/ARMSX2"
        cp -r "/usr/config/ARMSX2" "/storage/.config/"
fi

#Check if ARMSX2 ini exists in .config
if [ ! -f "/storage/.config/ARMSX2/inis/PCSX2.ini" ]; then
        cp -r "/usr/config/ARMSX2/inis/PCSX2.ini" "/storage/.config/ARMSX2/inis/"
fi

#Check if secrets ini exists in .config
if [ ! -f "/storage/.config/ARMSX2/inis/secrets.ini" ]; then
        cp -r "/usr/config/ARMSX2/inis/secrets.ini" "/storage/.config/ARMSX2/inis/"
fi

#Make ARMSX2 bios folder
if [ ! -d "/storage/roms/bios/armsx2" ]; then
    mkdir -p "/storage/roms/bios/armsx2"
fi
sed -i '/^Bios =/c\Bios = /storage/roms/bios/armsx2' /storage/.config/ARMSX2/inis/PCSX2.ini

#Create PS2 savestates folder
if [ ! -d "/storage/roms/savestates/ps2" ]; then
    mkdir -p "/storage/roms/savestates/ps2"
fi

#Emulation Station Features
GAME=$(echo "${1}"| sed "s#^/.*/##")
PLATFORM=$(echo "${2}"| sed "s#^/.*/##")
ASPECT=$(get_setting aspect_ratio "${PLATFORM}" "${GAME}")
FILTER=$(get_setting bilinear_filtering "${PLATFORM}" "${GAME}")
FPS=$(get_setting show_fps "${PLATFORM}" "${GAME}")
RATE=$(get_setting ee_cycle_rate "${PLATFORM}" "${GAME}")
SKIP=$(get_setting ee_cycle_skip "${PLATFORM}" "${GAME}")
HWDOWNLOAD=$(get_setting hw_download_mode "${PLATFORM}" "${GAME}")
GRENDERER=$(get_setting graphics_backend "${PLATFORM}" "${GAME}")
IRES=$(get_setting internal_resolution "${PLATFORM}" "${GAME}")
VSYNC=$(get_setting vsync "${PLATFORM}" "${GAME}")
ENABLE_WIDESCREEN_PATCHES=$(get_setting enable_widescreen_patches "${PLATFORM}" "${GAME}")
LSFG_ENABLE=$(get_setting lsfg_enable "${PLATFORM}" "${GAME}")
LSFG_ENABLE=${LSFG_ENABLE:-0}
LSFG_MULTIPLIER=$(get_setting lsfg_multiplier "${PLATFORM}" "${GAME}")
LSFG_MULTIPLIER=${LSFG_MULTIPLIER:-2}
LSFG_FLOW_SCALE=$(get_setting lsfg_flow_scale "${PLATFORM}" "${GAME}")
LSFG_FLOW_SCALE=${LSFG_FLOW_SCALE:-0.30}
# The old external lsfg-vk layer used a 0.00..1.00 fraction. Native ARMSX2
# 2.6.6.8 stores the same choice as a 25..100 percentage. Accept both forms
# so existing EmulationStation settings continue to work after the migration.
case "${LSFG_FLOW_SCALE}" in
  auto)
    LSFG_FLOW_SCALE=100
    ;;
  *.*)
    LSFG_FLOW_SCALE=$(awk -v scale="${LSFG_FLOW_SCALE}" 'BEGIN { printf "%d", (scale * 100) + 0.5 }')
    ;;
esac
case "${LSFG_FLOW_SCALE}" in
  ''|*[!0-9]*)
    LSFG_FLOW_SCALE=100
    ;;
esac
if [ "${LSFG_FLOW_SCALE}" -lt 25 ]; then
  LSFG_FLOW_SCALE=25
elif [ "${LSFG_FLOW_SCALE}" -gt 100 ]; then
  LSFG_FLOW_SCALE=100
fi
LSFG_PERFORMANCE_MODE=$(get_setting lsfg_performance_mode "${PLATFORM}" "${GAME}")
LSFG_PERFORMANCE_MODE=${LSFG_PERFORMANCE_MODE:-1}
LSFG_TARGET_RATE=$(get_setting lsfg_target_rate "${PLATFORM}" "${GAME}")
LSFG_TARGET_RATE=${LSFG_TARGET_RATE:-auto}

#Set the cores to use
CORES=$(get_setting "cores" "${PLATFORM}" "${GAME}")
if [ "${CORES}" = "little" ]
then
  EMUPERF="${SLOW_CORES}"
elif [ "${CORES}" = "big" ]
then
  EMUPERF="${FAST_CORES}"
else
  #All..
  unset EMUPERF
fi

  #Aspect Ratio
	if [ "$ASPECT" = "0" ]
	then
  		sed -i '/^AspectRatio =/c\AspectRatio = 4:3' /storage/.config/ARMSX2/inis/PCSX2.ini
	fi
	if [ "$ASPECT" = "1" ]
	then
  		sed -i '/^AspectRatio =/c\AspectRatio = 16:9' /storage/.config/ARMSX2/inis/PCSX2.ini
	fi
	if [ "$ASPECT" = "2" ]
	then
  		sed -i '/^AspectRatio =/c\AspectRatio = Stretch' /storage/.config/ARMSX2/inis/PCSX2.ini
	fi

  #Bilinear Filtering
        if [ "$FILTER" = "0" ]
        then
                sed -i '/^filter =/c\filter = 0' /storage/.config/ARMSX2/inis/PCSX2.ini
        fi
        if [ "$FILTER" = "1" ]
        then
                sed -i '/^filter =/c\filter = 1' /storage/.config/ARMSX2/inis/PCSX2.ini
        fi
        if [ "$FILTER" = "2" ]
        then
                sed -i '/^filter =/c\filter = 2' /storage/.config/ARMSX2/inis/PCSX2.ini
        fi
        if [ "$FILTER" = "3" ]
        then
                sed -i '/^filter =/c\filter = 3' /storage/.config/ARMSX2/inis/PCSX2.ini
        fi

  #Graphics Backend
	if [ "$GRENDERER" = "0" ]
	then
  		sed -i '/^Renderer =/c\Renderer = -1' /storage/.config/ARMSX2/inis/PCSX2.ini
	fi
	if [ "$GRENDERER" = "1" ]
	then
  		sed -i '/^Renderer =/c\Renderer = 12' /storage/.config/ARMSX2/inis/PCSX2.ini
	fi
	if [ "$GRENDERER" = "2" ]
	then
  		sed -i '/^Renderer =/c\Renderer = 14' /storage/.config/ARMSX2/inis/PCSX2.ini
	fi
        if [ "$GRENDERER" = "3" ]
        then
                sed -i '/^Renderer =/c\Renderer = 13' /storage/.config/ARMSX2/inis/PCSX2.ini
        fi

  #Internal Resolution
        if [ "$IRES" > "0" ]
        then
                sed -i "/^upscale_multiplier =/c\upscale_multiplier = $IRES" /storage/.config/ARMSX2/inis/PCSX2.ini
        else
                sed -i '/^upscale_multiplier =/c\upscale_multiplier = 1' /storage/.config/ARMSX2/inis/PCSX2.ini
        fi

  #Show FPS
	if [ "$FPS" = "false" ]
	then
  		sed -i '/^OsdShowFPS =/c\OsdShowFPS = false' /storage/.config/ARMSX2/inis/PCSX2.ini
	fi
	if [ "$FPS" = "true" ]
	then
  		sed -i '/^OsdShowFPS =/c\OsdShowFPS = true' /storage/.config/ARMSX2/inis/PCSX2.ini
	fi

  #EE Cycle Rate
        sed -i '/^EECycleRate =/c\EECycleRate = 0' /storage/.config/ARMSX2/inis/PCSX2.ini
        if [ "$RATE" = "0" ]
        then
                sed -i '/^EECycleRate =/c\EECycleRate = -3' /storage/.config/ARMSX2/inis/PCSX2.ini
        fi
        if [ "$RATE" = "1" ]
        then
                sed -i '/^EECycleRate =/c\EECycleRate = -2' /storage/.config/ARMSX2/inis/PCSX2.ini
        fi
        if [ "$RATE" = "2" ]
        then
                sed -i '/^EECycleRate =/c\EECycleRate = -1' /storage/.config/ARMSX2/inis/PCSX2.ini
        fi
        if [ "$RATE" = "3" ]
        then
                sed -i '/^EECycleRate =/c\EECycleRate = 0' /storage/.config/ARMSX2/inis/PCSX2.ini
        fi
        if [ "$RATE" = "4" ]
        then
                sed -i '/^EECycleRate =/c\EECycleRate = 1' /storage/.config/ARMSX2/inis/PCSX2.ini
        fi
        if [ "$RATE" = "5" ]
        then
                sed -i '/^EECycleRate =/c\EECycleRate = 2' /storage/.config/ARMSX2/inis/PCSX2.ini
        fi
        if [ "$RATE" = "6" ]
        then
                sed -i '/^EECycleRate =/c\EECycleRate = 3' /storage/.config/ARMSX2/inis/PCSX2.ini
        fi

  #EE Cycle Skip
        sed -i '/^EECycleSkip =/c\EECycleSkip = 0' /storage/.config/ARMSX2/inis/PCSX2.ini
        if [ "$SKIP" = "0" ]
        then
                sed -i '/^EECycleSkip =/c\EECycleSkip = 0' /storage/.config/ARMSX2/inis/PCSX2.ini
        fi
        if [ "$SKIP" = "1" ]
        then
                sed -i '/^EECycleSkip =/c\EECycleSkip = 1' /storage/.config/ARMSX2/inis/PCSX2.ini
        fi
        if [ "$SKIP" = "2" ]
        then
                sed -i '/^EECycleSkip =/c\EECycleSkip = 2' /storage/.config/ARMSX2/inis/PCSX2.ini
        fi
        if [ "$SKIP" = "3" ]
        then
                sed -i '/^EECycleSkip =/c\EECycleSkip = 3' /storage/.config/ARMSX2/inis/PCSX2.ini
        fi

#HW download mode
        sed -i '/^HWDownloadMode =/c\HWDownloadMode = 0' /storage/.config/ARMSX2/inis/PCSX2.ini
        if [ "$HWDOWNLOAD" = "0" ]
        then
                sed -i '/^HWDownloadMode =/c\HWDownloadMode = 0' /storage/.config/ARMSX2/inis/PCSX2.ini
        fi
        if [ "$HWDOWNLOAD" = "1" ]
        then
                sed -i '/^HWDownloadMode =/c\HWDownloadMode = 1' /storage/.config/ARMSX2/inis/PCSX2.ini
        fi
        if [ "$HWDOWNLOAD" = "2" ]
        then
                sed -i '/^HWDownloadMode =/c\HWDownloadMode = 2' /storage/.config/ARMSX2/inis/PCSX2.ini
        fi
        if [ "$HWDOWNLOAD" = "3" ]
        then
                sed -i '/^HWDownloadMode =/c\HWDownloadMode = 3' /storage/.config/ARMSX2/inis/PCSX2.ini
        fi

#Widescreen patches
	if [ "$ENABLE_WIDESCREEN_PATCHES" = "true" ]
	then
  		sed -i '/^EnableWideScreenPatches =/c\EnableWideScreenPatches = true' /storage/.config/ARMSX2/inis/PCSX2.ini
        else
                sed -i '/^EnableWideScreenPatches =/c\EnableWideScreenPatches = false' /storage/.config/ARMSX2/inis/PCSX2.ini
        fi

#Retroachievements
  /usr/bin/cheevos_armsx2.sh

#Graphic driver fixes
@GRAPHICS@

#Lossless Scaling frame generation (native ARMSX2 Vulkan path)
  ARMSX2_INI="/storage/.config/ARMSX2/inis/PCSX2.ini"

  detect_refresh_rate() {
    local wlr_randr="/usr/bin/wlr-randr"
    local display_output
    local refresh_rate

    [ -x "${wlr_randr}" ] || return 1
    display_output=$(
      "${wlr_randr}" 2>/dev/null |
        awk '
          /^[^[:space:]]/ { output = $1; next }
          /^[[:space:]]+Enabled:[[:space:]]+yes/ && output != "" {
            print output
            found = 1
            exit
          }
          END {
            if (!found && output != "")
              print output
          }
        '
    )
    [ -n "${display_output}" ] || return 1
    refresh_rate=$(
      "${wlr_randr}" --output "${display_output}" 2>/dev/null |
        awk '/current/ {
          for (i = 1; i <= NF; i++) {
            if ($i == "Hz") {
              value = $(i - 1)
              gsub(/[^0-9.]/, "", value)
              if (value != "") {
                print value
                exit
              }
            }
          }
        }'
    )
    case "${refresh_rate}" in
      ''|*[!0-9.]*)
        return 1
        ;;
    esac
    refresh_rate=$(awk -v rate="${refresh_rate}" 'BEGIN { printf "%d", rate + 0.5 }')
    case "${refresh_rate}" in
      ''|*[!0-9]*) return 1 ;;
    esac
    printf '%s\n' "${refresh_rate}"
  }

  # Keep settings in the [EmuCore/GS] section. This also upgrades an existing
  # user configuration created by 2.6.6.7, which has no native LSFG keys yet.
  set_gs_setting() {
    local key="${1}"
    local value="${2}"
    local tmp="${ARMSX2_INI}.tmp.$$"

    awk -v key="${key}" -v value="${value}" '
      function add_missing() {
        if (!seen_value)
          print key " = " value
      }
      /^\[/ {
        if (in_gs)
          add_missing()
        in_gs = ($0 == "[EmuCore/GS]")
        if (in_gs) {
          seen_section = 1
          seen_value = 0
        }
      }
      in_gs && $0 ~ "^[[:space:]]*" key "[[:space:]]*=" {
        print key " = " value
        seen_value = 1
        next
      }
      { print }
      END {
        if (in_gs)
          add_missing()
        if (!seen_section) {
          print ""
          print "[EmuCore/GS]"
          print key " = " value
        }
      }
    ' "${ARMSX2_INI}" > "${tmp}" && mv "${tmp}" "${ARMSX2_INI}"
  }

  LSFG_DLL_PATH=""
  for candidate in \
    "/storage/roms/bios/armsx2/Lossless.dll" \
    "/storage/games-internal/roms/steam/steamapps/common/Lossless Scaling/Lossless.dll" \
    "/storage/.local/share/Steam/steamapps/common/Lossless Scaling/Lossless.dll" \
    "/storage/roms/steam/steamapps/common/Lossless Scaling/Lossless.dll"; do
    if [ -f "${candidate}" ]; then
      LSFG_DLL_PATH="${candidate}"
      break
    fi
  done

  # ARMSX2's native implementation and lsfg-vk must never run together.
  # Keep the external layer disabled even if the system package is installed.
  export DISABLE_LSFGVK=1
  unset LSFGVK_ENV LSFGVK_DLL_PATH LSFGVK_MULTIPLIER LSFGVK_FLOW_SCALE LSFGVK_PERFORMANCE_MODE LSFGVK_PACING

  if [ "${LSFG_ENABLE}" = "1" ] && [ -n "${LSFG_DLL_PATH}" ]; then
    if [ "${LSFG_TARGET_RATE}" = "auto" ]; then
      LSFG_TARGET_RATE="$(detect_refresh_rate || true)"
      if [ -z "${LSFG_TARGET_RATE}" ]; then
        LSFG_TARGET_RATE=0
        echo "ARMSX2 adaptive LSFG disabled: active display refresh rate could not be detected."
      fi
    fi
    case "${LSFG_TARGET_RATE}" in
      ''|*[!0-9]*) LSFG_TARGET_RATE=0 ;;
    esac
    if [ "${LSFG_PERFORMANCE_MODE}" = "1" ]; then
      LSFG_PERFORMANCE=true
    else
      LSFG_PERFORMANCE=false
    fi
    set_gs_setting LsfgEnabled true
    set_gs_setting LsfgMultiplier "${LSFG_MULTIPLIER}"
    set_gs_setting LsfgDllPath "${LSFG_DLL_PATH}"
    set_gs_setting LsfgPerformance "${LSFG_PERFORMANCE}"
    set_gs_setting LsfgFlowScale "${LSFG_FLOW_SCALE}"
    # A non-zero target enables 2.6.6.8's adaptive pacer. The EmulationStation
    # "adaptive (screen)" choice resolves to the active Wayland mode above.
    set_gs_setting LsfgTargetRate "${LSFG_TARGET_RATE}"
    sed -i '/^Renderer =/c\Renderer = 14' "${ARMSX2_INI}"
    sed -i '/^VsyncEnable =/c\VsyncEnable = true' "${ARMSX2_INI}"
    if [ "${LSFG_TARGET_RATE}" -gt 0 ]; then
      echo "ARMSX2 native adaptive LSFG enabled: x${LSFG_MULTIPLIER}, target ${LSFG_TARGET_RATE}Hz, flow ${LSFG_FLOW_SCALE}%"
    else
      echo "ARMSX2 native LSFG enabled: x${LSFG_MULTIPLIER}, fixed multiplier, flow ${LSFG_FLOW_SCALE}%"
    fi
  else
    set_gs_setting LsfgEnabled false
    set_gs_setting LsfgDllPath "${LSFG_DLL_PATH}"
    set_gs_setting LsfgTargetRate 0
    sed -i '/^VsyncEnable =/c\VsyncEnable = false' "${ARMSX2_INI}"
    if [ "${LSFG_ENABLE}" = "1" ]; then
      echo "ARMSX2 native LSFG disabled: Lossless.dll not found in the ARMSX2 BIOS or Steam directories."
    fi
  fi

#Set QT enviornment to wayland
  export QT_QPA_PLATFORM=wayland

#Run ARMSX2 emulator
  export SDL_AUDIODRIVER=pulseaudio
  set_kill set "-9 armsx2-qt"
  ${EMUPERF} /usr/share/armsx2-sa/armsx2-qt -bigpicture -fullscreen "${1}"
