/**
 * @file common.h
 * @author Matt Gilpin (matt@gilpin.au)
 * @brief Contains common handles and definitions
 * @version 0.1
 * @date 2023-04-15
 * 
 * @copyright Copyright (c) 2023
 * 
 */

#ifndef COMMON_H
#define COMMON_H

#include "FreeRTOS.h"
#include "task.h"
#include "queue.h"
#include "semphr.h"

extern TaskHandle_t xEMACTaskHandle;

/**
 * @brief Convert Hex char to int
 * 
 * @param c 
 * @return int 
 */
int hex_char_to_int(char c);

/**
 * @brief Convert Hex byte to int
 * 
 * @param c 
 * @return int 
 */
int hex_byte_to_int(char c[2]);


/**
 * @brief Convert a hex string to an integer
 * 
 * @param string 
 * @param length 
 * @return int 
 */
int hex_str_to_int(const char *string, int length);

/**
 * @brief Convert a string to an integer
 * 
 * @param string 
 * @param length 
 * @return int 
 */
int str_to_int(const char *string, int length);


#endif