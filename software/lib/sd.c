/**
 * @file sd.c
 * @author Matthew Gilpin (matt@gilpin.au)
 * @brief This file dictates the implementation of the SD card driver for the NEORV32. This driver uses the SPI driver to communicate with the SD card.
 * @version 0.1
 * @date 2023-05-05
 * 
 * @copyright Copyright (c) 2023
 * 
 */

#include "sd.h"

/**
 * @brief Check if the SD card is inserted.
 * 
 * @return uint8_t 1 if inserted, 0 if not inserted.
 */
uint8_t sd_card_inserted() {
    return !neorv32_gpio_pin_get(SD_CARD_DETECT_PIN);
}


/**
 * @brief Send a command to the SD card.
 * 
 * @param cmd 
 * @param arg 
 * @param crc 
 */
void sd_send_cmd(uint8_t cmd, uint32_t arg, uint8_t crc) {

    neorv32_spi_trans(0x40 | cmd);
    neorv32_spi_trans((uint8_t)(arg >> 24));
    neorv32_spi_trans((uint8_t)(arg >> 16));
    neorv32_spi_trans((uint8_t)(arg >> 8));
    neorv32_spi_trans((uint8_t)(arg));

    neorv32_spi_trans(0x01 | crc);

}

/**
 * @brief Read the R1 response from the SD card.
 * 
 * @return uint8_t 
 */
uint8_t sd_read_r1() {

    uint8_t i = 0, r1;
    
    while (r1 = neorv32_spi_trans(0xFF), r1 == 0xFF) {
        i++;
        if (i > 8)
            break;
    }

    return r1;
}

/**
 * @brief Read the R7 response from the SD card.
 * 
 * @param r7 buffer, len 5
 */
void sd_read_r7(uint8_t *r7) {

    r7[0] = sd_read_r1();

    if (r7[0] > 0x01)
        return;
    
    r7[1] = neorv32_spi_trans(0xFF);
    r7[2] = neorv32_spi_trans(0xFF);
    r7[3] = neorv32_spi_trans(0xFF);
    r7[4] = neorv32_spi_trans(0xFF);
}

/**
 * @brief Sends a CMD0 with CS low to reset the SD card.
 * 
 */
uint8_t sd_software_reset() {
    
    neorv32_spi_trans(0xFF);
    neorv32_spi_cs_en(SD_CHANNEL);
    neorv32_spi_trans(0xFF);
    
    sd_send_cmd(CMD0, CMD0_ARG, CMD0_CRC);


    // read response
    uint8_t res1 = sd_read_r1();
    neorv32_spi_trans(0xFF);
    neorv32_spi_cs_dis();
    neorv32_spi_trans(0xFF);
    return res1;
}

/**
 * @brief Sends a CMD8 with CS low to reset the SD card.
 * 
 * @param res buffer of 5 bytes to store the R7 response.
 */
void sd_send_if_cond(uint8_t *res) {
    neorv32_spi_trans(0xFF);
    neorv32_spi_cs_en(SD_CHANNEL);
    neorv32_spi_trans(0xFF);

    sd_send_cmd(CMD8, CMD8_ARG, CMD8_CRC);

    // read response
    sd_read_r7(res);

    neorv32_spi_trans(0xFF);
    neorv32_spi_cs_dis();
    neorv32_spi_trans(0xFF);
}


/**
 * @brief Sends a CMD55 with CS low to reset the SD card.
 * 
 * @return uint8_t R1 response
 */
uint8_t sd_send_app_cmd() {

    neorv32_spi_trans(0xFF);
    neorv32_spi_cs_en(SD_CHANNEL);
    neorv32_spi_trans(0xFF);

    sd_send_cmd(CMD55, CMD55_ARG, CMD55_CRC);

    // read response
    uint8_t r1 = sd_read_r1();

    neorv32_spi_trans(0xFF);
    neorv32_spi_cs_dis();
    neorv32_spi_trans(0xFF);
    
    return r1;
}

/**
 * @brief Sends a ACMD41 with CS low to reset the SD card.
 * 
 * @return uint8_t R1 response
 */
