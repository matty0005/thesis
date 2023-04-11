/**
 * @file ethernet.c
 * @author Matthew Gilpin (matt@gilpin.au)
 * @brief This file contains the implementation of the ethernet driver for the custom VHDL ethernet mac for the NEORV32.
 * @version 0.1
 * @date 2023-04-06
 * 
 * @copyright Copyright (c) 2023
 * 
 * Useful link: https://www.freertos.org/FreeRTOS-Plus/FreeRTOS_Plus_TCP/TCP_Networking_Tutorial_Adding_Source_Files.html
 * 
 */

#include "ethernet.h"

/**
 * @brief Initialise the ethernet mac.
 * 
 */
uint8_t eth_init() {

    ETH_CTRL = ETH_CTRL_RESET;
    ETH_MAC_CMD = ETH_MAC_CMD_INIT;

    return ETH_ERR_OK;
}

/**
 * @brief Send a packet over the ethernet mac.
 * 
 * @param data 
 * @param len 
 */
uint8_t eth_send(uint8_t *data, size_t len) {

    // Check the length of the packet.
    if (len > 1500) {
        return ETH_ERR_TOO_BIG;
    }

    if (len < 46) {
        return ETH_ERR_TOO_SMALL;
    }

    // Initialise the buffers in hardware
    ETH_MAC_CMD = ETH_MAC_CMD_INIT;

    // Set the destination mac
    ETH_MAC->DEST[0] = data[0] << 24 | data[1] << 16 | data[2] << 8 | data[3];
    ETH_MAC->DEST[1] = data[4] << 24 | data[5] << 16;

    // Set the length of the packet.
    ETH_MAC->LEN = data[6] << 8 | data[7]; 

    // Set the data of the packet.
    for (int i = 8; i < len; i++) {

        ETH_MAC->DATA[i] = data[i];
    }

    // Send a packet.
    ETH_MAC_CMD = ETH_MAC_CMD_START_TX;

    // Need to set the idle state. Otherwise packet gets sent again.
    ETH_MAC_CMD = ETH_MAC_CMD_IDLE;

    return ETH_ERR_OK;
}

/**
 * @brief Gets the size of the packet in the receive buffer.
 * 
 * @return size_t 
 */
size_t eth_recv_size() {
    return 1;
}


/**
 * @brief Receive a packet from the ethernet mac.
 * 
 * @param buffer 
 */
void eth_recv(uint8_t *buffer) {

}

/**
 * @brief Sends a demo packet over the ethernet mac.
 * 
 */
void eth_send_demo() {
    ETH_MAC_CMD = ETH_MAC_CMD_INIT;

    // set the destination mac
    ETH_MAC->DEST[0] = 0xaabbccdd;
    ETH_MAC->DEST[1] = 0x55667788;

    // set the length of the packet.
    ETH_MAC->LEN = 0x0000000F;
    // neorv32_uart0_printf("LEN: %x\n", ETH_MAC->LEN);

    // set the data of the packet.
    ETH_MAC->DATA[0] = 0xbeefcafe;
    ETH_MAC->DATA[1] = 0x11223344;
    ETH_MAC->DATA[2] = 0x55667788;
    ETH_MAC->DATA[3] = 0x99aabbcc;


    // send a packet.
    ETH_MAC_CMD = ETH_MAC_CMD_START_TX;

    // Need to set the idle state. Otherwise packet gets sent again.
    ETH_MAC_CMD = ETH_MAC_CMD_IDLE;
}