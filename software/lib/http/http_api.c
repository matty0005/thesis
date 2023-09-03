/**
 * @file http_api.c
 * @author Matthew Gilpin (matt@gilpin.au)
 * @brief This file provides all the API functions for the HTTP server.
 * @version 0.1
 * @date 2023-08-18
 * 
 * @copyright Copyright (c) 2023
 * 
 */

#include "http_api.h"


BaseType_t http_api_firewall_get(HTTPClient_t *pxClient, BaseType_t *httpErrorCode) {
        
        // Get the firewall rules from the packet classifier.
        snprintf(pxClient->pxParent->pcContentsType, sizeof( pxClient->pxParent->pcContentsType ),
                "%s", "text/plain" );

        int8_t *rules = pvPortMalloc(PACKET_FILTER_RULE_FILE_SIZE * sizeof(uint8_t));
        // uint8_t rules[PACKET_FILTER_RULE_FILE_SIZE];

        uint32_t size = 0;
        int err = pc_get_rules(rules, PACKET_FILTER_RULE_FILE_SIZE, &size);

        if (err) {
                FreeRTOS_printf( ( "http_api_firewall_get:  %d\n", err) );
                snprintf(pxClient->pxParent->pcExtraContents, sizeof( pxClient->pxParent->pcExtraContents ),
                        "Content-Length: %d\r\n\r\n%s", 19, "Could not read file" );

                *httpErrorCode = WEB_INTERNAL_SERVER_ERROR;
                vPortFree(rules);

                return pdTRUE;
        }

        
        
        // craft a response
        snprintf(pxClient->pxParent->pcExtraContents, sizeof( pxClient->pxParent->pcExtraContents ),
                "Content-Length: %d\r\n\r\n", size);

        // copy the rules into the response
        memcpy(pxClient->pxParent->pcExtraContents + strlen(pxClient->pxParent->pcExtraContents), rules, size);

        vPortFree(rules);
        

        *httpErrorCode = WEB_REPLY_OK;

        return pdTRUE;
}

/**
 * @brief Add a firewall rule to the packet classifier.
 * 
 * Packet format for firewall rule
 *  All bytes are in hex
 *  LOCATION[1] | WILDCARD[1] | DEST_IP[4] | SRC_IP[4] | DEST_PORT[2] | SRC_PORT[2] | PROTOCOL[1]
 * 
 * @param pxClient 
 * @param httpErrorCode 
 * @return BaseType_t 
 */
BaseType_t http_api_firewall_add(HTTPClient_t *pxClient, BaseType_t *httpErrorCode) {

    // Find offset of raw data.
    char *pcRawData = strstr(pxClient->pcRestData, "payload=");

    // Remove the payload= from the string.
    pcRawData += 8;

    uint8_t location = (uint8_t) hex_byte_to_int(pcRawData);
    uint8_t wildcard = (uint8_t) hex_byte_to_int(pcRawData + 2);
    uint8_t destIP[4] = {hex_byte_to_int(pcRawData + 4), hex_byte_to_int(pcRawData + 6), hex_byte_to_int(pcRawData + 8), hex_byte_to_int(pcRawData + 10)};
    uint8_t sourceIP[4] = {hex_byte_to_int(pcRawData + 12), hex_byte_to_int(pcRawData + 14), hex_byte_to_int(pcRawData + 16), hex_byte_to_int(pcRawData+ 18)};
    uint16_t destPort = (uint16_t) hex_byte_to_int(pcRawData + 20) << 8 | (uint16_t) hex_byte_to_int(pcRawData + 22);
    uint16_t sourcePort = (uint16_t) hex_byte_to_int(pcRawData + 24) << 8 | (uint16_t) hex_byte_to_int(pcRawData + 26);
    uint8_t protocol = hex_byte_to_int(pcRawData + 28);

    // Save the rule to the packet classifier.
    pc_save_rule(location, wildcard, destIP, sourceIP, destPort, sourcePort, protocol);

    FreeRTOS_printf( ( "http_api_firewall_add:  %d\n", destIP[0]) );


    // craft a response
    snprintf(pxClient->pxParent->pcContentsType, sizeof( pxClient->pxParent->pcContentsType ),
            "%s", "text/plain" );

    snprintf(pxClient->pxParent->pcExtraContents, sizeof( pxClient->pxParent->pcExtraContents ),
            "Content-Length: %d\r\n\r\n%s", 31, "You have the firewall add route" );

    *httpErrorCode = WEB_CREATED;

    return pdTRUE;
    
}

BaseType_t http_api_not_found(HTTPClient_t *pxClient, BaseType_t *httpErrorCode) {
    snprintf(pxClient->pxParent->pcContentsType, sizeof( pxClient->pxParent->pcContentsType ),
            "%s", "text/plain" );

    snprintf(pxClient->pxParent->pcExtraContents, sizeof( pxClient->pxParent->pcExtraContents ),
            "Content-Length: %d\r\n\r\n%s", 21, "Applied firewall rule" );

    
}