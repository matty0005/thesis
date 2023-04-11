#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

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


BaseType_t xNetworkInterfaceInitialise( void ) 
{

    if (eth_init()) {

        return pdFAIL;
    }

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
BaseType_t xNetworkInterfaceOutput(NetworkBufferDescriptor_t * const pxDescriptor, BaseType_t xReleaseAfterSend) 
{

    /* Call the standard trace macro to log the send event. */
    iptraceNETWORK_INTERFACE_TRANSMIT();

    BaseType_t xReturn = pdFAIL;

    // pxDescriptor->pucEthernetBuffer is just a pointer to the start of the buffer. (uint8_t *)
    // pxDescriptor->xDataLength is the length of the buffer. (size_t)
    if (eth_send(pxDescriptor->pucEthernetBuffer, pxDescriptor->xDataLength)) {

        xReturn = pdFAIL;
    } else {

        xReturn = pdPASS;
    }

    if (xReleaseAfterSend != pdFALSE) {

        vReleaseNetworkBufferAndDescriptor(pxDescriptor);
    }

    return xReturn;
}