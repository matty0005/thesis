/**
 * @file packet_classifier.h
 * @author Matthew Gilpin (matt@gilpin.au)
 * @brief 
 * @version 0.1
 * @date 2023-08-11
 * 
 * @copyright Copyright (c) 2023
 * 
 */

#ifndef PACKET_CLASSIFIER_H
#define PACKET_CLASSIFIER_H

#include <stdint.h>
#include "neorv32.h"

#define PC_SPI_CHANNEL 1

/**
 * @brief Initialise the packet classifier.
 * 
 */
void pc_init();

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
void pc_save_rule(uint8_t address, uint8_t wildcard, uint8_t *destIP, uint8_t *srcIP, uint16_t destPort, uint16_t srcPort, uint8_t protocol);

#endif