uint8_t sd_send_app_op_cond() {

    neorv32_spi_trans(0xFF);
    neorv32_spi_cs_en(SD_CHANNEL);
    neorv32_spi_trans(0xFF);

    sd_send_cmd(ACMD41, ACMD41_ARG, ACMD41_CRC);

    // read response
    uint8_t r1 = sd_read_r1();

    neorv32_spi_trans(0xFF);
    neorv32_spi_cs_dis();
    neorv32_spi_trans(0xFF);

    return r1;

}


/**
 * @brief Power on the SD card. Set SPI clock rate between 100 kHz and 400 kHz. Set DI and CS high and 
 * apply 74 or more clock pulses to SCLK. The card will enter its native operating mode and go ready 
 * to accept native command.
 * 
 */
void sd_power_on() {

    // power cycle the SD card
    neorv32_spi_cs_dis();
    neorv32_gpio_pin_set(SD_CARD_RESETn_PIN);
    neorv32_cpu_delay_ms(1);
    neorv32_gpio_pin_clr(SD_CARD_RESETn_PIN);

    neorv32_cpu_delay_ms(1);

    
    // send 80 clock cycles
    for (uint8_t i = 0; i < 10; i++)
        neorv32_spi_trans(0xFF);
    
    neorv32_spi_cs_dis();
    neorv32_spi_trans(0xFF);

}

/**
 * @brief Read the OCR register from the SD card.
 * 
 * @param ocr 
 */
void sd_read_ocr(uint8_t *ocr) {

    neorv32_spi_trans(0xFF);
    neorv32_spi_cs_en(SD_CHANNEL);
    neorv32_spi_trans(0xFF);

    sd_send_cmd(CMD58, CMD58_ARG, CMD58_CRC);

    // read response
    sd_read_r7(ocr);

    neorv32_spi_trans(0xFF);
    neorv32_spi_cs_dis();
    neorv32_spi_trans(0xFF);
}

/**
 * @brief Read a block from the SD card.
 * 
 * @param addr Address to read in sectors (512 bytes)
 * @param data 512 byte buffer to store sector/block in
 * @param token  token = 0xFE - Successful read, token = 0x0X - Data error, token = 0xFF - Timeout
 * @return uint8_t 
 */
uint8_t sd_read_block(uint32_t addr, uint8_t *data, uint8_t *token) {
    uint8_t res, read;
    uint16_t readAttempts;

    // Set token to none
    *token = 0xFF;

    // Send CMD17
    neorv32_spi_cs_en(SD_CHANNEL);
    sd_send_cmd(CMD17, addr, CMD17_CRC);

    // read response
    res = sd_read_r1();

    // if response received from card
    if(res != 0xFF)
    {
        // wait for a response token (timeout = 100ms)
        readAttempts = 0;
        while(++readAttempts != SD_MAX_READ_ATTEMPTS)
            if((read = neorv32_spi_trans(0xFF)) != 0xFF) 
                break;

        // if response token is 0xFE
        if(read == 0xFE) {
            // read 512 byte block
            for(uint16_t i = 0; i < SD_BLOCK_SIZE; i++) 
                *data++ = neorv32_spi_trans(0xFF);

            // read 16-bit CRC
            neorv32_spi_trans(0xFF);
            neorv32_spi_trans(0xFF);
        }

        // set token to card response
        *token = read;
    }

    // set CS high
    neorv32_spi_cs_dis();
    return res;
}


/**
 * @brief Write a block to the SD card.
 * 
 * @param addr Address to read in sectors (512 bytes)
 * @param data 512 byte buffer to store on the SD card
 * @param token 
 * @return uint8_t status
 */
