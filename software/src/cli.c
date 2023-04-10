/**
 * @file cli.c
 * @author Matthew Gilpin (matt@gilpin.au)
 * @brief CLI commands for the project
 * @version 0.1
 * @date 2023-04-10
 * 
 * @copyright Copyright (c) 2023
 * 
 */

#include "cli.h"

static BaseType_t cli_cmd_usage(char *pcWriteBuffer, size_t xWriteBufferLen, const char *pcCommandString);

CLI_Command_Definition_t xStill = {	
	"usage",							
	"usage:\r\n    Shows current number of tasks running and task states and stack high water-mark usage\r\n\r\n",
	cli_cmd_usage,
	0				
};


int usage_string_build(char *buffer, const char *name, eTaskState state, UBaseType_t stackUsage) {

    char stateString[10] = "Running";
    switch((int) state) {

        case 1:

            sprintf(stateString, "Ready");
            break;

        case 2:

            sprintf(stateString, "Blocked");
            break;

        case 3:
        
            sprintf(stateString, "Suspended");
            break;

        case 4:

            sprintf(stateString, "Deleted");
            break;

    }

    return sprintf(buffer + strlen(buffer), "== %s == State: %s, High Water-mark Stack Usage: %ld\r\n", name, stateString, stackUsage);
}


static BaseType_t cli_cmd_usage(char *pcWriteBuffer, size_t xWriteBufferLen, const char *pcCommandString) {

    int taskCount = uxTaskGetNumberOfTasks();

    sprintf(pcWriteBuffer, "Total running task count: %d\r\n", taskCount);
    TaskStatus_t *taskStates = pvPortMalloc(taskCount * sizeof(TaskStatus_t));

    UBaseType_t arraySize = uxTaskGetSystemState(taskStates, taskCount, NULL);

    for (int i = 0; i < arraySize; i++) {

        usage_string_build(pcWriteBuffer, taskStates[i].pcTaskName, taskStates[i].eCurrentState, taskStates[i].usStackHighWaterMark);
    }

    vPortFree(taskStates);

	/* Return pdFALSE, as there are no more strings to return */
	/* Only return pdTRUE, if more strings need to be printed */
	return pdFALSE;
}


void tsk_cli_daemon(void *pvParameters) {

    /* Register the command with the FreeRTOS+CLI command interpreter. */
    FreeRTOS_CLIRegisterCommand(&xStill);


	char cRxedChar;
	char cInputString[100];
	int InputIndex = 0;
	char *pcOutputString;
	BaseType_t xReturned;

	/* Initialise pointer to CLI output buffer. */
	memset(cInputString, 0, sizeof(cInputString));

	pcOutputString = FreeRTOS_CLIGetOutputBuffer();



    for (;;) {

        /* Receive character from terminal */
        cRxedChar = neorv32_uart0_getc();


        /* Process if character if not Null */
        if (cRxedChar != '\0') {

            /* Echo character */
            neorv32_uart0_putc(cRxedChar);

            /* Process only if return is received. */
            if (cRxedChar == '\r') {

                //Put new line and transmit buffer
                neorv32_uart0_putc('\n');
                // debug_flush();

                /* Put null character in command input string. */
                cInputString[InputIndex] = '\0';

                xReturned = pdTRUE;
                /* Process command input string. */
                while (xReturned != pdFALSE) {

                    /* Returns pdFALSE, when all strings have been returned */
                    xReturned = FreeRTOS_CLIProcessCommand( cInputString, pcOutputString, configCOMMAND_INT_MAX_OUTPUT_SIZE );

                    /* Display CLI command output string (not thread safe) */
                    portENTER_CRITICAL();
                    neorv32_uart0_printf("%s", pcOutputString);
                    portEXIT_CRITICAL();

                    vTaskDelay(5);
                }

                memset(cInputString, 0, sizeof(cInputString));
                InputIndex = 0;

            } else {

                // debug_flush();		//Transmit USB buffer

                if( cRxedChar == '\r' ) {

                    /* Ignore the character. */
                } else if( cRxedChar == '\b' ) {

                    /* Backspace was pressed.  Erase the last character in the
                    string - if any.*/
                    if( InputIndex > 0 ) {
                        InputIndex--;
                        cInputString[ InputIndex ] = '\0';
                    }

                } else {

                    /* A character was entered.  Add it to the string
                    entered so far.  When a \n is entered the complete
                    string will be passed to the command interpreter. */
                    if( InputIndex < 20 ) {
                        cInputString[ InputIndex ] = cRxedChar;
                        InputIndex++;
                    }
                }
            }
        }
        vTaskDelay(5);
    }
}

void cli_init() {
    neorv32_uart0_printf("Here: 0\n");

    xTaskCreate(tsk_cli_daemon, "CLIDAEMON", CLI_STACK_SIZE, NULL, CLI_TASK_PRIORITY, NULL);
}