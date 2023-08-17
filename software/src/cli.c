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
static BaseType_t cli_cmd_eth_phy_wr(char *pcWriteBuffer, size_t xWriteBufferLen, const char *pcCommandString);
static BaseType_t cli_cmd_gpio_ctrl(char *pcWriteBuffer, size_t xWriteBufferLen, const char *pcCommandString);
static BaseType_t cli_cmd_reset(char *pcWriteBuffer, size_t xWriteBufferLen, const char *pcCommandString);
static BaseType_t cli_cmd_eth(char *pcWriteBuffer, size_t xWriteBufferLen, const char *pcCommandString);
static BaseType_t cli_cmd_eth_recv(char *pcWriteBuffer, size_t xWriteBufferLen, const char *pcCommandString);
static BaseType_t cli_cmd_eth_recv_size(char *pcWriteBuffer, size_t xWriteBufferLen, const char *pcCommandString);
static BaseType_t cli_cmd_eth_cont(char *pcWriteBuffer, size_t xWriteBufferLen, const char *pcCommandString);
static BaseType_t cli_cmd_trng(char *pcWriteBuffer, size_t xWriteBufferLen, const char *pcCommandString);
static BaseType_t cli_cmd_ping(char *pcWriteBuffer, size_t xWriteBufferLen, const char *pcCommandString);
static BaseType_t cli_cmd_pingn(char *pcWriteBuffer, size_t xWriteBufferLen, const char *pcCommandString);
static BaseType_t cli_cmd_broadcast(char *pcWriteBuffer, size_t xWriteBufferLen, const char *pcCommandString);
static BaseType_t cli_cmd_sd_init(char *pcWriteBuffer, size_t xWriteBufferLen, const char *pcCommandString);
static BaseType_t cli_cmd_sd_read(char *pcWriteBuffer, size_t xWriteBufferLen, const char *pcCommandString);
static BaseType_t cli_cmd_sd_write(char *pcWriteBuffer, size_t xWriteBufferLen, const char *pcCommandString);
static BaseType_t cli_cmd_fat_read(char *pcWriteBuffer, size_t xWriteBufferLen, const char *pcCommandString);
static BaseType_t cli_packet_classifier_init(char *pcWriteBuffer, size_t xWriteBufferLen, const char *pcCommandString);

CLI_Command_Definition_t xPCInit = {	
	"pcinit",							
	"pcinit [wildcard]:\r\n    Initialise the packet classifier with a default rule\r\n\r\n",
	cli_packet_classifier_init,
	1				
};

CLI_Command_Definition_t xFATRead = {	
	"fatr",							
	"fatr:\r\n    Read a file called readme.txt and print the contents\r\n\r\n",
	cli_cmd_fat_read,
	0				
};

CLI_Command_Definition_t xSDWrite = {	
	"sdw",							
	"sdw [addr] [value]:\r\n    Write value to the first 2 bytes of the block starting at addr\r\n\r\n",
	cli_cmd_sd_write,
	2			
};

CLI_Command_Definition_t xSDRead = {	
	"sdr",							
	"sdr [addr]:\r\n    Read the first 8 bytes from block at addr\r\n\r\n",
	cli_cmd_sd_read,
	1				
};


CLI_Command_Definition_t xSDInit = {	
	"sdi",							
	"sdi:\r\n    Initialise SD card\r\n\r\n",
	cli_cmd_sd_init,
	0				
};


CLI_Command_Definition_t xBroadcast = {	
	"budp",							
	"budp:\r\n    Broadcast a UDP packet\r\n\r\n",
	cli_cmd_broadcast,
	0				
};

CLI_Command_Definition_t xPingn = {	
	"pingn",							
	"pingn [ip_addr] [num]:\r\n    Send ping to ipaddr, num many times\r\n\r\n",
	cli_cmd_pingn,
	2				
};


CLI_Command_Definition_t xPing = {	
	"ping",							
	"ping [ip_addr]:\r\n    Send ping to ipaddr\r\n\r\n",
	cli_cmd_ping,
	1				
};

CLI_Command_Definition_t xEthAck = {	
	"ethack",							
	"ethack:\r\n    Acknowledge ethernet interrupts\r\n\r\n",
	cli_cmd_eth,
	0				
};

