#!/system/bin/sh
#
# MCU Calibration data update.

bus_app_address=0025
bus_number=3
i2c_path=/sys/class/i2c-dev/i2c-$bus_number/device/$bus_number-$bus_app_address
threshold_hinge_offset=53
threshold_camkey_offset=49

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
  echo "$@" > /dev/kmsg
}

# Read DeviceID
if [ -f /persist/DeviceID.txt ]; then
  deviceid=`cat /persist/DeviceID.txt`
else
  kmsg "atmel_init: can't found DeviceID.txt in /persist"
  exit 1
fi

#Check threshold data version
if [ "$deviceid" != "" ]; then
  if [ -f /persist/$deviceid/mcu/v2 ]; then
    kmsg "atmel_init: threshold data version is v2"
  else
    kmsg "atmel_init: threshold data version is v1"
	echo 1 > /persist/$deviceid/mcu/v2
	if [ -f /persist/$deviceid/mcu/threshold_hinge ]; then
	  read_threshold=`cat /persist/$deviceid/mcu/threshold_hinge`
	  if [ "$read_threshold" != "" ]; then
	    cal_threshold=$(($read_threshold-$threshold_hinge_offset))
		echo $cal_threshold > /persist/$deviceid/mcu/threshold_hinge
		kmsg "atmel_init: modify threshold_hinge($read_threshold) to v2($cal_threshold)"
	  else
	    kmsg "atmel_init: threshold_hinge is empty"
	  fi
	else
      kmsg "atmel_init: can't found threshold_hinge in /persist/$deviceid/mcu/"
	  exit 1
    fi

	if [ -f /persist/$deviceid/mcu/threshold_camkey ]; then
	  read_threshold=`cat /persist/$deviceid/mcu/threshold_camkey`
	  if [ "$read_threshold" != "" ]; then
	    cal_threshold=$(($read_threshold-$threshold_camkey_offset))
		echo $cal_threshold > /persist/$deviceid/mcu/threshold_camkey
		kmsg "atmel_init: modify threshold_camkey($read_threshold) to v2($cal_threshold)"
	  else
	    kmsg "atmel_init: threshold_camkey is empty"
	  fi
	else
      kmsg "atmel_init: can't found threshold_camkey in /persist/$deviceid/mcu/"
	  exit 1
    fi
  fi
fi

# Load threshold_hinge
if [ "$deviceid" != "" ]; then
  if [ -f /persist/$deviceid/mcu/threshold_hinge ]; then
    threshold_hinge=`cat /persist/$deviceid/mcu/threshold_hinge`
  else
    kmsg "atmel_init: can't found threshold_hinge in /persist/$deviceid/mcu/"
	exit 1
  fi
  
  if [ -f /persist/$deviceid/mcu/threshold_camkey ]; then
    threshold_camkey=`cat /persist/$deviceid/mcu/threshold_camkey`
  else
    kmsg "atmel_init: can't found threshold_camkey in /persist/$deviceid/mcu/"
	exit 1
  fi
fi

if [ "$threshold_hinge" != "" ]; then
  echo $threshold_hinge > $i2c_path/hinge_threshold
  if [ $? != 0 ]; then
    kmsg "atmel_init: update threshold_hinge to mcu fail"
	exit 1
  else
    kmsg "atmel_init: hinge_threshold = "$threshold_hinge
  fi
fi

if [ "$threshold_camkey" != "" ]; then
  echo $threshold_camkey > $i2c_path/camera_key_threshold
  if [ $? != 0 ]; then
    kmsg "atmel_init: update threshold_camkey to mcu fail"
	exit 1
  else
    kmsg "atmel_init: camera_key_threshold = "$threshold_camkey
  fi
fi

exit 0