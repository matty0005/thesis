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

#include "ff_stdio.h"

#define PACKET_FILTER_RULE_FILE_SIZE 300

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

/**
 * @brief Get the rules from the packet classifier
 * 
 * @param buffer: make sure it is sufficiently large >= 240. 
 * @param bufferSize: size of buffer
 * @param size: size of data read.
 * @return int: 0 if no error, 1 if error
 */
int pc_get_rules(uint8_t *buffer, uint32_t bufferSize, uint32_t *size);

#endif
