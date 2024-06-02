#!/system/bin/sh
#
# MCU control command.

bus_app_address=0025
bus_number=3
i2c_path=/sys/class/i2c-dev/i2c-$bus_number/device/$bus_number-$bus_app_address

#######################################
# Send message to STDERR
# Globals:
#   None
# Arguments:
#   $@ debug message
# Returns:
#   None
#######################################
err() {
  echo "$@" >&2
}

#######################################
# Send message to STDOUT
# Globals:
#   None
# Arguments:
#   $@ message
# Returns:
#   None
#######################################
msg() {
  echo "$@"
}

#######################################
# Help
# Globals:
#   None
# Arguments:
#   None
# Returns:
#   None
#######################################
help() {
  msg "usage: atmel_cmd.sh <command> [<value>]"
  msg "command :"
  msg "     read_fw_ver"
  msg "     read_hall_adc"
  msg "     read_mcu_state"
  msg "     write_mcu_state <ALIVE | FACTORY>"
  msg "     read_hinge_status"
  msg "     read_camkey_status"
  msg "     read_hinge_threshold"
  msg "     read_camkey_threshold"
  msg "     read_hinge_debounce"
  msg "     read_camkey_debounce"
  msg "     write_hinge_debounce <time-ms>"
  msg "     write_camkey_debounce <time-ms>"
  msg "     enter_standby"
  msg "     enter_standby_poweroff <wait>"
  msg "     mcu_reset"
  msg "     set_led <OFF | ON_BREATH | BLINK_FAST | BLINK_MEDIUM | BLINK_SLOW>"
  msg "     read_led_status"
}

if [ "$1" == "" ]; then
  err "Input parameter error"
  help
  exit 1
fi

case "$1" in
  help)
    help
    exit 0
  ;;

  READ_FW_VER | read_fw_ver)
    cat $i2c_path/firmware_version
  ;;

  READ_HALL_ADC | read_hall_adc)
    cat $i2c_path/hall_adc
  ;;

  READ_MCU_STATE | read_mcu_state)
    val=`cat $i2c_path/power_state`
    case "$val" in
      0) msg "($val) POWER_OFF" ;;
      1) msg "($val) BOOTING" ;;
      3) msg "($val) ALIVE" ;;
      4) msg "($val) SHUTTING_DOWN" ;;
      6) msg "($val) SLEEP" ;;
      8) msg "($val) OFF_MODE_CHARGING" ;;
      99) msg "($val) FACTORY" ;;
      *) msg "($val) Unknown" ;;
    esac;
    ;;

  WRITE_MCU_STATE | write_mcu_state)
    if [ "$2" == "" ]; then
      err "Input parameter error"
      help
      exit 1
    fi

    case "$2" in
      ALIVE | alive)
        echo 3 > $i2c_path/power_state
        ;;

      FACTORY | factory)
        echo 99 > $i2c_path/power_state
        ;;

      *)
        err "Input parameter error"
        help
        exit 1
        ;;
	esac;
	;;

  READ_HANGE_STATUS | read_hinge_status)
    val=`cat $i2c_path/hinge_status`
    case "$val" in
      0) msg "($val) ON" ;;
      1) msg "($val) OFF" ;;
      *) msg "($val) Unknown" ;;
    esac;
    ;;

  READ_CAMKEY_STATUS | read_camkey_status)
    val=`cat $i2c_path/camera_key_status`
    case "$val" in
      0) msg "($val) ON" ;;
      1) msg "($val) OFF" ;;
      *) msg "($val) Unknown" ;;
    esac;
    ;;

  READ_HINGE_THRESHOLD | read_hinge_threshold)
    cat $i2c_path/hinge_threshold
    ;;

  READ_CAMKEY_THRESHOLD | read_camkey_threshold)
    cat $i2c_path/camera_key_threshold
    ;;

  READ_HINGE_DEBOUNCE | read_hinge_debounce)
    cat $i2c_path/hinge_debounce
    ;;

  WRITE_HINGE_DEBOUNCE | write_hinge_debounce)
    if [ "$2" == "" ]; then
      err "Input parameter error"
      help
      exit 1
    fi
    echo $2 > $i2c_path/hinge_debounce
    ;;

  READ_CAMKEY_DEBOUNCE | read_camkey_debounce)
    cat $i2c_path/camera_key_debounce
    ;;

  WRITE_CAMKEY_DEBOUNCE | write_camkey_debounce)
    if [ "$2" == "" ]; then
      err "Input parameter error"
      help
      exit 1
    fi
    echo $2 > $i2c_path/camera_key_debounce
	;;

  ENTER_STANDBY | enter_standby)
    echo 100 > $i2c_path/power_state
    ;;

  ENTER_STANDBY_POWEROFF | enter_standby_poweroff)
    if [ "$2" == "" ]; then
      err "Input parameter error"
      help
      exit 1
    fi
    echo 100 > $i2c_path/power_state
    sleep $2
    reboot -p
    ;;

  MCU_RESET | mcu_reset)
    echo app > $i2c_path/change_mode
    sh /vendor/bin/atmel_update_cal_data.sh
    echo 3 > $i2c_path/power_state
    echo 1 > $i2c_path/led_ctrl
    ;;

  SET_LED | set_led)
    if [ "$2" == "" ]; then
      err "Input parameter error"
      help
      exit 1
    fi

    case "$2" in
      OFF | off)
        echo 0 > $i2c_path/led_ctrl
        ;;

      ON_BREATH | on_breath)
        echo 1 > $i2c_path/led_ctrl
        ;;

      BLINK_FAST | blink_fast)
        echo 3 > $i2c_path/led_ctrl
        ;;

      BLINK_MEDIUM | blink_medium)
        echo 4 > $i2c_path/led_ctrl
        ;;

      BLINK_SLOW | blink_slow)
        echo 5 > $i2c_path/led_ctrl
        ;;

      *)
        err "Input parameter error"
        help
        exit 1
        ;;
    esac;
    ;;

  READ_LED_STATUS | read_led_status)
    val=`cat $i2c_path/led_ctrl`
    case "$val" in
      0) msg "($val) OFF" ;;
      1) msg "($val) ON_BREATH" ;;
      3) msg "($val) BLINK_FAST" ;;
      4) msg "($val) BLINK_MEDIUM" ;;
      5) msg "($val) BLINK_SLOW" ;;
      *) msg "($val) Unknown" ;;
    esac;
    ;;

  *)
    err "Input parameter error"
    help
    exit 1
    ;;
esac;