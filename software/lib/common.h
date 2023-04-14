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

#endif