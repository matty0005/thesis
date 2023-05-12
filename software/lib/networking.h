/**
 * @file networking.h
 * @author Matthew Gilpin (matt@gilpin.au)
 * @brief 
 * @version 0.1
 * @date 2023-05-13
 * 
 * @copyright Copyright (c) 2023
 * 
 */
#ifndef NETWORKING_H
#define NETWORKING_H

#include <neorv32.h>

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


void start_networking();
void vApplicationIPNetworkEventHook( eIPCallbackEvent_t eNetworkEvent );
void vCreateTCPClientSocket( void );

#endif
