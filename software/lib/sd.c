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
 * @brief Power on the SD card. Set SPI clock rate between 100 kHz and 400 kHz. Set DI and CS high and 
 * apply 74 or more clock pulses to SCLK. The card will enter its native operating mode and go ready 
 * to accept native command.
 * 
 */
void sd_power_on() {
    neorv32_spi_cs_dis();

    neorv32_cpu_delay_ms(1);

    neorv32_spi_cs_en(SD_CHANNEL);
    
    // send 80 clock cycles
    for (uint8_t i = 0; i < 10; i++)
        neorv32_spi_trans(0xFF);
    
    neorv32_spi_cs_dis();

}

/**
 * @brief Initialise the SD card.
 * 
 */
void sd_init() {


    // check if SPI unit is implemented at all
    if (neorv32_spi_available() == 0) {
        neorv32_uart0_printf("ERROR! No SPI unit implemented.");
        return 1;
    }

    // Set up SPI
    // Prescalars: 2, 4, 8, 64, 128, 1024, 2048, 4096
    // Set inital SPI speed between 100khz and 400khz
    uint8_t spi_prsc = 0, clk_div = 1, clk_phase = 0, clk_pol = 0;

    neorv32_spi_setup(spi_prsc, clk_div, clk_phase, clk_pol, 0);


    sd_power_on();


}


void sd_write(uint32_t addr, uint32_t data) {
    neorv32_spi_cs_en(SD_CHANNEL);

    // Write stuff to SD card
    uint8_t tx_data = 0;
    uint32_t rx_data = neorv32_spi_trans(tx_data);


    neorv32_spi_cs_dis();
}
