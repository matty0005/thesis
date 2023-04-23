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
#include <stddef.h>
#include <neorv32.h>

// Errors
#define ETH_ERR_OK 0
#define ETH_ERR_TOO_BIG 1
#define ETH_ERR_TOO_SMALL 2


#define ETH_CTRL_BASE 0x13370100
#define ETH_MAC_BASE 0x13371000
#define ETH_MAC_CMD_BASE 0x13370000


#define ETH_MAC_CMD  (*(volatile uint32_t *)ETH_MAC_CMD_BASE)
#define ETH_MAC ((EthMac *) ETH_MAC_BASE)
#define ETH_CTRL (*(volatile uint32_t *) ETH_CTRL_BASE)

#define ETH_MAC_CMD_INIT 0x1
#define ETH_MAC_CMD_START_TX 0x2
#define ETH_MAC_CMD_IDLE 0x00

#define ETH_CTRL_RESET 0x01

#define PHY_MDC 0x08
#define PHY_MDIO 0x09

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
uint8_t eth_init();

/**
 * @brief Send a packet over the ethernet mac.
 * 
 * @param data 
 * @param len 
 */
uint8_t eth_send(uint8_t *data, size_t len);

/**
 * @brief Gets the size of the packet in the receive buffer.
 * 
 * @return size_t 
 */
size_t eth_recv_size();

/**
 * @brief Receive a packet from the ethernet mac.
 * 
 * @param buffer 
 */
void eth_recv(uint8_t *buffer);

/**
 * @brief Sends a demo packet over the ethernet mac.
 * 
 */
void eth_send_demo();


/**
 * @brief Reads a register from the phy.
 * 
 * @param phy_addr 
 * @param reg_addr 
 * @param data 
 * @return uint8_t 
 */
uint8_t phy_mdio_read(uint8_t phy_addr, uint8_t reg_addr, uint8_t *data);

#endif