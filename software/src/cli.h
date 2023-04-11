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

#include "ethernet.h"

#include <neorv32.h>
#include <stdio.h>
#include <string.h>

#define CLI_TASK_PRIORITY (tskIDLE_PRIORITY + 1)
#define CLI_STACK_SIZE (configMINIMAL_STACK_SIZE * 5)

void cli_init();

#endif