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
static BaseType_t cli_cmd_eth_demo(char *pcWriteBuffer, size_t xWriteBufferLen, const char *pcCommandString);
static BaseType_t cli_cmd_eth_phy(char *pcWriteBuffer, size_t xWriteBufferLen, const char *pcCommandString);
static BaseType_t cli_cmd_gpio_ctrl(char *pcWriteBuffer, size_t xWriteBufferLen, const char *pcCommandString);
static BaseType_t cli_cmd_reset(char *pcWriteBuffer, size_t xWriteBufferLen, const char *pcCommandString);

CLI_Command_Definition_t xUsage = {	
	"usage",							
	"usage:\r\n    Shows current number of tasks running and task states and stack high water-mark usage\r\n\r\n",
	cli_cmd_usage,
	0				
};

CLI_Command_Definition_t xSendDemoPacket = {	
	"demo",							
	"demo:\r\n    Send an ethernet packet. \r\n\r\n",
	cli_cmd_eth_demo,
	0				
};

CLI_Command_Definition_t xPhyControl = {	
	"phy",							
	"phy [command] [reg]:\r\n    Do some command to the phy - valid commands are.\r\n        phy read [reg] \r\n\r\n",
	cli_cmd_eth_phy,
	2				
};

CLI_Command_Definition_t xReset = {	
	"reset",							
	"reset [device]:\r\n    Reset some device or mechinism - valid commands are.\r\n        reset phy \r\n\r\n",
	cli_cmd_reset,
	1				
};


CLI_Command_Definition_t xGpioControl = {	
    "gpio",							
    "gpio [command] [pin]:\r\n    Do some command to the gpio - valid commands are.\r\n        gpio set [pin]\r\n        gpio reset [pin]\r\n        gpio get [pin] \r\n\r\n",
    cli_cmd_gpio_ctrl,
    2				
};


/**
 * @brief Convert a string to an integer
 * 
 * @param string 
 * @param length 
 * @return int 
 */
int str_to_int(const char *string, int length) {

    int value = 0;

    if (length == 2) {
        value += (string[0] - '0') * 10;
        value += (string[1] - '0');
    } else {
        value += (string[0] - '0');

    }
    
    return value;
}


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


/**
 * @brief CLI command to show the current usage of the system.
 * 
 * @param pcWriteBuffer 
 * @param xWriteBufferLen 
 * @param pcCommandString 
 * @return BaseType_t 
 */
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



/**
 * @brief CLI command to send a packet.
 * 
 * @param pcWriteBuffer 
 * @param xWriteBufferLen 
 * @param pcCommandString 
 * @return BaseType_t 
 */
static BaseType_t cli_cmd_eth_demo(char *pcWriteBuffer, size_t xWriteBufferLen, const char *pcCommandString) {

    sprintf(pcWriteBuffer, "Executed task: %ld\r\n", ETH_MAC->DATA[1]);
    
    taskENTER_CRITICAL();
    
    eth_send_demo();

    taskEXIT_CRITICAL();

	return pdFALSE;

}

/**
 * @brief CLI command to control the phy.
 * 
 * @param pcWriteBuffer 
 * @param xWriteBufferLen 
 * @param pcCommandString 
 * @return BaseType_t 
 */
static BaseType_t cli_cmd_eth_phy(char *pcWriteBuffer, size_t xWriteBufferLen, const char *pcCommandString) {

    // Check to see if the first parameter is "reset"
    const char *pcCmd, *pcData;
    BaseType_t xCmdLen, xDataLen;
    uint16_t data = 0;
    uint8_t registerNum;

    // Obtain the first parameter string.
    pcCmd = FreeRTOS_CLIGetParameter(pcCommandString, 1, &xCmdLen);
    pcData = FreeRTOS_CLIGetParameter(pcCommandString, 2, &xDataLen);

    if (strncmp(pcCmd, "read", xCmdLen) == 0) {

        registerNum = str_to_int(pcData, xDataLen);

        // enter critical section
        taskENTER_CRITICAL();
        phy_mdio_read(0x01, registerNum, &data);
        taskEXIT_CRITICAL();

        sprintf(pcWriteBuffer, "Phy Register %d = 0x%X\r\n", registerNum, data);

    } else if (strncmp(pcCmd, "write", xCmdLen) == 0) { 
        registerNum = str_to_int(pcData, xDataLen);

        // enter critical section
        taskENTER_CRITICAL();
        phy_mdio_write(0x01, registerNum, &data);
        taskEXIT_CRITICAL();
        sprintf(pcWriteBuffer, "Phy Register %d => 0x%X\r\n", registerNum, data);

    } else {    
        sprintf(pcWriteBuffer, "Unknown command\r\n");
    }
    
  
    return pdFALSE;
}

