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

    // Save all rules so that we know these are the most up to date ones.
    // pc_save_rules_all(buffer, *size);

    return 0;
}


/**
 * @brief Save all rules to the packet classifier
 * 
 * @param pcRawData String raw data from file or API.
 * @param size The maximum number of rules - default should be 8
 * @return int 0 if no error, 1 if error
 */
int pc_save_rules_all(uint8_t *pcRawData, uint8_t size) {

    uint8_t location, wildcard, protocol;
    uint8_t destIP[4], sourceIP[4];
    uint16_t destPort, sourcePort;

    for (uint8_t i = 0; i < size; i++) {

        // location = (uint8_t) hex_byte_to_int(pcRawData);
        wildcard = (uint8_t) hex_byte_to_int(pcRawData + 2);

        destIP[0] = hex_byte_to_int(pcRawData + 4);
        destIP[1] = hex_byte_to_int(pcRawData + 6);
        destIP[2] =  hex_byte_to_int(pcRawData + 8);
        destIP[3] =  hex_byte_to_int(pcRawData + 10);

        sourceIP[0] = hex_byte_to_int(pcRawData + 12);
        sourceIP[1] = hex_byte_to_int(pcRawData + 14);
        sourceIP[2] = hex_byte_to_int(pcRawData + 16);
        sourceIP[3] = hex_byte_to_int(pcRawData+ 18);

        destPort = (uint16_t) hex_byte_to_int(pcRawData + 20) << 8 | (uint16_t) hex_byte_to_int(pcRawData + 22);
        sourcePort = (uint16_t) hex_byte_to_int(pcRawData + 24) << 8 | (uint16_t) hex_byte_to_int(pcRawData + 26);

        protocol = hex_byte_to_int(pcRawData + 28);

        // Save the rule to the packet classifier.
        pc_save_rule(i, wildcard, destIP, sourceIP, destPort, sourcePort, protocol);

        // Got to add 1 to pointer to account for \n
        // if no more \n then break
        if (pcRawData[30] != '\n') {
            break;
        }
        pcRawData += 31; //Might need to be 30.
    }

    return 0;
} 


/* Standard includes. */
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

/* FreeRTOS includes. */
#include "FreeRTOS.h"
#include "task.h"

/* FreeRTOS+TCP includes. */
#include "FreeRTOS_IP.h"
#include "FreeRTOS_Sockets.h"

static uint8_t swap_bits(uint8_t bits) {
    uint8_t result = 0;
    for (uint8_t i = 0; i < 8; i++) {
        result |= ((bits >> i) & 0x01) << (7 - i);
    }
    return result;
}

/**
 * @brief Get the valid packet count
 * 
 * @return uint64_t the count 
 */
uint64_t pc_get_valid_packet_count() {
    neorv32_spi_cs_dis();
    neorv32_spi_cs_en(PC_CTRL_SPI_CHANNEL);

    neorv32_spi_trans(PC_CTRL_VALID);
    neorv32_spi_cs_dis();
    neorv32_spi_cs_en(PC_CTRL_SPI_CHANNEL);
    uint64_t count = 0;

    for (uint8_t i = 0; i < 8; i++) 
        count |= (swap_bits(neorv32_spi_trans(PC_CTRL_NULL)) << (i * 8));
    
    
    neorv32_spi_cs_dis();

    return count;
}

/**
 * @brief Get the blocked packet count
 * 
 * @return uint64_t the count
 */
uint64_t pc_get_blocked_packet_count() {
    neorv32_spi_cs_dis();
    neorv32_spi_cs_en(PC_CTRL_SPI_CHANNEL);

    neorv32_spi_trans(PC_CTRL_INVALID);

    neorv32_spi_cs_dis();
    neorv32_spi_cs_en(PC_CTRL_SPI_CHANNEL);
    uint64_t count = 0;

    for (uint8_t i = 0; i < 8; i++)
        count |= (swap_bits(neorv32_spi_trans(PC_CTRL_NULL)) << (i * 8));
    


    neorv32_spi_cs_dis();

    return count;
}

/**
 * @brief Get the total packet count
 * 
 * @return uint64_t the count
 */
uint64_t pc_get_total_packet_count() {

    neorv32_spi_cs_dis();
    neorv32_spi_cs_en(PC_CTRL_SPI_CHANNEL);

    neorv32_spi_trans(PC_CTRL_TOTAL);
    neorv32_spi_cs_dis();
    neorv32_spi_cs_en(PC_CTRL_SPI_CHANNEL);
    uint64_t count = 0;

    for (uint8_t i = 0; i < 8; i++) 
        count |= (swap_bits(neorv32_spi_trans(PC_CTRL_NULL)) << (i * 8));
    
    
    neorv32_spi_cs_dis();

    return count;
}


/**
 * @brief Get the status of the packet classifier
 * 
 * @return uint8_t 
 */
uint8_t pc_get_status() {
    // Status is based on GPIO pin 11
    return !!neorv32_gpio_pin_get(12);
}

/**
 * @brief Reset the packet classifier counts
 * 
 */
void pc_reset_counts() {

    neorv32_spi_cs_dis();
    neorv32_spi_cs_en(PC_CTRL_SPI_CHANNEL);


    neorv32_spi_trans(PC_CTRL_RST);
    neorv32_spi_trans(0x00); // send second one just for it to be set high for 1 clk cycle
    
    neorv32_spi_cs_dis();
}