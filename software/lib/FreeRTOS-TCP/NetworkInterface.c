/**
 * @file NetworkInterface.c
 * @author Matthew Gilpin (matt@gilpin.au)
 * @brief FreeRTOS Plus TCP Network Interface for NeoRV32 + VHDL Ethernet MAC
 * @version 0.1
 * @date 2023-04-12
 * 
 * @copyright Copyright (c) 2023
 * 
 * Useful link
 * https://www.freertos.org/FreeRTOS-Plus/FreeRTOS_Plus_TCP/Embedded_Ethernet_Porting.html
 * 
 */

#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <neorv32.h>

/* FreeRTOS includes. */
#include "FreeRTOS.h"
#include "task.h"
#include "queue.h"
#include "semphr.h"

/* FreeRTOS+TCP includes. */
#include "FreeRTOS_IP.h"
#include "FreeRTOS_Sockets.h"
#include "FreeRTOS_IP_Private.h"
#include "FreeRTOS_DNS.h"
#include "NetworkBufferManagement.h"
#include "NetworkInterface.h"

#include "ethernet.h"
#include "common.h"

const char * pcApplicationHostnameHook( void ) {
    return "RISCy-Firewall";
}

BaseType_t xApplicationGetRandomNumber( uint32_t * pulNumber );
BaseType_t xApplicationDNSQueryHook( const char * pcName );
uint32_t ulApplicationGetNextSequenceNumber( uint32_t ulSourceAddress, uint16_t usSourcePort, uint32_t ulDestinationAddress, uint16_t usDestinationPort );

static void prvEMACDeferredInterruptHandlerTask( void *pvParameters );
TaskHandle_t xEMACTaskHandle = NULL;



/** Implement with TNG in Neorv32*/
BaseType_t xApplicationGetRandomNumber( uint32_t * pulNumber ) {
    uint8_t trng_data[4];

 
    neorv32_trng_get(trng_data);
    neorv32_trng_get(trng_data + 1);
    neorv32_trng_get(trng_data + 2);
    neorv32_trng_get(trng_data + 3);
      
     return (uint32_t) trng_data[3] << 24 | (uint32_t)trng_data[2] << 16 | (uint32_t) trng_data[1] << 8 | (uint32_t) trng_data[0];
}


BaseType_t xApplicationDNSQueryHook( const char * pcName ) {
    return 0;
}

uint32_t ulApplicationGetNextSequenceNumber( uint32_t ulSourceAddress, uint16_t usSourcePort, uint32_t ulDestinationAddress, uint16_t usDestinationPort ) {
    uint8_t trng_data[4];

    neorv32_trng_get(trng_data);
    neorv32_trng_get(trng_data + 1);
    neorv32_trng_get(trng_data + 2);
    neorv32_trng_get(trng_data + 3);

    return (uint32_t) trng_data[3] << 24 | (uint32_t)trng_data[2] << 16 | (uint32_t) trng_data[1] << 8 | (uint32_t) trng_data[0];
}




/**
 * @brief The TCP/IP stack calls xNetworkInterfaceInitialise() when the network is ready to be used (or re-used after a disconnect).
 * 
 * @return BaseType_t 
 */
BaseType_t xNetworkInterfaceInitialise( void ) 
{

    if( xEMACTaskHandle == NULL )
    {
        /* Create event handler task */
        xTaskCreate( prvEMACDeferredInterruptHandlerTask, /* Function that implements the task. */
                     "EMACInt",                           /* Text name for the task. */
                     256 * 2,                                 /* Stack size in words, not bytes. */
                     ( void * ) 1,                        /* Parameter passed into the task. */
                     configMAX_PRIORITIES - 3,                    /* Priority at which the task is created. */
                     &xEMACTaskHandle );                  /* Used to pass out the created task's handle. */

    }



    if (eth_init() != ETH_ERR_OK)
        return pdFAIL;
    

    return pdPASS;
}


/**
 * @brief  The TCP/IP stack calls xNetworkInterfaceOutput() whenever a network buffer is ready to be transmitted.
 * The buffer to transmit is described by the descriptor passed into the function using the function's pxDescriptor parameter. 
 * If xReleaseAfterSend does not equal pdFALSE then both the buffer and the buffer's descriptor must be released (returned) back 
 * to the embedded TCP/IP stack by the driver code when they are no longer required. If xReleaseAfterSend is pdFALSE then both 
 * the network buffer and the buffer's descriptor will be released by the TCP/IP stack itself (in which case the driver does not need to release them).
 * 
 * Note that, at the time of writing, the value returned from xNetworkInterfaceOutput() is ignored. The embedded TCP/IP stack will NOT call 
 * xNetworkInterfaceOutput() for the same network buffer twice, even if the first call to xNetworkInterfaceOutput() could not send the network buffer onto the network.
 * 
 * Basic and more advanced examples are provided below, and the FreeRTOS-Plus-TCP/portable/NetworkInterface directory of the FreeRTOS-Plus-TCP 
 * download contained examples that can be referenced. Note however that the examples in the download may not be optimised. 
 * 
 * @param pxDescriptor 
 * @param xReleaseAfterSend 
 * @return BaseType_t 
 */

