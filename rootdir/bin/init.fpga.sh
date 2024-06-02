#! /vendor/bin/sh

count_max=60
fpga_reflash_max=5
count=0
mtd_dev=0
fpga_fw=/vendor/firmware/fpga/fpga.bit

#check mtd device is exitsted
while [ $count -le $count_max ];
do
    echo "[FPGA]Check mtd device($count sec)..." > /dev/kmsg 
    sleep 1
	cat /proc/mtd | grep spi32766.0 > /dev/null
	if [ $? == 0 ]; then
		count=$count_max
        mtd_dev=1
        echo "[FPGA]Found mtd device" > /dev/kmsg 
	fi

	let count=count+1 
done

let count=1
while [ $count -le $fpga_reflash_max ];
do
	if [ $mtd_dev == 1 ]; then
		spi_size=`cat /sys/bus/spi/devices/spi32766.0/mtd/mtd0/size`
		echo "[FPGA]SPI size: $spi_size" > /dev/kmsg
		spi_version=`cat /sys/bus/spi/devices/spi32766.0/usecode`
		spi_time=$(date -d "$spi_version" +"%s" -D "%a %b %e %H:%M:%S %Y")
		echo "[FPGA]SPI FW timestamp: $spi_time" > /dev/kmsg
		
		fw_size=$((`stat -c%s "$fpga_fw"`-14))
		echo "[FPGA]New FW size: $fw_size" > /dev/kmsg
		fw_version=`xxd -s220 -l24 -g1 -p $fpga_fw | xxd -r -p`
		fw_time=$(date -d "$fw_version" +"%s" -D "%a %b %e %H:%M:%S %Y")
		echo "[FPGA]New FW timestamp: $fw_time" > /dev/kmsg

		#calculate crc32 checksum
		spi_checksum=$(dd if=/dev/mtd/mtd0 bs=4096 | head -c$(($fw_size+14)) | cksum -H | cut -c 1-8)
		echo "[FPGA]SPI checksum: $spi_checksum" > /dev/kmsg
		fw_checksum=$(cksum -H $fpga_fw | cut -c 1-8)
		echo "[FPGA]FW checksum: $fw_checksum" > /dev/kmsg
		 
		#compare fw timestamp, checksum and upgrade
		if [ "$spi_time" -le "$fw_time" ] && [ "$spi_checksum" != "$fw_checksum" ]; then
			echo "[FPGA]Upgrade to FW: $fw_version" > /dev/kmsg
			echo 1 > /sys/bus/spi/devices/spi32766.0/erase_all
			dd if=$fpga_fw of=/dev/mtd/mtd0
		else
			echo "[FPGA] Don't need to upgrade" > /dev/kmsg
			break
		fi

		if [[ $spi_checksum != $fw_checksum ]]; then
			reboot
		fi
	fi
	
	let count=count+1
done







