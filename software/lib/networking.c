/**
 * @file networking.c
 * @author Matthew Gilpin (matt@gilpin.au)
 * @brief 
 * @version 0.1
 * @date 2023-05-13
 * 
 * @copyright Copyright (c) 2023
 * 
 */
#include "networking.h"

#define UDP_STACK_SIZE ( configMINIMAL_STACK_SIZE * 5 )
#define UDP_PRIORITY ( tskIDLE_PRIORITY + 1 )

/* Constants */
static uint8_t ucMACAddress[ 6 ] = { 0x00, 0x11, 0x22, 0x33, 0x44, 0x55 };
static const uint8_t ucIPAddress[ 4 ] = { 10, 20, 1, 120 };
static const uint8_t ucNetMask[ 4 ] = { 255, 255, 255, 0 };
static const uint8_t ucGatewayAddress[ 4 ] = { 10, 20, 1, 1 };
static const uint8_t ucDNSServerAddress[ 4 ] = { 1, 1, 1, 1 };

/* Function prototypes*/
static void tsk_udp_receive( void *pvParameters );


void start_networking() {
    /* Initialise the RTOS's TCP/IP stack.  The tasks that use the network
    are created in the vApplicationIPNetworkEventHook() hook function
    below.  The hook function is called when the network connects. */
    FreeRTOS_IPInit( ucIPAddress,
                    ucNetMask,
                    ucGatewayAddress,
                    ucDNSServerAddress,
                    ucMACAddress );

    xTaskCreate(tsk_udp_receive, "UDP RX", UDP_STACK_SIZE, NULL, UDP_PRIORITY, NULL);
}


static void print_packet(uint8_t *data, size_t len) {

    uint8_t buff[2] = {0x00, 0x00};
    for (int i = 0; i < len; i++) {
        sprintf(buff, "%02x", data[i]);
        neorv32_uart0_printf(buff);
    }
    neorv32_uart0_printf("\n");
}

/**
 * @brief FreeRTOS task to receive UDP data
 * 
 * @param pvParameters 
 */
static void tsk_udp_receive( void *pvParameters ) {
    long lBytes;
    uint8_t cReceivedString[ 60 ];
    struct freertos_sockaddr xClient, xBindAddress;
    uint32_t xClientLength = sizeof( xClient );
    Socket_t xListeningSocket;

    /* Attempt to open the socket. */
    xListeningSocket = FreeRTOS_socket( FREERTOS_AF_INET,
                                        FREERTOS_SOCK_DGRAM,/*FREERTOS_SOCK_DGRAM for UDP.*/
                                        FREERTOS_IPPROTO_UDP );

    /* Check the socket was created. */
    configASSERT( xListeningSocket != FREERTOS_INVALID_SOCKET );

    /* Bind to port 10000. */
    xBindAddress.sin_port = FreeRTOS_htons( 10000 );
    FreeRTOS_bind( xListeningSocket, &xBindAddress, sizeof( xBindAddress ) );

    for( ;; ) {
        /* Receive data from the socket.  ulFlags is zero, so the standard
        interface is used.  By default the block time is portMAX_DELAY, but it
        can be changed using FreeRTOS_setsockopt(). */
        lBytes = FreeRTOS_recvfrom( xListeningSocket,
                                    cReceivedString,
                                    sizeof( cReceivedString ),
                                    0,
                                    &xClient,
                                    &xClientLength );

        if( lBytes > 0 )
        {
            /* Data was received and can be process here. */
            print_packet(cReceivedString, lBytes);
            
        }
    }
}




/**
 * @brief FreeRTOS task to Send UDP data
 * 
 * @param pvParameters 
 */
static void vUDPSendUsingStandardInterface( void *pvParameters ) {
    Socket_t xSocket;
    struct freertos_sockaddr xDestinationAddress;
    uint8_t cString[ 50 ];
    uint32_t ulCount = 0UL;
    const TickType_t x1000ms = 1000UL / portTICK_PERIOD_MS;

    /* Send strings to port 10000 on IP address 192.168.0.50. */
    xDestinationAddress.sin_addr = FreeRTOS_inet_addr( "192.168.0.50" );
    xDestinationAddress.sin_port = FreeRTOS_htons( 10000 );

    /* Create the socket. */
    xSocket = FreeRTOS_socket( FREERTOS_AF_INET,
                                FREERTOS_SOCK_DGRAM,/*FREERTOS_SOCK_DGRAM for UDP.*/
                                FREERTOS_IPPROTO_UDP );

    /* Check the socket was created. */
    configASSERT( xSocket != FREERTOS_INVALID_SOCKET );

    /* NOTE: FreeRTOS_bind() is not called.  This will only work if
    ipconfigALLOW_SOCKET_SEND_WITHOUT_BIND is set to 1 in FreeRTOSIPConfig.h. */

    for( ;; )
    {
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

        ulCount++;

        /* Wait until it is time to send again. */
        vTaskDelay( x1000ms );
    }
}





void vApplicationIPNetworkEventHook( eIPCallbackEvent_t eNetworkEvent )
{
static BaseType_t xTasksAlreadyCreated = pdFALSE;

    /* Both eNetworkUp and eNetworkDown events can be processed here. */
    if( eNetworkEvent == eNetworkUp )
    {
        /* Create the tasks that use the TCP/IP stack if they have not already
        been created. */
        if( xTasksAlreadyCreated == pdFALSE )
        {
            /*
             * For convenience, tasks that use FreeRTOS-Plus-TCP can be created here
             * to ensure they are not created before the network is usable.
             */

            xTasksAlreadyCreated = pdTRUE;
        }
    }
}