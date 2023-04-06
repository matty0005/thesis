/**
 * @file ethernet.h
 * @author Matthew Gilpin (matt@gilpin.au)
 * @brief This file contains the implementation of the ethernet driver for the custom VHDL ethernet mac for the NEORV32.
 * @version 0.1
 * @date 2023-04-06
 * 
 * @copyright Copyright (c) 2023
 * 
 */

#ifndef ETHERNET_H
#define ETHERNET_H

#include <stdint.h>


#define ETH_MAC_BASE 0x13371000
#define ETH_MAC_CMD_BASE 0x13370000


#define ETH_MAC_CMD  (*(volatile uint32_t *)ETH_MAC_CMD_BASE)
#define ETH_MAC ((EthMac *) ETH_MAC_BASE)

#define ETH_MAC_CMD_INIT 0x1
#define ETH_MAC_CMD_START_TX 0x2



// Mem location starts at 0x13371000
typedef struct __attribute__((__packed__))  {
    volatile uint32_t DEST[2];
    volatile uint32_t LEN;
    volatile uint32_t DATA[375]; // 1500 / 4 = 375.
} EthMac;


/**
 * @brief Register layout
 * 
 * +--------------------------------------------------+
 * |              0x13370000: Config Reg              |
 * +----------------+----------------+----------------+
 * |  [31:2]        |   [1]          |    [0]         |
 * +----------------+----------------+----------------+
 * | reserved       | Start tx       | Initalise      |
 * +----------------+----------------+----------------+
 */
typedef struct __attribute__((__packed__))  {
    uint32_t init:1;
    uint32_t start_tx:1;
    uint32_t reserved:30;
} EthMacConfig;


/**
 * @brief Initialise the ethernet mac.
 * 
 */
void eth_init();

/**
 * @brief Send a packet over the ethernet mac.
 * 
 */
void eth_send();

#endif