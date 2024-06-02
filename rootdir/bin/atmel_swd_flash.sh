#!/system/bin/sh
#
# MCU fw update over SWD.

RST_GPIO=0
SWD_CLK_GPIO=4
SWD_DIO_GPIO=5
blank_bin=/vendor/firmware/atmel/blank.bin
evtgold_bin=/vendor/firmware/atmel/evtgold.bin
fw_file=$1
MCU_INIT_CALL=$2

#######################################
# Send message to STDERR or kmsg
# Globals:
#   MCU_INIT_CALL
# Arguments:
#   $@ debug message
# Returns:
#   None
#######################################
err() {
  if [ "$MCU_INIT_CALL" == "YES" ]; then
    echo "atmel_sw_flash: $@" > /dev/kmsg
  else
    echo "$@" >&2
  fi
}

#######################################
# Send message to STDOUT or kmsg
# Globals:
#   MCU_INIT_CALL
# Arguments:
#   $@ message
# Returns:
#   None
#######################################
msg() {
  if [ "$MCU_INIT_CALL" == "YES" ]; then
    echo "atmel_sw_flash: $@" > /dev/kmsg
  else
    echo "$@"
  fi
}

#######################################
# Update Calibration data and
# change MCU state to Alive and set LED ON
# Globals:
#   MCU_INIT_CALL
# Arguments:
#   None
# Returns:
#   None
#######################################
mcu_caldata_state_update() {
  if [ ! "$MCU_INIT_CALL" == "YES" ]; then
    sh /vendor/bin/atmel_update_cal_data.sh
    sh /vendor/bin/atmel_cmd.sh write_mcu_state ALIVE
    sh /vendor/bin/atmel_cmd.sh set_led ON_BREATH
  fi
}

if [ "$1" == "" ]; then
  err "Input parameter error"
  exit 1
fi

sh /vendor/bin/atmel_cmd.sh write_mcu_state FACTORY

msg "[SWD] Clear MCU fuse ..."
/vendor/bin/edbg -b -s $SWD_DIO_GPIO -S $SWD_CLK_GPIO -n $RST_GPIO -t atmel_cm0p -F wv,*,$blank_bin
if [ $? != 0 ]; then
  err "Clear MCU fuse -- fail!!"
  mcu_caldata_state_update
  exit 1
fi

msg "[SWD] Flash fw($1) ..."
/vendor/bin/edbg -e -b -s $SWD_DIO_GPIO -S $SWD_CLK_GPIO -n $RST_GPIO -t atmel_cm0p -p -f $fw_file
if [ $? != 0 ]; then
  err "Flash MCU FW -- fail!!"
  mcu_caldata_state_update
  exit 1
fi

msg "[SWD] Write MCU fuse ..."
/vendor/bin/edbg -b -s $SWD_DIO_GPIO -S $SWD_CLK_GPIO -n $RST_GPIO -t atmel_cm0p -F wv,*,$evtgold_bin
if [ $? != 0 ]; then
  err "Write MCU fuse -- fail!!"
  mcu_caldata_state_update
  exit 1
else
  err "Flash MCU FW -- pass!!"
  mcu_caldata_state_update
  exit 0
fi