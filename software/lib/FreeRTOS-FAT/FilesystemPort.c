/**
 * @file FilesystemPort.c
 * @author Matthew Gilpin (matt@gilpin.au)
 * @brief 
 * @version 0.1
 * @date 2023-05-29
 * 
 * @copyright Copyright (c) 2023
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

/* FreeRTOS+FAT includes. */
#include "ff_sddisk.h"
#include "ff_sys.h"

#include "sd.h"

/* Misc definitions. */
#define sdSIGNATURE         0x41404342UL
#define sdHUNDRED_64_BIT    ( 100ull )
#define sdBYTES_PER_MB      ( 1024ull * 1024ull )
#define sdSECTORS_PER_MB    ( sdBYTES_PER_MB / 512ull )
#define sdIOMAN_MEM_SIZE    4096
#define xSDCardInfo         ( sd_mmc_cards[ 0 ] )

#define sdSECTOR_COUNT      31250000UL


#define sdSECTOR_SIZE    512

static int32_t prvWriteSD(uint8_t *pucSource, uint32_t ulSectorNumber, uint32_t ulSectorCount, FF_Disk_t *pxDisk);
static int32_t prvReadSD(uint8_t *pucDestination, uint32_t ulSectorNumber, uint32_t ulSectorCount, FF_Disk_t *pxDisk);

/*
 * Mutex for partition.
 */
static SemaphoreHandle_t xPlusFATMutex = NULL;


/**
 * @brief Reads from the SD card.
 * 
 * @param pucBuffer Buffer to read to 
 * @param ulSectorNumber The sector to start at
 * @param ulSectorCount The number of sectors to read
 * @param pxDisk The disk to read from
 * @return int32_t 
 */
static int32_t prvReadSD(uint8_t *pucBuffer, uint32_t ulSectorNumber, uint32_t ulSectorCount, FF_Disk_t *pxDisk) {
    uint8_t *pucSource;

    int32_t lReturnCode = 1L, lResult = pdFALSE;

    if( ( pxDisk != NULL ) &&
        ( sd_card_inserted() == pdTRUE ) &&
        ( pxDisk->ulSignature == sdSIGNATURE ) &&
        ( pxDisk->xStatus.bIsInitialised != pdFALSE ) &&
        ( ulSectorNumber < pxDisk->ulNumberOfSectors ) &&
        ( ( pxDisk->ulNumberOfSectors - ulSectorNumber ) >= ulSectorCount ) )
    {

        uint32_t ulSector;
        uint8_t *pucDMABuffer = ffconfigMALLOC(512ul);

        /* The buffer is NOT word-aligned, read to an aligned buffer and then
            * copy the data to the user provided buffer. */
        if (pucDMABuffer != NULL) {
            for (ulSector = 0; ulSector < ulSectorCount; ulSector++ ) {

                // Ignore errors.
                uint8_t *token;
                sd_read_block(ulSectorNumber + ulSector, pucDMABuffer, token);

                // could check token for error, but thats not fun.
       
                /* Copy to the user-provided buffer. */
                memcpy(pucBuffer + 512ul * ulSector, pucDMABuffer, 512ul);
            }

            ffconfigFREE(pucDMABuffer);
        } else {
            FF_PRINTF("prvFFRead: malloc failed\n" );
            lResult = pdFALSE;
        }
    

        if (lResult != pdFALSE) {
            lReturnCode = 0L;
        } else {
            /* Some error occurred. */
            FF_PRINTF( "prvFFRead: %u: %d\n", ( unsigned ) ulSectorNumber, ( int ) lResult );
        }
    }
    else
    {
        /* Make sure no random data is in the returned buffer. */
        memset((void *) pucBuffer, '\0', ulSectorCount * 512UL);

        if (pxDisk->xStatus.bIsInitialised != pdFALSE) {
            FF_PRINTF("prvFFRead: warning: %u + %u > %u\n", ( unsigned ) ulSectorNumber, ( unsigned ) ulSectorCount, ( unsigned ) pxDisk->ulNumberOfSectors);
        }
    }

    return lReturnCode;
}

