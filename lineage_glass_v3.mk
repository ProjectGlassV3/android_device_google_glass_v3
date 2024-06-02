#
# Copyright (C) 2024 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

# Inherit from those products. Most specific first.
$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base_telephony.mk)

# Inherit some common Lineage stuff.
$(call inherit-product, vendor/lineage/config/common_full_phone.mk)

# Inherit from glass_v3 device
$(call inherit-product, device/google/glass_v3/device.mk)

PRODUCT_DEVICE := glass_v3
PRODUCT_NAME := lineage_glass_v3
PRODUCT_BRAND := Android
PRODUCT_MODEL := Glass Enterprise Edition 2
PRODUCT_MANUFACTURER := google

PRODUCT_GMS_CLIENTID_BASE := android-google

PRODUCT_BUILD_PROP_OVERRIDES += \
    PRIVATE_BUILD_DESC="glass_v3-user 8.1.0 OPM1.221111.001 eng.idzkow.20221111.224234 release-keys"

BUILD_FINGERPRINT := Android/glass_v3/glass_v3:8.1.0/OPM1.221111.001/idzkow11112242:user/release-keys
