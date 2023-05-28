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
    
    neorv32_spi_cs_en(SD_CHANNEL);
    sd_send_cmd(CMD0, CMD0_ARG, CMD0_CRC);


    // read response
    uint8_t res1 = sd_read_r1();
    neorv32_spi_cs_dis();
    return res1;
}

/**
 * @brief Sends a CMD8 with CS low to reset the SD card.
 * 
 * @param res buffer of 5 bytes to store the R7 response.
 */
void sd_send_if_cond(uint8_t *res) {
    neorv32_spi_cs_en(SD_CHANNEL);
    sd_send_cmd(CMD8, CMD8_ARG, CMD8_CRC);

    // read response
    sd_read_r7(res);
    neorv32_spi_cs_dis();
}


/**
 * @brief Sends a CMD55 with CS low to reset the SD card.
 * 
 * @return uint8_t R1 response
 */
uint8_t sd_send_app_cmd() {
    neorv32_spi_cs_en(SD_CHANNEL);
    sd_send_cmd(CMD55, CMD55_ARG, CMD55_CRC);

    // read response
    uint8_t r1 = sd_read_r1();
    neorv32_spi_cs_dis();

    return r1;
}

/**
 * @brief Sends a ACMD41 with CS low to reset the SD card.
 * 
 * @return uint8_t R1 response
 */
uint8_t sd_send_app_op_cond() {
    neorv32_spi_cs_en(SD_CHANNEL);
    sd_send_cmd(ACMD41, ACMD41_ARG, ACMD41_CRC);

    // read response
    uint8_t r1 = sd_read_r1();
    neorv32_spi_cs_dis();

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

}

void sd_read_ocr(uint8_t *ocr) {
    neorv32_spi_cs_en(SD_CHANNEL);
    sd_send_cmd(CMD58, CMD58_ARG, CMD58_CRC);

    // read response
    sd_read_r7(ocr);
    neorv32_spi_cs_dis();
}


/**
 * @brief Initialise the SD card. This function will initialise the SD card and set the SPI clock rate to 1 MHz.
 * 
 * @note This code assumes a SDv2 card of either SDHC or SDXC type. SDSC is NOT supported, nor are SDv1 cards.
 * 
 * @return uint8_t error code. 0 if no error.
 */
uint8_t sd_init() {

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
    
    sd_software_reset();

    // send CMD8
    uint8_t res[5];

    if (sd_send_if_cond(res), res[0] != 0x01)
        return SD_CARD_INIT_FAILED;

    // check if the card is SDv2
    if (res[4] != 0xAA) {
        neorv32_uart0_printf("ERROR! SD card not responding.");
        return SD_CARD_NOT_SUPPORTED;
    }


    // attempt to initialize card
    uint8_t cmdAttempts = 0;
    do
    {
        if(cmdAttempts > 100) return SD_CARD_INIT_FAILED;

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
    while(res[0] != 0x01);

    memset(res, 0, 5);

    sd_read_ocr(res);

    if(!(res[2] & 0x80)) 
        return SD_CARD_ERROR;


    return SD_CARD_OK;

}


void sd_write(uint32_t addr, uint32_t data) {
    neorv32_spi_cs_en(SD_CHANNEL);

    // Write stuff to SD card
    uint8_t tx_data = 0;
    uint32_t rx_data = neorv32_spi_trans(tx_data);


    neorv32_spi_cs_dis();
}
