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
#include <stdint.h>
#include <string.h>

#include "neorv32.h"

#define SD_CHANNEL 0
#define SD_CARD_DETECT_PIN 10
#define SD_CARD_RESETn_PIN 11

// ENUM for errors
enum SD_ERRORS {
    SD_CARD_NOT_INSERTED = 1,
    SD_CARD_NOT_RESPONDING = 2,
    SD_CARD_INIT_FAILED = 3,
    SD_CARD_READ_FAILED = 4,
    SD_CARD_WRITE_FAILED = 5,
    SD_CARD_ERASE_FAILED = 6,
    SD_CARD_NOT_READY = 7,
    SD_CARD_NOT_PRESENT = 8,
    SD_CARD_NOT_INITIALIZED = 9,
    SD_CARD_NOT_SUPPORTED = 10,
    SD_CARD_INVALID_ARGUMENT = 11,
    SD_CARD_CRC_ERROR = 12,
    SD_CARD_TIMEOUT = 13,
    SD_CARD_ERROR = 14,
    SD_CARD_OK = 0
};

#define SD_READY 0x00
#define SD_START_TOKEN 0xFE
#define SD_BLOCK_SIZE 512
#define SD_WRITE_ACCEPTED 0x05

#define CMD0        0
#define CMD0_ARG    0x00000000
#define CMD0_CRC    0x94

#define CMD8        8
#define CMD8_ARG    0x0000001AA
#define CMD8_CRC    0x86

#define CMD17                   17
#define CMD17_CRC               0x00
#define SD_MAX_READ_ATTEMPTS    1563 //(0.1s * 16000000 MHz)/(128 * 8 bytes) = 1563. 0.1s is the timeout for the SD card.

#define CMD24                   24
#define CMD24_CRC               0x00
#define SD_MAX_WRITE_ATTEMPTS   3907


#define CMD55       55
#define CMD55_ARG   0x00000000
#define CMD55_CRC   0x00

#define CMD58       58
#define CMD58_ARG   0x00000000
#define CMD58_CRC   0x00

#define ACMD41      41
#define ACMD41_ARG  0x40000000
#define ACMD41_CRC  0x00


/**
 * @brief Check if the SD card is inserted.
 * 
 * @return uint8_t 1 if inserted, 0 if not inserted.
 */
uint8_t sd_card_inserted();


/**
 * @brief Initialise the SD card. This function will initialise the SD card and set the SPI clock rate to 1 MHz.
 * 
 * @return uint8_t error code. 0 if no error.
 */
uint8_t sd_init();

/**
 * @brief Read a block from the SD card.
 * 
 * @param addr Address to read in sectors (512 bytes)
 * @param data 512 byte buffer to store sector/block in
 * @param token  token = 0xFE - Successful read, token = 0x0X - Data error, token = 0xFF - Timeout
 * @return uint8_t 
 */
uint8_t sd_read_block(uint32_t addr, uint8_t *data, uint8_t *token);

/**
 * @brief Write a block to the SD card.
 * 
 * @param addr Address to read in sectors (512 bytes)
 * @param data 512 byte buffer to store on the SD card
 * @param token 
 * @return uint8_t status
 */
uint8_t sd_write_block(uint32_t addr, uint8_t *data, uint8_t *token);

#endif