void printBufferInHex(const uint8_t *buffer, size_t length)
{
    for(size_t i = 0; i < length; i++)
    {
        FreeRTOS_printf(("%c", buffer[i]));
    }
    FreeRTOS_printf(("\n"));
}
BaseType_t xNetworkInterfaceOutput(NetworkBufferDescriptor_t * const pxDescriptor, BaseType_t xReleaseAfterSend) 
{

    BaseType_t xReturn = pdFAIL;
    // printBufferInHex(pxDescriptor->pucEthernetBuffer, pxDescriptor->xDataLength);

    // pxDescriptor->pucEthernetBuffer is just a pointer to the start of the buffer. (uint8_t *)
    // pxDescriptor->xDataLength is the length of the buffer. (size_t)
    if (eth_send(pxDescriptor->pucEthernetBuffer, pxDescriptor->xDataLength) == ETH_ERR_OK) 
        xReturn = pdPASS;

    /* Call the standard trace macro to log the send event. */
    iptraceNETWORK_INTERFACE_TRANSMIT();
    
    if (xReleaseAfterSend != pdFALSE)
        vReleaseNetworkBufferAndDescriptor(pxDescriptor);
    

    return xReturn;
}

/**
 * @brief The TCP/IP stack calls xNetworkInterfaceInput() to pass received Ethernet frames into the TCP/IP stack.
 * 
 * @param eStatus 
 * @param usIdentifier 
 */
void vApplicationPingReplyHook( ePingReplyStatus_t eStatus, uint16_t usIdentifier )
{
static const uint8_t *pcSuccess = ( uint8_t * ) "Ping reply received - ";
static const uint8_t *pcInvalidChecksum = ( uint8_t * ) "Ping reply received with invalid checksum - ";
static const uint8_t *pcInvalidData = ( uint8_t * ) "Ping reply received with invalid data - ";
static uint8_t cMessage[ 50 ];


    switch( eStatus )
    {
        case eSuccess:
            neorv32_uart0_printf( ( ( char * ) pcSuccess ) );
            break;

        case eInvalidChecksum:
            neorv32_uart0_printf( ( ( char * ) pcInvalidChecksum ) );
            break;

        case eInvalidData:
            neorv32_uart0_printf( ( ( char * ) pcInvalidData ) );
            break;

        default :
            /* It is not possible to get here as all enums have their own
             * case. */
            break;
    }

    sprintf( ( char * ) cMessage, "identifier %d\r\n", ( int ) usIdentifier );
    neorv32_uart0_printf( ( ( char * ) cMessage ) );
}



/* The deferred interrupt handler is a standard RTOS task.  FreeRTOS's centralised
deferred interrupt handling capabilities can also be used. */
static void prvEMACDeferredInterruptHandlerTask( void *pvParameters ) 
{
    NetworkBufferDescriptor_t *pxBufferDescriptor;
    size_t xBytesReceived;

    /* Used to indicate that xSendEventStructToIPTask() is being called because
    of an Ethernet receive event. */
    IPStackEvent_t xRxEvent;

    for( ;; ) 
    {
        ulTaskNotifyTake( pdTRUE, portMAX_DELAY );

        /* Obtain the size of the packet and put it into the "length" member of
        the pxBufferDescriptor structure. */
        xBytesReceived = eth_recv_size();

        if (xBytesReceived > 0) 
        {
            /* Obtain a network buffer descriptor.  This call will block
            indefinitely if a network buffer is not available. */
            
            pxBufferDescriptor = pxGetNetworkBufferWithDescriptor( xBytesReceived, 0 );

            if( pxBufferDescriptor != NULL ) 
            {
                /* Set the actual length of the packet. */
                pxBufferDescriptor->xDataLength = xBytesReceived;
                

                taskENTER_CRITICAL();
    
                /* Obtain the packet into the buffer pointed to by the
                pxBufferDescriptor structure. */
                eth_recv(pxBufferDescriptor->pucEthernetBuffer, xBytesReceived);

                taskEXIT_CRITICAL();

                if (eConsiderFrameForProcessing(pxBufferDescriptor->pucEthernetBuffer) == eProcessBuffer) 
                {

                    // The event about to be sent to the TCP/IP is an Rx event.
                    xRxEvent.eEventType = eNetworkRxEvent;

                    xRxEvent.pvData = (void *) pxBufferDescriptor;

                    /* Pass the received packet to the TCP/IP stack. */
                    if( xSendEventStructToIPTask( &xRxEvent, 100 ) == pdFALSE ) 
                    {
                        /* The buffer could not be sent to the IP task so the buffer must be released. */
                        vReleaseNetworkBufferAndDescriptor( pxBufferDescriptor );
                        iptraceETHERNET_RX_EVENT_LOST();
                    }
                    else 
                    {
                        iptraceNETWORK_INTERFACE_RECEIVE();

                    }

                }
                else 
                {
                    // The Ethernet frame can be dropped, but the Ethernet buffer must be released.
                    vReleaseNetworkBufferAndDescriptor( pxBufferDescriptor );
                }
                
            }
            else 
            {
                /* The buffer could not be obtained so the packet must be dropped. */
                iptraceETHERNET_RX_EVENT_LOST();
            }
        }
    }
}