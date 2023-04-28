/* SPDX-License-Identifier: GPL-2.0 */
#ifndef _UAPI_AURA_PCI_DEV_I2C_H
#define _UAPI_AURA_PCI_DEV_I2C_H

#include <linux/pci.h>
#include "asic/asic-types.h"

/*
    AMD devices require an i2c adapter to be created,
    NVIDIA devices already have the adapter loaded.
 */
static const struct pci_device_id pciidlist[] = {
    {0x1002, 0x67df, 0x1da2, 0xe366, 0, 0, CHIP_POLARIS10},     // RX580 (Sapphire Nitro+)
    {0x1002, 0x67df, 0x1043, 0x04fd, 0, 0, CHIP_POLARIS10},     // RX480 (Strix)
    {0x1002, 0x67df, 0x1043, 0x0517, 0, 0, CHIP_POLARIS10},     // RX580 (Strix)
    {0x1002, 0x67FF, 0x1043, 0x04BC, 0, 0, CHIP_POLARIS11},     // RX560
    {0x1002, 0x687F, 0x1043, 0x0555, 0, 0, CHIP_VEGA10},        // Vega 56 (Strix)
    {0x1002, 0x687F, 0x1043, 0x04c4, 0, 0, CHIP_VEGA10},        // Vega 64 (Strix)
    // {0x1002, 0x731f, 0x1043, 0x04e2, 0, 0, CHIP_NAVI10},     // RX5700XT (Strix)
    {0x1002, 0x731f, 0x1da2, 0xe410, 0, 0, CHIP_NAVI10},        // RX5700XT (Sapphire)
    {0, 0, 0},
};

#endif
