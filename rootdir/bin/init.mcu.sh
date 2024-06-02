#! /vendor/bin/sh
#
# MCU initialization :
# 1. MCU GPIO setting.
# 2. MCU auto fw update check.
# 3. MCU calibration data update and change mcu state to ALIVE.

fw_file=/vendor/firmware/atmel/mcu_fw.bin

#######################################
# Send message to kernel debug message
# Globals:
#   None
# Arguments:
#   $@ debug message
# Returns:
#   None
#######################################
kmsg() {
  echo "atmel_init: $@" > /dev/kmsg
}

kmsg "start"

# MCU GPIO Setting
if [ -f /sys/class/gpio/gpio0/active_low ]; then
  echo 1 > /sys/class/gpio/gpio0/active_low
fi

if [ -f /sys/class/gpio/gpio4/active_low ]; then
  cat /proc/cmdline | grep evbid=1
  if [ $? == 0 ]; then
    echo 1 > /sys/class/gpio/gpio4/active_low
  fi
fi

# Auto fw update
if [ -f $fw_file ]; then
  bin_fw_ver=`cat $fw_file | grep -a "FW_VER:" | cut -d":" -f2`
  kmsg "bin_fw_ver=$bin_fw_ver"
  dev_fw_ver=`sh /vendor/bin/atmel_cmd.sh read_fw_ver`
  kmsg "dev_fw_ver=$dev_fw_ver"
  if [ $bin_fw_ver -gt $dev_fw_ver ]; then
    sh /vendor/bin/atmel_swd_flash.sh $fw_file YES
  fi
else
  kmsg "can't found $fw_file"
fi

# Calibration data update and change mcu state to ALIVE.
sh /vendor/bin/atmel_update_cal_data.sh
kmsg "Set Alive to mcu_state"
sh /vendor/bin/atmel_cmd.sh write_mcu_state ALIVE
sh /vendor/bin/atmel_cmd.sh set_led ON_BREATH

kmsg "end"