/**
 * @brief Writes to the SD card.
 * 
 * @param pucBuffer The buffer to write from 
 * @param ulSectorNumber The sector to start at
 * @param ulSectorCount The number of sectors to write
 * @param pxDisk The disk to write to
 * @return int32_t 
 */
static int32_t prvWriteSD(uint8_t *pucBuffer, uint32_t ulSectorNumber, uint32_t ulSectorCount, FF_Disk_t *pxDisk) {
    int32_t lReturnCode = 1, lResult = pdFALSE;

    if( ( pxDisk != NULL ) &&
        ( sd_card_inserted() == pdTRUE ) &&
        ( pxDisk->ulSignature == sdSIGNATURE ) &&
        ( pxDisk->xStatus.bIsInitialised != pdFALSE ) &&
        ( ulSectorNumber < pxDisk->ulNumberOfSectors ) &&
        ( ( pxDisk->ulNumberOfSectors - ulSectorNumber ) >= ulSectorCount ) )
    {
       
        uint32_t ulSector;
        uint8_t *pucDMABuffer = ffconfigMALLOC( 512ul );

        if (pucDMABuffer != NULL) {
            for (ulSector = 0; ulSector < ulSectorCount; ulSector++) {

                /* Copy from the user provided buffer to the temporary buffer. */
                memcpy(pucDMABuffer, pucBuffer + 512ul * ulSector, 512ul);

                uint8_t *token;
                sd_write_block(ulSectorNumber + ulSector, pucDMABuffer, token);

                // could check token for error, but thats boring - getting unexpected errors are much better.   
            }

            ffconfigFREE(pucDMABuffer);
        } else {
            FF_PRINTF("prvFFWrite: malloc failed\n");
            lResult = pdFALSE;
        }
        

        if(lResult != pdFALSE) {
            /* No errors. */
            lReturnCode = 0L;
        } else {
            FF_PRINTF("prvFFWrite: %u: %d\n", ( unsigned ) ulSectorNumber, ( int ) lResult);
        }
    } else {
        if (pxDisk->xStatus.bIsInitialised != pdFALSE) {
            FF_PRINTF("prvFFWrite: warning: %u + %u > %u\n", ( unsigned ) ulSectorNumber, ( unsigned ) ulSectorCount, ( unsigned ) pxDisk->ulNumberOfSectors);
        }
    }

    return lReturnCode;
}

/**
 * @brief Detects if the SD card is plugged in.
 * 
 * @return BaseType_t 
 */
static BaseType_t prvSDDetect() {
    static BaseType_t xWasPresent = pdFALSE;
    BaseType_t xIsPresent = pdFALSE;
    uint8_t xSDPresence;

    // Dont bother if not inserted
    if (!sd_card_inserted()) {
        xWasPresent = pdFALSE;
        return pdFALSE;
    }

    if (xWasPresent == pdFALSE) 
        xIsPresent = sd_init();
    
    xWasPresent = xIsPresent;

    return xIsPresent;
}


/**
 * @brief Detects if the SD card is plugged in.
 * 
 * @return BaseType_t 
 */
static BaseType_t prvSDMMCInit() {
    BaseType_t xReturn;

    /* Check if the SD card is plugged in the slot */
    if (prvSDDetect() == pdFALSE) {
        FF_PRINTF("No SD card detected\n");
        xReturn = pdFAIL;
    } else {
        FF_PRINTF("SD card Init successful\r\n");

        xReturn = pdPASS;
    }

    return xReturn;
}


/**
 * @brief Releases the resources used by the SD card.
 * 
 * @param pxDisk Disk to unmount
 * @return BaseType_t 
 */
