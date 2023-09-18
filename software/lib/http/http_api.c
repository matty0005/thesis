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


BaseType_t http_api_firewall_add_all(HTTPClient_t *pxClient, BaseType_t *httpErrorCode) {

    // Count number of \n's
    char *pcRawData = strstr(pxClient->pcRestData, "\r\n\r\n");

    // Remove the \r\n\r\n from the string.
    pcRawData += 4;

    pc_save_rules_all(pcRawData, 8);

    // craft a response
    snprintf(pxClient->pxParent->pcContentsType, sizeof( pxClient->pxParent->pcContentsType ),
            "%s", "text/plain" );

    snprintf(pxClient->pxParent->pcExtraContents, sizeof( pxClient->pxParent->pcExtraContents ),
            "Content-Length: %d\r\n\r\n%s", 19, "Sucessfully created" );

    *httpErrorCode = WEB_CREATED;

    return pdTRUE;

}

/**
 * @brief GET Request for the stats API. Format is CSV, with the following fields:
 * packetsTotal, blockedTotal, udp_status, cli_status, firewall_status
 * 
 * @param pxClient 
 * @param httpErrorCode 
 * @return BaseType_t 
 */
BaseType_t http_api_stats(HTTPClient_t *pxClient, BaseType_t *httpErrorCode) {

    uint64_t total = pc_get_total_packet_count();
    uint64_t blocked = pc_get_blocked_packet_count();

    uint64_t uptime = xTaskGetTickCount(); // May need to change if tick rate is changed. 
    

    char buff[100] = {0};
    snprintf(buff, sizeof(buff), "%llu,%llu,%llu,%d,%d,%d", total, blocked, uptime, xUDPPingTaskHandle != NULL, xCliTaskHandle != NULL, pc_get_status());


    // craft a response
    snprintf(pxClient->pxParent->pcContentsType, sizeof( pxClient->pxParent->pcContentsType ),
            "%s", "text/plain" );

    snprintf(pxClient->pxParent->pcExtraContents, sizeof( pxClient->pxParent->pcExtraContents ),
            "Content-Length: %d\r\n\r\n%s", strlen(buff), buff);

    *httpErrorCode = WEB_REPLY_OK;

    return pdTRUE;

}

BaseType_t http_api_control_udp(HTTPClient_t *pxClient, BaseType_t *httpErrorCode) {

    if (xUDPPingTaskHandle != NULL) {

        vTaskDelete(xUDPPingTaskHandle);
        xUDPPingTaskHandle = NULL;
    } else 
        create_udp_task();

    // craft a response
    snprintf(pxClient->pxParent->pcContentsType, sizeof( pxClient->pxParent->pcContentsType ),
            "%s", "text/plain" );

    snprintf(pxClient->pxParent->pcExtraContents, sizeof( pxClient->pxParent->pcExtraContents ),
            "Content-Length: %d\r\n\r\n%s", 2, "OK" );

    *httpErrorCode = WEB_CREATED;

    return pdTRUE;
}

BaseType_t http_api_control_cli(HTTPClient_t *pxClient, BaseType_t *httpErrorCode) {

    if (xCliTaskHandle != NULL) {
        vTaskDelete(xCliTaskHandle);
        xCliTaskHandle = NULL;
    } else 
        cli_init();

    // craft a response
    snprintf(pxClient->pxParent->pcContentsType, sizeof( pxClient->pxParent->pcContentsType ),
            "%s", "text/plain" );

    snprintf(pxClient->pxParent->pcExtraContents, sizeof( pxClient->pxParent->pcExtraContents ),
            "Content-Length: %d\r\n\r\n%s", 2, "OK" );

    *httpErrorCode = WEB_CREATED;

    return pdTRUE;

}

BaseType_t http_api_reset_counts(HTTPClient_t *pxClient, BaseType_t *httpErrorCode) {

    pc_reset_counts();

    // craft a response
    snprintf(pxClient->pxParent->pcContentsType, sizeof( pxClient->pxParent->pcContentsType ),
            "%s", "text/plain" );

    snprintf(pxClient->pxParent->pcExtraContents, sizeof( pxClient->pxParent->pcExtraContents ),
            "Content-Length: %d\r\n\r\n%s", 2, "OK" );

    *httpErrorCode = WEB_CREATED;

    return pdTRUE;

}




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
            "Content-Length: %d\r\n\r\n%s", 9, "Not found" );

    
}