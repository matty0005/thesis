/**
 * @file project.c
 * @author Matthew Gilpin (matt@gilpin.au)
 * @brief Stores the core functionality of the project.
 * @version 0.1
 * @date 2023-04-06
 * 
 * @copyright Copyright (c) 2023
 * 
 */

/* Standard includes. */
#include <stdio.h>
#include <string.h>
#include <unistd.h>

/* Kernel includes. */
#include "FreeRTOS.h"
#include "task.h"
#include "queue.h"


#include "ethernet.h"

/* Priorities used by the tasks. */
#define ETH_TASK_PRIORITY ( tskIDLE_PRIORITY + 1 )
#define ETH_STACK_SIZE ( configMINIMAL_STACK_SIZE * 5 )

/**
 * @brief Creates a task that controls the ethernet mac.
 * 
 */
void task_ethernet_daemon(void *pvParameters) {

    for(;;) {
        
        // init the ethernet mac.
        ETH_MAC_CMD = ETH_MAC_CMD_INIT;

        

        vTaskDelay(1000);
    }
}


void main_project( void )
{

    xTaskCreate(task_ethernet_daemon, "ETHERNETDAEMON", ETH_STACK_SIZE, NULL, ETH_TASK_PRIORITY, NULL );


    /* Start the tasks and timer running. */
    vTaskStartScheduler();
}

