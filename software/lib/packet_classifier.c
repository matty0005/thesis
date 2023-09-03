/**
 * @file packet_classifier.c
 * @author Matthew Gilpin (matt@gilpin.au)
 * @brief 
 * @version 0.1
 * @date 2023-08-11
 * 
 * @copyright Copyright (c) 2023
 * 
 */

#include "packet_classifier.h"

/**
 * @brief Initialise the packet classifier.
 * 
 */
void pc_init() {
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
    uint8_t spi_prsc = 0b011, clk_div = 3, clk_phase = 0, clk_pol = 0;
    spi_prsc = 1;
    clk_div = 0;
    clk_phase = 0;
    clk_pol = 0;

    neorv32_spi_setup(spi_prsc, clk_div, clk_phase, clk_pol, 0);
}

/**
 * @brief Save a rule to the packet classifier
 * 
 * @param address The address to store the rule
 * @param wildcard Least significant 5 bits are used as a wildcard
 * @param destIP Destination IP of the rule
 * @param srcIP Source IP of the rule
 * @param destPort destination port for the rule
 * @param srcPort Source port for the rule
 * @param protocol Protocol for the rule
 */
void pc_save_rule(uint8_t address, uint8_t wildcard, uint8_t *destIP, uint8_t *srcIP, uint16_t destPort, uint16_t srcPort, uint8_t protocol) {

    neorv32_spi_cs_dis();
    neorv32_spi_cs_en(PC_SPI_CHANNEL);


    neorv32_spi_trans(address);
    neorv32_spi_trans(wildcard);

    neorv32_spi_trans(destIP[0]);
    neorv32_spi_trans(destIP[1]);
    neorv32_spi_trans(destIP[2]);
    neorv32_spi_trans(destIP[3]);

    neorv32_spi_trans(srcIP[0]);
    neorv32_spi_trans(srcIP[1]);
    neorv32_spi_trans(srcIP[2]);
    neorv32_spi_trans(srcIP[3]);

    neorv32_spi_trans((destPort >> 8) & 0xFF);
    neorv32_spi_trans(destPort & 0xFF);

    neorv32_spi_trans((srcPort >> 8) & 0xFF);
    neorv32_spi_trans(srcPort & 0xFF);

    neorv32_spi_trans(protocol);

    neorv32_spi_cs_dis();
}


/**
 * @brief Get the rules from the packet classifier
 * 
 * @param buffer: make sure it is sufficiently large >= 240. 
 * @param bufferSize: size of buffer
 * @param size: size of data read.
 * @return int: 0 if no error, 1 if error
 */
int pc_get_rules(uint8_t *buffer, uint32_t bufferSize, uint32_t *size) {


    FF_FILE *filehandle = ff_fopen( "/firewall/filter.rules", "rb" );

    if (filehandle != NULL) {

        *size = ff_fread(buffer, 1, bufferSize, filehandle);

        ff_fclose(filehandle);
    
    } else {
        return 1;
    }

    return 0;
}
