/**
 * @file FreeRTOSFATConfig.h
 * @author Matthew Gilpin (matt@gilpin.au)
 * @brief 
 * @version 0.1
 * @date 2023-05-29
 * 
 * @copyright Copyright (c) 2023
 * 
 */
#ifndef FREERTOS_FAT_CONFIG_H
#define FREERTOS_FAT_CONFIG_H

#define ffconfigBYTE_ORDER pdFREERTOS_LITTLE_ENDIAN 

/** Full paths must be used unless this is set to 1*/
#define ffconfigHAS_CWD 0
#define ffconfigCWD_THREAD_LOCAL_INDEX 0

/** Long file name support*/
#define ffconfigLFN_SUPPORT 0

/** Support for FAT12*/
#define ffconfigFAT12_SUPPORT 0

/** */
#define ffconfigOPTIMISE_UNALIGNED_ACCESS 0

/** Use second copy in case of an error*/
#define ffconfigWRITE_BOTH_FATS 1

/** Write the free storage amount after write */
#define ffconfigWRITE_FREE_COUNT 1

/** Support timestamps*/
#define  ffconfigTIME_SUPPORT 0

/** Is removable media such as SD card*/
#define ffconfigREMOVABLE_MEDIA 1

/** Find free storage on mount or when needed*/
#define ffconfigMOUNT_FIND_FREE 1

/** Trust certain fields on SD card size left*/
#define ffconfigFSINFO_TRUSTED 1

/** Use cache for paths - uses more memory, but faster*/
#define ffconfigPATH_CACHE 1

/** How many entries in the path cache*/
#define ffconfigPATH_CACHE_DEPTH 3

/** Use cache for hash - uses more memory, but faster*/
#define ffconfigHASH_CACHE 0

/** Allows directory tree created in one go*/
#define ffconfigMKDIR_RECURSIVE 0




#define ffconfigMALLOC( size ) pvPortMalloc( size )
#define ffconfigFREE( ptr ) vPortFree( ptr )




#endif /* ifndef FREERTOS_FAT_CONFIG_H */