BaseType_t FF_SDDiskDelete(FF_Disk_t * pxDisk) {
    if (pxDisk != NULL) {
        pxDisk->ulSignature = 0;
        pxDisk->xStatus.bIsInitialised = 0;

        if (pxDisk->pxIOManager != NULL) {

            if (FF_Mounted(pxDisk->pxIOManager) != pdFALSE)
                FF_Unmount(pxDisk);

            FF_DeleteIOManager(pxDisk->pxIOManager);
        }

        vPortFree(pxDisk);
    }

    return 1;
}


/**
 * @brief Shows the partition information of the SD card
 * 
 * @param pxDisk Disk to show partition information of
 * @return BaseType_t 
 */
BaseType_t FF_SDDiskShowPartition(FF_Disk_t * pxDisk) {
    FF_Error_t xError;
    uint64_t ullFreeSectors;
    uint32_t ulTotalSizeMB, ulFreeSizeMB;
    int iPercentageFree;
    FF_IOManager_t * pxIOManager;
    const char * pcTypeName = "unknown type";
    BaseType_t xReturn = pdPASS;

    if (pxDisk == NULL) {
        xReturn = pdFAIL;
    } else {
        pxIOManager = pxDisk->pxIOManager;

        neorv32_uart0_printf("Reading FAT and calculating Free Space\n");

        switch (pxIOManager->xPartition.ucType) {
            case FF_T_FAT12:
                pcTypeName = "FAT12";
                break;

            case FF_T_FAT16:
                pcTypeName = "FAT16";
                break;

            case FF_T_FAT32:
                pcTypeName = "FAT32";
                break;

            default:
                pcTypeName = "UNKOWN";
                break;
        }

        FF_GetFreeSize(pxIOManager, &xError);

        ullFreeSectors = pxIOManager->xPartition.ulFreeClusterCount * pxIOManager->xPartition.ulSectorsPerCluster;
        iPercentageFree = (int) ((sdHUNDRED_64_BIT * ullFreeSectors + pxIOManager->xPartition.ulDataSectors / 2 ) /
                                    ((uint64_t) pxIOManager->xPartition.ulDataSectors ));

        ulTotalSizeMB = pxIOManager->xPartition.ulDataSectors / sdSECTORS_PER_MB;
        //ulFF_SDDiskMountFreeSizeMB = (uint32_t) (ullFreeSectors / sdSECTORS_PER_MB);

        /* It is better not to use the 64-bit format such as %Lu because it
         * might not be implemented. */

        char buff[200];
        
        neorv32_uart0_printf("Partition Nr   %d\n", pxDisk->xStatus.bPartitionNumber);
        neorv32_uart0_printf("Type           %d (%s)\n", pxIOManager->xPartition.ucType, pcTypeName);
        neorv32_uart0_printf("VolLabel       '%s' \n", pxIOManager->xPartition.pcVolumeLabel);
        neorv32_uart0_printf("TotalSectors   %d\n", (unsigned) pxIOManager->xPartition.ulTotalSectors);
        neorv32_uart0_printf("SecsPerCluster %d\n", (unsigned) pxIOManager->xPartition.ulSectorsPerCluster);
        neorv32_uart0_printf("Size           %d MB\n", (unsigned) ulTotalSizeMB);
        neorv32_uart0_printf("FreeSize       %d MB ( %d perc free )\n", (unsigned) ulFreeSizeMB, iPercentageFree);
    }

    return xReturn;
}

/**
 * @brief Mounts the SD card
 * 
 * @param pxDisk Disk to mount
 * @return BaseType_t 
 */
