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

#include <neorv32.h>

#include "ethernet.h"
#include "cli.h"

/* Priorities used by the tasks. */
#define ETH_TASK_PRIORITY ( tskIDLE_PRIORITY + 1 )
#define ETH_STACK_SIZE ( configMINIMAL_STACK_SIZE * 5 )

/**
 * @brief Creates a task that controls the ethernet mac.
 * 
 */
void tsk_ethernet(void *pvParameters) {

    for(;;) {
        
        // Enter critical section to prevent the ethernet mac from being used by another task.
        taskENTER_CRITICAL();

        eth_send_demo()

        // Exit critical section.
        taskEXIT_CRITICAL();

        vTaskDelay(1000);
    }
}


/**
* @brief Creates the tasks and starts the scheduler.
*/  
void main_project( void ) {
    
    cli_init();
    // xTaskCreate(tsk_ethernet, "ETHERNETDAEMON", ETH_STACK_SIZE, NULL, ETH_TASK_PRIORITY, NULL );

}