/**
 * @brief CLI command to reset hardware
 * 
 * @param pcWriteBuffer 
 * @param xWriteBufferLen 
 * @param pcCommandString 
 * @return BaseType_t 
 */
static BaseType_t cli_cmd_reset(char *pcWriteBuffer, size_t xWriteBufferLen, const char *pcCommandString) {
    // Check to see if the first parameter is "reset"
    const char *pcParameter;
    BaseType_t xParameterStringLength;

    // Obtain the first parameter string.
    pcParameter = FreeRTOS_CLIGetParameter(pcCommandString, 1, &xParameterStringLength);

    if (strncmp(pcParameter, "phy", xParameterStringLength) == 0) {

        sprintf(pcWriteBuffer, "Resetting the PHY chip\r\n");
    
        ETH_CTRL = ETH_CTRL_RESET;

    } else {    
        sprintf(pcWriteBuffer, "Unknown command\r\n");
    }

    return pdFALSE;
}

/**
 * @brief CLI command to control the gpio.
 * 
 * @param pcWriteBuffer 
 * @param xWriteBufferLen 
 * @param pcCommandString 
 * @return BaseType_t 
 */
static BaseType_t cli_cmd_gpio_ctrl(char *pcWriteBuffer, size_t xWriteBufferLen, const char *pcCommandString) {

    // Check to see if the first parameter is "reset"
    const char *pcCmd;
    const char *pcPin;
    BaseType_t cmdLen, pinLen;

    // Obtain the first parameter string.
    pcCmd = FreeRTOS_CLIGetParameter(pcCommandString, 1, &cmdLen);
    pcPin = FreeRTOS_CLIGetParameter(pcCommandString, 2, &pinLen);
    
    int pin = str_to_int(pcPin, pinLen);

    if (strncmp(pcCmd, "set", cmdLen) == 0) {
            
        sprintf(pcWriteBuffer, "Set pin %d\r\n", pin);
        neorv32_gpio_pin_set(pin);      

    } else if (strncmp(pcCmd, "reset", cmdLen) == 0 || strncmp(pcCmd, "clear", cmdLen) == 0) {

        sprintf(pcWriteBuffer, "Reseting pin %d\r\n", pin);
        neorv32_gpio_pin_clr(pin);

    } else if (strncmp(pcCmd, "get", cmdLen) == 0) {

        sprintf(pcWriteBuffer, "Pin %d is %d\r\n", pin, !!neorv32_gpio_pin_get(pin));

    } else {
        sprintf(pcWriteBuffer, "Unknown command\r\n");
    }
    
  
    return pdFALSE;
}


void tsk_cli_daemon(void *pvParameters) {

    /* Register the command with the FreeRTOS+CLI command interpreter. */
    FreeRTOS_CLIRegisterCommand(&xUsage);
    FreeRTOS_CLIRegisterCommand(&xSendDemoPacket);
    FreeRTOS_CLIRegisterCommand(&xPhyControl);
    FreeRTOS_CLIRegisterCommand(&xGpioControl);
    FreeRTOS_CLIRegisterCommand(&xReset);


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

    xTaskCreate(tsk_cli_daemon, "CLIDAEMON", CLI_STACK_SIZE, NULL, CLI_TASK_PRIORITY, NULL);
}