uint8_t sd_write_block(uint32_t addr, uint8_t *data, uint8_t *token) {
    uint8_t readAttempts, read;
    uint8_t res[5];

    // set token to none
    *token = 0xFF;

    // assert chip select
    neorv32_spi_trans(0xFF);
    neorv32_spi_cs_en(SD_CHANNEL);
    neorv32_spi_trans(0xFF);

    // send CMD24
    sd_send_cmd(CMD24, addr, CMD24_CRC);

    // read response
    res[0] = sd_read_r1();

    // if no error
    if(res[0] == SD_READY)
    {
        // send start token
        neorv32_spi_trans(SD_START_TOKEN);

        // write data to card
        for (uint16_t i = 0; i < SD_BLOCK_SIZE; i++) 
            neorv32_spi_trans(data[i]);

        // wait for a response 
        readAttempts = 0;
        while (++readAttempts != SD_MAX_WRITE_ATTEMPTS) {

            if (read = neorv32_spi_trans(0xFF), read != 0xFF) { 

                *token = 0xFF; 
                break; 
            }
        }

        // Check if data accepted - check lower 5 bits
        if ((read & 0x1F) == SD_WRITE_ACCEPTED) {

            // set token to data accepted
            *token = 0x05;

            // wait for write to finish (timeout = 250ms)
            readAttempts = 0;

            while (neorv32_spi_trans(0xFF) == 0x00) {
                if (++readAttempts == SD_MAX_WRITE_ATTEMPTS) { 
                    *token = 0x00; 
                    break;
                }
            }
        }
    }

    // deassert chip select
    neorv32_spi_trans(0xFF);
    neorv32_spi_cs_dis();
    neorv32_spi_trans(0xFF);

    return res[0];
}


/**
 * @brief Initialise the SD card. This function will initialise the SD card and set the SPI clock rate to 1 MHz.
 * 
 * @note This code assumes a SDv2 card of either SDHC or SDXC type. SDSC is NOT supported, nor are SDv1 cards.
 * 
 * @return uint8_t error code. 0 if no error.
 */
uint8_t sd_init() {

    uint8_t res[5];
    uint8_t cmdAttempts = 0;


    // check if SPI unit is implemented at all
    if (neorv32_spi_available() == 0) {
        neorv32_uart0_printf("ERROR! No SPI unit implemented.");
        return 1;
    }

    // Set up SPI
    // Prescalars: 2, 4, 8, 64, 128, 1024, 2048, 4096
    // Set inital SPI speed between 100khz and 400khz

    // f_spi = f_cpu / (2 * prescalar * (1 + clk_div))
    // f_spi = 50 MHz / (2 * 64 * (1 + 0)) = 390.625 kHz
    // f_spi = 50 MHz / (2 * 64 * (1 + 1)) = 195.3125 kHz
    uint8_t spi_prsc = 0b011, clk_div = 1, clk_phase = 0, clk_pol = 0;


    // if (!sd_card_inserted()) {
    //     neorv32_uart0_printf("ERROR! SD card not inserted.");
    //     return SD_CARD_NOT_INSERTED;
    // }

    neorv32_spi_setup(spi_prsc, clk_div, clk_phase, clk_pol, 0);


    sd_power_on();


    // command card to idle
    while((res[0] = sd_software_reset()) != 0x01) {
        cmdAttempts++;
        if(cmdAttempts > 10) 
            return SD_CARD_ERROR;
    }
    


    // send CMD8
    if (sd_send_if_cond(res), res[0] != 0x01)
        return SD_CARD_INIT_FAILED;

    // check if the card is SDv2
    if (res[4] != 0xAA) {
        neorv32_uart0_printf("ERROR! SD card not responding.");
        return SD_CARD_NOT_SUPPORTED;
    }


    // attempt to initialize card
    do
    {
        if(cmdAttempts > 100) 
            return SD_CARD_INIT_FAILED;

        // send app cmd
        res[0] = sd_send_app_cmd();

        // if no error in response
        if(res[0] < 2) {
            res[0] = sd_send_app_op_cond();
        }

        // wait
        neorv32_cpu_delay_ms(10);

        cmdAttempts++;
    }
    while(res[0] != SD_READY);

    neorv32_cpu_delay_ms(1);

    sd_read_ocr(res);

    if(!(res[2] & 0x80)) 
        return SD_CARD_ERROR;


    // speed up bus
    spi_prsc = 1;
    clk_div = 0;
    clk_phase = 0;
    clk_pol = 0;
    
    neorv32_spi_setup(spi_prsc, clk_div, clk_phase, clk_pol, 0);

    return SD_CARD_OK;

}


void sd_write(uint32_t addr, uint32_t data) {
    neorv32_spi_cs_en(SD_CHANNEL);

    // Write stuff to SD card
    uint8_t tx_data = 0;
    uint32_t rx_data = neorv32_spi_trans(tx_data);


    neorv32_spi_cs_dis();
}