CLI_Command_Definition_t xEthRecv = {	
	"ethrecv",							
	"ethrecv:\r\n    Shows contents of receive buffer\r\n\r\n",
	cli_cmd_eth_recv,
	0				
};

CLI_Command_Definition_t xEthRecvSize = {	
	"ethrs",							
	"ethrs [size]:\r\n    Shows contents of receive buffer, include size to fetch\r\n\r\n",
	cli_cmd_eth_recv_size,
	1				
};

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

CLI_Command_Definition_t xSendDemoContPacket = {	
	"democ",							
	"democ:\r\n    Send an ethernet packet. \r\n\r\n",
	cli_cmd_eth_cont,
	0				
};

CLI_Command_Definition_t xPhyControl = {	
	"phy",							
	"phy [command] [reg] [addr]:\r\n    Do some command to the phy - valid commands are.\r\n        phy read [reg] \r\n\r\n",
	cli_cmd_eth_phy,
	3				
};

CLI_Command_Definition_t xPhyControlWr = {	
	"phywr",							
	"phywr [reg] [value] [addr]:\r\n    Write some data to the phy over SMI/MDIO \r\n\r\n",
	cli_cmd_eth_phy_wr,
	3				
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

CLI_Command_Definition_t xTrng = {	
    "trng",							
    "trng [num]:\r\n    Return some random number. Select number of bytes\r\n        trng 2 \r\n\r\n",
    cli_cmd_trng,
    1				
};


/**
 * @brief Convert Hex char to int
 * 
 * @param c 
 * @return int 
 */
int hex_char_to_int(char c) {
    if (c >= '0' && c <= '9') {
        return c - '0';
    } else if (c >= 'a' && c <= 'f') {
        return c - 'a' + 10;
    } else if (c >= 'A' && c <= 'F') {
        return c - 'A' + 10;
    } else {
        return 0; // Invalid character, you may want to handle this case differently
    }
}


/**
 * @brief Convert a hex string to an integer
 * 
 * @param string 
 * @param length 
 * @return int 
 */
int hex_str_to_int(const char *string, int length) {
    int value = 0;

    for (int i = 0; i < length; i++) {
        value = value * 16 + hex_char_to_int(string[i]);
    }

    return value;
}

/**
 * @brief Convert a string to an integer
 * 
 * @param string 
 * @param length 
 * @return int 
 */
int str_to_int(const char *string, int length) {

    int value = 0;

    switch(length) {
        case 4:
            value += (string[0] - '0') * 1000;
            value += (string[1] - '0') * 100;
            value += (string[2] - '0') * 10;
            value += (string[3] - '0');
            break;
        case 3:
            value += (string[0] - '0') * 100;
            value += (string[1] - '0') * 10;
            value += (string[2] - '0');
            break;
        case 2:
            value += (string[0] - '0') * 10;
            value += (string[1] - '0');
            break;
        case 1:
        default:
            value += (string[0] - '0');
            break;
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
 * @brief CLI command to read FAT32 file called readme.txt in root directory.
 * 
 * @param pcWriteBuffer 
 * @param xWriteBufferLen 
 * @param pcCommandString 
 * @return BaseType_t 
 */
static BaseType_t cli_cmd_fat_read(char *pcWriteBuffer, size_t xWriteBufferLen, const char *pcCommandString) {

    uint32_t ucBuffer[ 64 ];
    uint8_t ucBuffer8[ 64 * 4];
    size_t xCount = 0;
    
    FF_Disk_t *disk = FF_SDDiskInit("/");

    FF_FILE *f = ff_fopen("/readme.txt", "r");

    if (f != NULL) {

        xCount = ff_fread(ucBuffer, 1, sizeof( ucBuffer ), f);
        ff_fclose(f);

        sprintf(pcWriteBuffer, "Read %d bytes from file\r\n\r\n", xCount);

        memcpy(ucBuffer8, ucBuffer, xCount);

        for (int i = 0; i < xCount; i++) 
            sprintf(pcWriteBuffer + strlen(pcWriteBuffer), "%c", ucBuffer8[i]);

    } else {
        // https://www.freertos.org/FreeRTOS-Plus/FreeRTOS_Plus_FAT/stdio_API/errno.html
        sprintf(pcWriteBuffer, "Failed to open file: %d\r\n", stdioGET_ERRNO());
    }


    

    return pdFALSE;

}


/**
 * @brief CLI command to init sd card
 * 
 * @param pcWriteBuffer 
 * @param xWriteBufferLen 
 * @param pcCommandString 
 * @return BaseType_t 
 */
static BaseType_t cli_cmd_sd_init(char *pcWriteBuffer, size_t xWriteBufferLen, const char *pcCommandString) {

    taskENTER_CRITICAL();


    uint8_t err = sd_init();

    sprintf(pcWriteBuffer, "Initialising SD card, r1 = %X\r\n", err);  

    taskEXIT_CRITICAL(); 

    return pdFALSE;

}

/**
 * @brief CLI command to read block from sd card
 * 
 * @param pcWriteBuffer 
 * @param xWriteBufferLen 
 * @param pcCommandString 
 * @return BaseType_t 
 */
static BaseType_t cli_cmd_sd_read(char *pcWriteBuffer, size_t xWriteBufferLen, const char *pcCommandString) {

    const char *pcSize;
    BaseType_t xSizeLen;

    pcSize = FreeRTOS_CLIGetParameter(pcCommandString, 1, &xSizeLen);

    uint32_t addr = 0x0000FFFF & (uint32_t)str_to_int(pcSize, xSizeLen);
    
    uint8_t buff[512];
    uint8_t token;
    
    taskENTER_CRITICAL();
    uint8_t err = sd_read_block(addr, buff, &token);
    taskEXIT_CRITICAL(); 

    sprintf(pcWriteBuffer, "Reading from SD card, addr: %d, token: %x, res: %x\r\n", addr, token, err);  
    sprintf(pcWriteBuffer + strlen(pcWriteBuffer), "%x %x %x %x %x %x %x %x\r\n", buff[0], buff[1], buff[2], buff[3], buff[4], buff[5], buff[6], buff[7]);  

    return pdFALSE;

}

/**
 * @brief CLI command to write a block to the sd card
 * 
 * @param pcWriteBuffer 
 * @param xWriteBufferLen 
 * @param pcCommandString 
 * @return BaseType_t 
 */
static BaseType_t cli_cmd_sd_write(char *pcWriteBuffer, size_t xWriteBufferLen, const char *pcCommandString) {

    const char *pcAddr, *pcData;
    BaseType_t xAddrLen, xDataLen;

    pcAddr = FreeRTOS_CLIGetParameter(pcCommandString, 1, &xAddrLen);
    pcData = FreeRTOS_CLIGetParameter(pcCommandString, 2, &xDataLen);

    uint32_t addr = 0x0000FFFF & (uint32_t)str_to_int(pcAddr, xAddrLen);
    uint16_t data = str_to_int(pcData, xDataLen);
    
    uint8_t buff[512];
    uint8_t token;
    
    taskENTER_CRITICAL();
    uint8_t err = sd_read_block(addr, buff, &token);

    buff[0] = data & 0xFF;
    buff[1] = (data >> 8) & 0xFF;

    err = sd_write_block(addr, buff, &token);
    taskEXIT_CRITICAL(); 

    sprintf(pcWriteBuffer, "Reading from SD card, addr: %d, token: %x, res: %x\r\n", addr, token, err);  
    sprintf(pcWriteBuffer + strlen(pcWriteBuffer), "%x %x %x %x %x %x %x %x\r\n", buff[0], buff[1], buff[2], buff[3], buff[4], buff[5], buff[6], buff[7]);  

    return pdFALSE;

}




/**
 * @brief CLI command to send a broadcast udp packet
 * 
 * @param pcWriteBuffer 
 * @param xWriteBufferLen 
 * @param pcCommandString 
 * @return BaseType_t 
 */
static BaseType_t cli_cmd_broadcast(char *pcWriteBuffer, size_t xWriteBufferLen, const char *pcCommandString) {

    Socket_t xSocket;
    struct freertos_sockaddr xDestinationAddress;
    uint8_t cString[ 50 ];
    uint32_t ulCount = 0UL;
    const TickType_t x1000ms = 1000UL / portTICK_PERIOD_MS;

    /* Send strings to port 10000 on IP address 192.168.0.50. */
    xDestinationAddress.sin_address.ulIP_IPv4 = FreeRTOS_inet_addr( "255.255.255.255" );
    xDestinationAddress.sin_port = FreeRTOS_htons( 10000 );

    /* Create the socket. */
    xSocket = FreeRTOS_socket( FREERTOS_AF_INET,
                                FREERTOS_SOCK_DGRAM,/*FREERTOS_SOCK_DGRAM for UDP.*/
                                FREERTOS_IPPROTO_UDP );


    /* Create the string that is sent. */
    sprintf( cString,
            "Standard send message number %lurn",
            ulCount );

    /* Send the string to the UDP socket.  ulFlags is set to 0, so the standard
    semantics are used.  That means the data from cString[] is copied
    into a network buffer inside FreeRTOS_sendto(), and cString[] can be
    reused as soon as FreeRTOS_sendto() has returned. */
    FreeRTOS_sendto( xSocket,
                    cString,
                    strlen( cString ),
                    0,
                    &xDestinationAddress,
                    sizeof( xDestinationAddress ) );

    sprintf(pcWriteBuffer, "Sent packet\r\n");   

    return pdFALSE;

}


/**
 * @brief Send a ping packet 
 * 
 * @param pcWriteBuffer 
 * @param xWriteBufferLen 
 * @param pcCommandString 
 * @return BaseType_t 
 */
static BaseType_t cli_cmd_ping(char *pcWriteBuffer, size_t xWriteBufferLen, const char *pcCommandString) {

    const char *pcIPAddr;
    char pcAddr[16];
    BaseType_t xIPAddrLen;

    // Obtain the first parameter string.
    pcIPAddr = FreeRTOS_CLIGetParameter(pcCommandString, 1, &xIPAddrLen);
    memcpy(pcAddr, pcIPAddr, xIPAddrLen);

    taskENTER_CRITICAL();
    
    uint16_t usRequestSequenceNumber, usReplySequenceNumber;
    uint32_t ulIPAddress;

    /* The pcIPAddress parameter holds the destination IP address as a string in
    decimal dot notation (for example, "192.168.0.200").  Convert the string into
    the required 32-bit format. */
    ulIPAddress = FreeRTOS_inet_addr( "10.20.1.19" );

    /* Send a ping containing 8 data bytes.  Wait (in the Blocked state) a
    maximum of 100ms for a network buffer into which the generated ping request
    can be written and sent. */
    usRequestSequenceNumber = FreeRTOS_SendPingRequest( ulIPAddress, 8, 100 / portTICK_PERIOD_MS );

    if( usRequestSequenceNumber == pdFAIL )
    {
        /* The ping could not be sent because a network buffer could not be
        obtained within 100ms of FreeRTOS_SendPingRequest() being called. */
        sprintf(pcWriteBuffer, "Buffer could not be obtained within 100ms\r\n");

    }
    else
    {
        
        sprintf(pcWriteBuffer, "Sent\r\n");   
    }   


    taskEXIT_CRITICAL();

  
    return pdFALSE;
}


/**
 * @brief Send a ping packet 
 * 
 * @param pcWriteBuffer 
 * @param xWriteBufferLen 
 * @param pcCommandString 
 * @return BaseType_t 
 */
static BaseType_t cli_cmd_pingn(char *pcWriteBuffer, size_t xWriteBufferLen, const char *pcCommandString) {

    const char *pcIPAddr, *pcSize;
    char pcAddr[16];
    BaseType_t xIPAddrLen, xSizeLen;

    // Obtain the first parameter string.
    pcIPAddr = FreeRTOS_CLIGetParameter(pcCommandString, 1, &xIPAddrLen);
    memcpy(pcAddr, pcIPAddr, xIPAddrLen);

    pcSize = FreeRTOS_CLIGetParameter(pcCommandString, 2, &xSizeLen);

    uint16_t size = str_to_int(pcSize, xSizeLen);
    
    uint16_t usRequestSequenceNumber, usReplySequenceNumber;
    uint32_t ulIPAddress;

    /* The pcIPAddress parameter holds the destination IP address as a string in
    decimal dot notation (for example, "192.168.0.200").  Convert the string into
    the required 32-bit format. */
    ulIPAddress = FreeRTOS_inet_addr( pcAddr );

    /* Send a ping containing 8 data bytes.  Wait (in the Blocked state) a
    maximum of 100ms for a network buffer into which the generated ping request
    can be written and sent. */

    for (int i = 0; i < size; i++) {
        usRequestSequenceNumber = FreeRTOS_SendPingRequest( ulIPAddress, 8, 100 / portTICK_PERIOD_MS );

        if( usRequestSequenceNumber == pdFAIL )
        {
            /* The ping could not be sent because a network buffer could not be
            obtained within 100ms of FreeRTOS_SendPingRequest() being called. */
            sprintf(pcWriteBuffer, "Buffer could not be obtained within 100ms\r\n");

        }
        else
        {
            
            sprintf(pcWriteBuffer, "Sent\r\n");   
        }   
    }
    
  
    return pdFALSE;
}




/**
 * @brief CLI command to print out the usage of the system
 * 
 * @param pcWriteBuffer 
 * @param xWriteBufferLen 
 * @param pcCommandString 
 * @return BaseType_t 
 */
static BaseType_t cli_cmd_trng(char *pcWriteBuffer, size_t xWriteBufferLen, const char *pcCommandString) {
    
    // Check to see if the first parameter is "reset"
    const char *pcNum;
    BaseType_t xNumLen;
    uint8_t num;

    uint8_t trng_data = 0;

    sprintf(pcWriteBuffer, "");

    // Obtain the first parameter string.
    pcNum = FreeRTOS_CLIGetParameter(pcCommandString, 1, &xNumLen);

    num = str_to_int(pcNum, xNumLen);

    // enter critical section
    taskENTER_CRITICAL();

    for (int i = 0; i < num; i++) {
        neorv32_trng_get(&trng_data);
        sprintf(pcWriteBuffer + strlen(pcWriteBuffer), "%02x ", trng_data);
    }

    taskEXIT_CRITICAL();

    sprintf(pcWriteBuffer + strlen(pcWriteBuffer), "\r\n");
  
    return pdFALSE;
}



/**
 * @brief CLI command to receive eth stuff.
 * 
 * @param pcWriteBuffer 
 * @param xWriteBufferLen 
 * @param pcCommandString 
 * @return BaseType_t 
 */
static BaseType_t cli_cmd_eth_recv(char *pcWriteBuffer, size_t xWriteBufferLen, const char *pcCommandString) {

   
    sprintf(pcWriteBuffer, "Receive from ethernet\r\n");
    
    taskENTER_CRITICAL();
    
    size_t xBytesReceived = eth_recv_size();

    if (xBytesReceived > 0) {
        uint8_t *buff = pvPortMalloc(1000 * sizeof(uint8_t));
        char *strOut = pvPortMalloc(200 * sizeof(char));

        eth_recv(buff, xBytesReceived);

        for (int i = 0; i < xBytesReceived; i += 8) {
            sprintf(strOut, "%02x %02x %02x %02x %02x %02x %02x %02x\n", buff[i], buff[i+ 1], buff[i+2], buff[i+3], buff[i+4], buff[i+5], buff[i+6], buff[i+7]);
            neorv32_uart0_printf(strOut);
        }
       
        
        vPortFree(strOut);
        vPortFree(buff);

    }

    taskEXIT_CRITICAL();

	/* Return pdFALSE, as there are no more strings to return */
	/* Only return pdTRUE, if more strings need to be printed */
	return pdFALSE;
}

/**
 * @brief CLI command to receive eth stuff.
 * 
 * @param pcWriteBuffer 
 * @param xWriteBufferLen 
 * @param pcCommandString 
 * @return BaseType_t 
 */
static BaseType_t cli_cmd_eth_recv_size(char *pcWriteBuffer, size_t xWriteBufferLen, const char *pcCommandString) {

   
    sprintf(pcWriteBuffer, "Receive from ethernet\r\n");
    const char *pcSize;
    BaseType_t xSizeLen;
    uint16_t data = 0;
    

    // Obtain the first parameter string.
    pcSize = FreeRTOS_CLIGetParameter(pcCommandString, 1, &xSizeLen);

    uint16_t size = str_to_int(pcSize, xSizeLen);

    
    taskENTER_CRITICAL();

    uint8_t *buff = pvPortMalloc(1000 * sizeof(uint8_t));
    char *strOut = pvPortMalloc(200 * sizeof(char));

    eth_recv_raw_size(buff, size);

    for (int i = 0; i < size; i += 8) {
        sprintf(strOut, "%02x %02x %02x %02x %02x %02x %02x %02x\n", buff[i+3], buff[i+2], buff[i+ 1], buff[i], buff[i+7], buff[i+6], buff[i+5], buff[i+4]);
        neorv32_uart0_printf(strOut);
    }
    
    
    vPortFree(strOut);
    vPortFree(buff);

    

    taskEXIT_CRITICAL();

	/* Return pdFALSE, as there are no more strings to return */
	/* Only return pdTRUE, if more strings need to be printed */
	return pdFALSE;
}



/**
 * @brief CLI command to control eth stuff.
 * 
 * @param pcWriteBuffer 
 * @param xWriteBufferLen 
 * @param pcCommandString 
 * @return BaseType_t 
 */
static BaseType_t cli_cmd_eth(char *pcWriteBuffer, size_t xWriteBufferLen, const char *pcCommandString) {

   
    sprintf(pcWriteBuffer, "Ack IQR for ethernet\r\n");
    
    taskENTER_CRITICAL();
    
    eth_ack_irq();

    taskEXIT_CRITICAL();

	/* Return pdFALSE, as there are no more strings to return */
	/* Only return pdTRUE, if more strings need to be printed */
	return pdFALSE;
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

    sprintf(pcWriteBuffer, "Executed task: %ld\r\n", ETH_MAC_TX->DATA[1]);
    
    taskENTER_CRITICAL();
    
    eth_send_demo();

    taskEXIT_CRITICAL();

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
static BaseType_t cli_cmd_eth_cont(char *pcWriteBuffer, size_t xWriteBufferLen, const char *pcCommandString) {

    sprintf(pcWriteBuffer, "Sending 10000 packets\r\n");
    
    taskENTER_CRITICAL();
   
    eth_send_demo();
    for (int i = 0; i < 10000; i++) {
        ETH_MAC_CMD = ETH_MAC_CMD_START_TX;

        // Need to set the idle state. Otherwise packet gets sent again.
        ETH_MAC_CMD = ETH_MAC_CMD_IDLE;
    }
    
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
    const char *pcCmd, *pcData, *pcAddr;
    BaseType_t xCmdLen, xDataLen, xAddrLen;
    uint16_t data = 0;
    uint8_t registerNum, phyAddr;

    // Obtain the first parameter string.
    pcCmd = FreeRTOS_CLIGetParameter(pcCommandString, 1, &xCmdLen);
    pcData = FreeRTOS_CLIGetParameter(pcCommandString, 2, &xDataLen);
    pcAddr = FreeRTOS_CLIGetParameter(pcCommandString, 3, &xAddrLen);

    registerNum = str_to_int(pcData, xDataLen);
    phyAddr = str_to_int(pcAddr, xAddrLen);


    if (strncmp(pcCmd, "read", xCmdLen) == 0) {


        // enter critical section
        taskENTER_CRITICAL();
        phy_mdio_read(phyAddr, registerNum, &data);
        taskEXIT_CRITICAL();

        sprintf(pcWriteBuffer, "Phy Addr: %d, Register %d = 0x%X\r\n", phyAddr, registerNum, data);

    } else if (strncmp(pcCmd, "write", xCmdLen) == 0) { 
        registerNum = str_to_int(pcData, xDataLen);

        // enter critical section
        taskENTER_CRITICAL();
        phy_mdio_write(phyAddr, registerNum, &data);
        taskEXIT_CRITICAL();
        sprintf(pcWriteBuffer, "Phy Addr: %d, Register %d => 0x%X\r\n", phyAddr, registerNum, data);

    } else {    
        sprintf(pcWriteBuffer, "Unknown command\r\n");
    }
    
  
    return pdFALSE;
}

/**
 * @brief CLI command to control/write the phy .
 * 
 * @param pcWriteBuffer 
 * @param xWriteBufferLen 
 * @param pcCommandString 
 * @return BaseType_t 
 */
static BaseType_t cli_cmd_eth_phy_wr(char *pcWriteBuffer, size_t xWriteBufferLen, const char *pcCommandString) {

    // Check to see if the first parameter is "reset"
    const char *pcCmd, *pcReg, *pcVal, *pcAddr;
    BaseType_t xCmdLen, xRegLen, xValLen, xAddrLen;
    uint16_t data = 0;
    uint8_t registerNum, phyAddr;

    // Obtain the first parameter string.
    pcReg = FreeRTOS_CLIGetParameter(pcCommandString, 1, &xRegLen);
    pcVal = FreeRTOS_CLIGetParameter(pcCommandString, 2, &xValLen);
    pcAddr = FreeRTOS_CLIGetParameter(pcCommandString, 3, &xAddrLen);
    
    registerNum = hex_str_to_int(pcReg, xRegLen);
    data = hex_str_to_int(pcVal, xValLen);
    phyAddr = str_to_int(pcAddr, xAddrLen);

    // enter critical section
    taskENTER_CRITICAL();
    phy_mdio_write(phyAddr, registerNum, &data);
    taskEXIT_CRITICAL();
    sprintf(pcWriteBuffer, "Phy Addr: %d, Register %d => 0x%X\r\n", phyAddr, registerNum, data);
    
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

    } else if (strncmp(pcCmd, "output", cmdLen) == 0) {

        sprintf(pcWriteBuffer, "Pin %d is set to output\r\n", pin);
        neorv32_gpio_pin_set(pin + 32);

    } else if (strncmp(pcCmd, "input", cmdLen) == 0) {

        sprintf(pcWriteBuffer, "Pin %d is set to input\r\n", pin);
        neorv32_gpio_pin_clr(pin + 32);

    } else {
        sprintf(pcWriteBuffer, "Unknown command\r\n");
    }
    
  
    return pdFALSE;
}


static BaseType_t cli_packet_classifier_init(char *pcWriteBuffer, size_t xWriteBufferLen, const char *pcCommandString) {

    taskENTER_CRITICAL();

    const char *pcCmd;
    BaseType_t xCmdLen;
    uint16_t data = 0;
    uint8_t registerNum, phyAddr;

    // Obtain the first parameter string.
    pcCmd = FreeRTOS_CLIGetParameter(pcCommandString, 1, &xCmdLen);
 

    registerNum = str_to_int(pcCmd, xCmdLen);

    pc_init();

    uint8_t wildcard = registerNum;
    uint8_t destIP[4] = {10, 20, 1, 120};
    uint8_t sourceIP[4] = {10, 0, 0, 159};
    uint16_t destPort = 80;
    uint16_t sourcePort = 80;
    uint8_t protocol = 0x06;

    sprintf(pcWriteBuffer, "Writing rule to packet classifier\r\n");  
    pc_save_rule(0, wildcard, destIP, sourceIP, destPort, sourcePort, protocol);


    taskEXIT_CRITICAL(); 

    return pdFALSE;

}




void tsk_cli_daemon(void *pvParameters) {

    /* Register the command with the FreeRTOS+CLI command interpreter. */
    FreeRTOS_CLIRegisterCommand(&xUsage);
    FreeRTOS_CLIRegisterCommand(&xSendDemoPacket);
    FreeRTOS_CLIRegisterCommand(&xPhyControl);
    FreeRTOS_CLIRegisterCommand(&xPhyControlWr);
    FreeRTOS_CLIRegisterCommand(&xGpioControl);
    FreeRTOS_CLIRegisterCommand(&xReset);
    FreeRTOS_CLIRegisterCommand(&xEthAck);
    FreeRTOS_CLIRegisterCommand(&xEthRecv);
    FreeRTOS_CLIRegisterCommand(&xEthRecvSize);
    FreeRTOS_CLIRegisterCommand(&xSendDemoContPacket);
    FreeRTOS_CLIRegisterCommand(&xTrng);
    FreeRTOS_CLIRegisterCommand(&xPing);
    FreeRTOS_CLIRegisterCommand(&xPingn);
    FreeRTOS_CLIRegisterCommand(&xBroadcast);
    FreeRTOS_CLIRegisterCommand(&xSDInit);
    FreeRTOS_CLIRegisterCommand(&xSDRead);
    FreeRTOS_CLIRegisterCommand(&xSDWrite);
    FreeRTOS_CLIRegisterCommand(&xFATRead);
    FreeRTOS_CLIRegisterCommand(&xPCInit);
    
    
    

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