BaseType_t FF_SDDiskMount(FF_Disk_t * pxDisk) {
    FF_Error_t xFFError;
    BaseType_t xReturn;

    /* Mount the partition */
    xFFError = FF_Mount(pxDisk, pxDisk->xStatus.bPartitionNumber);

    if (FF_isERR(xFFError)) {
        neorv32_uart0_printf("FF_SDDiskMount: %08lX\n", xFFError);
        xReturn = pdFAIL;
    } else {
        pxDisk->xStatus.bIsMounted = pdTRUE;
        neorv32_uart0_printf("****** FreeRTOS+FAT initialized %d sectors\n", (unsigned) pxDisk->pxIOManager->xPartition.ulTotalSectors);
        FF_SDDiskShowPartition( pxDisk );
        xReturn = pdPASS;
    }

    return xReturn;
}


/**
 * @brief Initalises the SD disk
 * 
 * @param pcName Path to mount the SD card as
 * @return FF_Disk_t* 
 */
FF_Disk_t * FF_SDDiskInit(const char * pcName) {
    FF_Error_t xFFError;
    BaseType_t xPartitionNumber = 0;
    FF_CreationParameters_t xParameters;
    FF_Disk_t * pxDisk;

    uint8_t err = prvSDMMCInit();

    if (err != SD_CARD_OK) {
        neorv32_uart0_printf( "FF_SDDiskInit: sd_init failed\n" );
        pxDisk = NULL;
    } else {
        pxDisk = (FF_Disk_t *) pvPortMalloc(sizeof(*pxDisk));

        if (pxDisk == NULL) {

            neorv32_uart0_printf("FF_SDDiskInit: Malloc failed\n");

        } else {

            /* Initialise the created disk structure. */
            memset(pxDisk, '\0', sizeof( *pxDisk ));

            // time by 2 since we are using 512 byte sectors
            pxDisk->ulNumberOfSectors = sdSECTOR_COUNT << 1;

            if (xPlusFATMutex == NULL) {
                xPlusFATMutex = xSemaphoreCreateRecursiveMutex();
            }

            pxDisk->ulSignature = sdSIGNATURE;

            if (xPlusFATMutex != NULL) {
                memset(&xParameters, '\0', sizeof(xParameters));
                xParameters.ulMemorySize = sdIOMAN_MEM_SIZE;
                xParameters.ulSectorSize = 512;
                xParameters.fnWriteBlocks = prvWriteSD;
                xParameters.fnReadBlocks = prvReadSD;
                xParameters.pxDisk = pxDisk;

                /* prvReadSD()/prvWriteSD() are not re-entrant and must be
                 * protected with the use of a semaphore. */
                xParameters.xBlockDeviceIsReentrant = pdFALSE;

                /* The semaphore will be used to protect critical sections in
                 * the +FAT driver, and also to avoid concurrent calls to
                 * prvReadSD()/prvWriteSD() from different tasks. */
                xParameters.pvSemaphore = (void *) xPlusFATMutex;

                pxDisk->pxIOManager = FF_CreateIOManager(&xParameters, &xFFError);

                if (pxDisk->pxIOManager == NULL) {

                    neorv32_uart0_printf("FF_SDDiskInit: FF_CreateIOManager: %s\n", (const char *) FF_GetErrMessage( xFFError));
                    FF_SDDiskDelete(pxDisk);
                    pxDisk = NULL;

                } else {

                    pxDisk->xStatus.bIsInitialised = pdTRUE;
                    pxDisk->xStatus.bPartitionNumber = xPartitionNumber;

                    if(FF_SDDiskMount(pxDisk) == 0) {
                        FF_SDDiskDelete(pxDisk);
                        pxDisk = NULL;
                    } else {
                        if (pcName == NULL) {
                            pcName = "/";
                        }

                        FF_FS_Add(pcName, pxDisk);
                        neorv32_uart0_printf("FF_SDDiskInit: Mounted SD-card as root \"%s\"\n", pcName);
                        FF_SDDiskShowPartition(pxDisk);
                    }
                } /* if( pxDisk->pxIOManager != NULL ) */
            }     /* if( xPlusFATMutex != NULL) */
        }         /* if( pxDisk != NULL ) */
    }             /* if( xSDCardStatus == pdPASS ) */

    return pxDisk;
}