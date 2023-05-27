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

    // ack the interrupt.
    eth_ack_irq();

    return ETH_ERR_OK;
}

/**
 * @brief Send a packet over the ethernet mac.
 * 
 * @param data 
 * @param len 
 */
uint8_t eth_send(uint8_t *data, size_t len) {


    char buff[60] = {0};
    sprintf(buff, "size %d, \r\n", len);
    neorv32_uart0_printf(buff);

    for (int i = 0; i < len; i++) {
        sprintf(buff, "%02x", data[i]);
        neorv32_uart0_printf(buff);
    }
    neorv32_uart0_printf("\n");

    // Check the length of the packet.
    if (len > 1500) {
        return ETH_ERR_TOO_BIG;
    }

    // if (len < 46) {
    //     return ETH_ERR_TOO_SMALL;
    // }

    // Initialise the buffers in hardware
    ETH_MAC_CMD = ETH_MAC_CMD_INIT;

    ETH_MAC_TX->SIZE = len; 

    // Set the data of the packet.
    for (int i = 0; i < len; i = i + 4) {

        ETH_MAC_TX->DATA[i >> 2] = (data[i] << 24) | (data[i + 1] << 16) | (data[i + 2] << 8) | (data[i + 3]);
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

    neorv32_uart0_printf("\nLen: %d\r\n", ETH_MAC_RX->SIZE);
    
    return ETH_MAC_RX->SIZE;
}

/**
 * @brief Acknowledge the interrupt from the ethernet mac.
 * 
 */
void eth_ack_irq() {
    // Acknowledge the interrupt.
    ETH_CTRL_RX |= (1 << ETH_CTRL_RX_IQR_ACK_Pos);
    ETH_CTRL_RX &= ~(0 << ETH_CTRL_RX_IQR_ACK_Pos);
}

/**
 * @brief Receive a packet from the ethernet mac.
 * 
 * @param buffer 
 */
void eth_recv(uint8_t *buffer, size_t size) {

    // May need to factor in MAC header stuff - depends what freertos tcp wants.

    // Copy the data from the receive buffer.
    for (int i = 0; i < (size / 4); i++) {
        uint32_t dat = ETH_MAC_RX->DATA[i];

        for (int j = 0; j < 4; j++)
            buffer[(i << 2) + j] = 0xFF & (dat >> ((3 - j) * 8)); 

    }
}

/**
 * @brief Receive a raw packet from the ethernet mac. THis includes all ethernet headers
 * 
 * @param buffer 
 */
void eth_recv_raw(uint8_t *buffer) {

    // Get the size of the packet.
    size_t size = eth_recv_size();

    // Copy the data from the receive buffer.
    for (int i = 0; i < (size / 4); i++) {
        uint32_t dat = ((uint32_t *) ETH_MAC_RX_BASE)[i];
        neorv32_uart0_printf("raw> %X, %d, %p\n", dat, i, &((uint32_t *) ETH_MAC_RX_BASE)[i]);

        for (int j = 0; j < 4; j++)
            buffer[(i << 2) + j] = 0xFF & (dat >> (j * 8));

    }
}

/**
 * @brief Receive a raw packet from the ethernet mac. THis includes all ethernet headers. This function also sets the size of payload to grab
 * 
 * @param buffer 
 */
void eth_recv_raw_size(uint8_t *buffer, uint16_t size) {


    // Copy the data from the receive buffer.
    for (int i = 0; i < (size / 4); i++) {
        uint32_t dat = ((uint32_t *) ETH_MAC_RX->DATA)[i];
        neorv32_uart0_printf("raw> %X, %d, %p\n", dat, i, &((uint32_t *) ETH_MAC_RX_BASE)[i]);

        for (int j = 0; j < 4; j++)
            buffer[(i << 2) + j] = 0xFF & (dat >> (j * 8));

    }
}

/**
 * @brief Sends a demo packet over the ethernet mac.
 * 
 */
void eth_send_demo() {
    ETH_MAC_CMD = ETH_MAC_CMD_INIT;

    // set the length of the packet.
    ETH_MAC_TX->SIZE = 0x002E; //Size of data in bytes

    // set the data of the packet.
    // ARP header
    ETH_MAC_TX->DATA[0] = 0xffffffff;
    ETH_MAC_TX->DATA[1] = 0xffffbeef;
    ETH_MAC_TX->DATA[2] = 0xbabe1337;
    ETH_MAC_TX->DATA[3] = 0x08004500;
    ETH_MAC_TX->DATA[4] = 0x002eb3fe;
    ETH_MAC_TX->DATA[5] = 0x00008011;
    ETH_MAC_TX->DATA[6] = 0x05400a00;
    ETH_MAC_TX->DATA[7] = 0x00beffff;
    ETH_MAC_TX->DATA[8] = 0xffff001a;
    ETH_MAC_TX->DATA[9] = 0x2de80001;
    ETH_MAC_TX->DATA[10] = 0x02030405;
    ETH_MAC_TX->DATA[11] = 0x06070809;
    ETH_MAC_TX->DATA[12] = 0x0a0b0c0d;
    ETH_MAC_TX->DATA[13] = 0x0e0f1011;

    // send a packet.
    ETH_MAC_CMD = ETH_MAC_CMD_START_TX;

    // Need to set the idle state. Otherwise packet gets sent again.
    ETH_MAC_CMD = ETH_MAC_CMD_IDLE;
}


void phy_smi_start() {

    neorv32_gpio_pin_set(PHY_MDIO); 
    neorv32_gpio_pin_set(PHY_MDC); 

    // 32 clock cycls for preamble.
    for (int i = 0; i < 31; i++) {
        neorv32_gpio_pin_clr(PHY_MDC); 
        neorv32_gpio_pin_set(PHY_MDC); 
    }

    // Start of frame.
    neorv32_gpio_pin_clr(PHY_MDIO);
    neorv32_gpio_pin_clr(PHY_MDC);
    neorv32_gpio_pin_set(PHY_MDC);
    neorv32_gpio_pin_set(PHY_MDIO);
    neorv32_gpio_pin_clr(PHY_MDC);
    neorv32_gpio_pin_set(PHY_MDC);
}

/**
 * @brief Sends a byte to the phy smi.
 * 
 * @param data 
 */
void phy_smi_send_addr(uint8_t data) {

    for (int i = 0; i < 5; i++) {

        // Set the data bit.
        if (data & (1 << (4 - i))) {
            neorv32_gpio_pin_set(PHY_MDIO);
        } else {
            neorv32_gpio_pin_clr(PHY_MDIO);
        }

        neorv32_gpio_pin_clr(PHY_MDC);
        neorv32_gpio_pin_set(PHY_MDC);

    }
}

/**
 * @brief Reads a byte from the phy smi.
 * 
 * @param data 
 * @param len 
 */
void phy_smi_read(uint16_t *data) {

    for (int j = 0; j < 16; j++) {

        neorv32_gpio_pin_set(PHY_MDC);
        data[0] |= ((!!neorv32_gpio_pin_get(PHY_MDIO)) << (15 - j));
        neorv32_gpio_pin_clr(PHY_MDC);
    }

    neorv32_gpio_pin_set(PHY_MDC);
    neorv32_gpio_pin_clr(PHY_MDC);
    
}

/**
 * @brief Writes a byte to the phy smi.
 * 
 * @param data 
 * @param len 
 */
void phy_smi_write(uint16_t *data) {

    for (int j = 0; j < 16; j++) {

        neorv32_gpio_pin_set(PHY_MDC);
        
        if (data[0] & (1 << (15 - j))) {
            neorv32_gpio_pin_set(PHY_MDIO);
        } else {
            neorv32_gpio_pin_clr(PHY_MDIO);
        }

        neorv32_gpio_pin_clr(PHY_MDC);
    }

    neorv32_gpio_pin_set(PHY_MDC);
    neorv32_gpio_pin_clr(PHY_MDC);
}

/**
 * @brief Reads a register from the phy. 
 * @note Bit banged interface.
 * 
 * @param phy_addr 
 * @param reg_addr 
 * @param data 
 * @return uint8_t 
 */
uint8_t phy_mdio_read(uint8_t phy_addr, uint8_t reg_addr, uint16_t *data) {

    neorv32_gpio_pin_set(PHY_MDC_MODE); 
    neorv32_gpio_pin_set(PHY_MDIO_MODE); 

    phy_smi_start();

    // Op code
    neorv32_gpio_pin_set(PHY_MDIO);
    neorv32_gpio_pin_clr(PHY_MDC);
    neorv32_gpio_pin_set(PHY_MDC);
    neorv32_gpio_pin_clr(PHY_MDIO);
    neorv32_gpio_pin_clr(PHY_MDC);
    neorv32_gpio_pin_set(PHY_MDC);

    // PHY address
    phy_smi_send_addr(phy_addr);

    // Register address
    phy_smi_send_addr(reg_addr);

    


    // Turn around
    neorv32_gpio_pin_clr(PHY_MDIO_MODE); 
    neorv32_gpio_pin_set(PHY_MDC);
    neorv32_gpio_pin_clr(PHY_MDC);
    neorv32_gpio_pin_set(PHY_MDC);
    neorv32_gpio_pin_clr(PHY_MDC);

    // Read data
    phy_smi_read(data);

    return 0x00;
}


/**
 * @brief Writes a register from the phy.
 * @note Bit banged interface.
 * 
 * @param phy_addr 
 * @param reg_addr 
 * @param data 
 * @return uint8_t 
 */
uint8_t phy_mdio_write(uint8_t phy_addr, uint8_t reg_addr, uint16_t *data) {

    // Set to output
    neorv32_gpio_pin_set(PHY_MDC_MODE); 
    neorv32_gpio_pin_set(PHY_MDIO_MODE); 

    phy_smi_start();

    // Op code
    neorv32_gpio_pin_clr(PHY_MDIO);
    neorv32_gpio_pin_clr(PHY_MDC);
    neorv32_gpio_pin_set(PHY_MDC);
    neorv32_gpio_pin_set(PHY_MDIO);
    neorv32_gpio_pin_clr(PHY_MDC);
    neorv32_gpio_pin_set(PHY_MDC);

    // PHY address
    phy_smi_send_addr(phy_addr);

    // Register address
    phy_smi_send_addr(reg_addr);

    


    // Turn around
    neorv32_gpio_pin_set(PHY_MDIO);
    neorv32_gpio_pin_set(PHY_MDC);
    neorv32_gpio_pin_clr(PHY_MDC);
    neorv32_gpio_pin_clr(PHY_MDIO);
    neorv32_gpio_pin_set(PHY_MDC);
    neorv32_gpio_pin_clr(PHY_MDC);

    // Read data
    phy_smi_write(data);

    return 0x00;
}
