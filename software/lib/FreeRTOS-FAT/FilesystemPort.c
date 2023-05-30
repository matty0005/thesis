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

/*
 * Mutex for partition.
 */
static SemaphoreHandle_t xPlusFATMutex = NULL;



static int32_t prvReadSD(uint8_t *pucDestination, uint32_t ulSectorNumber, uint32_t ulSectorCount, FF_Disk_t *pxDisk) {
    uint8_t *pucSource;

    /* The FF_Disk_t structure describes the media being accessed.  Attributes that
    are common to all media types are stored in the structure directly.  The pvTag
    member of the structure is used to add attributes that are specific to the media
    actually being accessed.  In the case of the RAM disk the pvTag member is just
    used to point to the RAM buffer being used as the disk. */
    pucSource = ( uint8_t * ) pxDisk->pvTag;

    /* Move to the start of the sector being read. */
    pucSource += ( sdSECTOR_SIZE * ulSectorNumber );

    /* Copy the data from the disk.  As this is a RAM disk data can be copied
    using memcpy(). */
    memcpy( ( void * ) pucDestination,
            ( void * ) pucSource,
            ( size_t ) ( ulSectorCount * sdSECTOR_SIZE ) );

    return FF_ERR_NONE;
}

static int32_t prvWriteSD(uint8_t *pucSource, uint32_t ulSectorNumber, uint32_t ulSectorCount, FF_Disk_t *pxDisk) {
    uint8_t *pucDestination;

    /* The FF_Disk_t structure describes the media being accessed.  Attributes that
    are common to all media types are stored in the structure directly.  The pvTag
    member of the structure is used to add attributes that are specific to the media
    actually being accessed.  In the case of the RAM disk the pvTag member is just
    used to point to the RAM buffer being used as the disk. */
    pucDestination = ( uint8_t * ) pxDisk->pvTag;

    /* Move to the start of the sector being written. */
    pucDestination += ( sdSECTOR_SIZE * ulSectorNumber );

    /* Copy the data to the disk.  As this is a RAM disk data can be copied
    using memcpy(). */
    memcpy( ( void * ) pucDestination,
            ( void * ) pucSource,
            ( size_t ) ( ulSectorCount * sdSECTOR_SIZE ) );

    return FF_ERR_NONE;
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
        neorv32_uart0_printf("Partition Nr   %8u\n", pxDisk->xStatus.bPartitionNumber);
        neorv32_uart0_printf("Type           %8u (%s)\n", pxIOManager->xPartition.ucType, pcTypeName);
        neorv32_uart0_printf("VolLabel       '%8s' \n", pxIOManager->xPartition.pcVolumeLabel);
        neorv32_uart0_printf("TotalSectors   %8u\n", (unsigned) pxIOManager->xPartition.ulTotalSectors);
        neorv32_uart0_printf("SecsPerCluster %8u\n", (unsigned) pxIOManager->xPartition.ulSectorsPerCluster);
        neorv32_uart0_printf("Size           %8u MB\n", (unsigned) ulTotalSizeMB);
        neorv32_uart0_printf("FreeSize       %8u MB ( %d perc free )\n", (unsigned) ulFreeSizeMB, iPercentageFree);
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
        neorv32_uart0_printf("****** FreeRTOS+FAT initialized %u sectors\n", (unsigned) pxDisk->pxIOManager->xPartition.ulTotalSectors);
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

    uint8_t err = sd_init();

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