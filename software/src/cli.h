/**
 * @file cli.h
 * @author Matthew Gilpin (matt@gilpin.au)
 * @brief CLI commands for the system
 * @version 0.1
 * @date 2023-04-10
 * 
 * @copyright Copyright (c) 2023
 * 
 */
#ifndef CLI_H
#define CLI_H

#include "FreeRTOS.h"
#include "task.h"
#include "queue.h"
#include "event_groups.h"
#include "semphr.h"
#include "FreeRTOS_CLI.h"
#include "FreeRTOS_IP.h"
#include "FreeRTOS_Sockets.h"

#include "ethernet.h"
#include "sd.h"
#include "packet_classifier.h"
#include "common.h"

#include <neorv32.h>
#include <stdio.h>
#include <string.h>

#include "ff_stdio.h"

#define CLI_TASK_PRIORITY (tskIDLE_PRIORITY + 1)
#define CLI_STACK_SIZE (configMINIMAL_STACK_SIZE * 5)

void cli_init();

#endif