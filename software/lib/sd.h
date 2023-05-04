/**
 * @file sd.h
 * @author Matthew Gilpin (matt@gilpin.au)
 * @brief This file dictates the implementation of the SD card driver for the NEORV32. This driver uses the SPI driver to communicate with the SD card.
 * @version 0.1
 * @date 2023-05-05
 * 
 * @copyright Copyright (c) 2023
 * 
 */

#ifndef SD_H
#define SD_H


#include <stdint.h>

#define SD_CHANNEL 0

void sd_init();

#endif