/**
 * @file ethernet.c
 * @author Matthew Gilpin (matt@gilpin.au)
 * @brief This file contains the implementation of the ethernet driver for the custom VHDL ethernet mac for the NEORV32.
 * @version 0.1
 * @date 2023-04-06
 * 
 * @copyright Copyright (c) 2023
 * 
 */

#include "ethernet.h"

/**
 * @brief Initialise the ethernet mac.
 * 
 */
void eth_init() {

    ETH_MAC_CMD = ETH_MAC_CMD_INIT;
}

/**
 * @brief Send a packet over the ethernet mac.
 * 
 */
void eth_send() {

    ETH_MAC_CMD = ETH_MAC_CMD_START_TX;
}


