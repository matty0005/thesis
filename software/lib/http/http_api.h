/**
 * @file http_api.h
 * @author Matthew Gilpin (matt@gilpin.au)
 * @brief This file provides all the API functions for the HTTP server.
 * @version 0.1
 * @date 2023-08-18
 * 
 * @copyright Copyright (c) 2023
 * 
 */

#ifndef HTTP_API_H
#define HTTP_API_H

#include "FreeRTOS.h"
#include "task.h"

/* FreeRTOS+TCP includes. */
#include "FreeRTOS_IP.h"
#include "FreeRTOS_Sockets.h"

/* FreeRTOS Protocol includes. */
#include "HTTP_commands.h"
#include "TCP_server.h"
#include "HTTP_server.h"


#include "packet_classifier.h"
#include "common.h"

BaseType_t http_api_firewall_add(HTTPClient_t *pxClient, BaseType_t *httpErrorCode);
BaseType_t http_api_not_found(HTTPClient_t *pxClient, BaseType_t *httpErrorCode);


#endif