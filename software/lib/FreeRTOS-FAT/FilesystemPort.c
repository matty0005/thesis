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

/* Misc definitions. */
#define sdSIGNATURE         0x41404342UL
#define sdHUNDRED_64_BIT    ( 100ull )
#define sdBYTES_PER_MB      ( 1024ull * 1024ull )
#define sdSECTORS_PER_MB    ( sdBYTES_PER_MB / 512ull )
#define sdIOMAN_MEM_SIZE    4096
#define xSDCardInfo         ( sd_mmc_cards[ 0 ] )


#define sdSECTOR_SIZE    512

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

/*
In this example:
  - pcName is the name to give the disk within FreeRTOS-Plus-FAT's virtual file system.
  - pucDataBuffer is the start of the RAM buffer used as the disk.
  - ulSectorCount is effectively the size of the disk, each sector is 512 bytes.
  - xIOManagerCacheSize is the size of the IO manager's cache, which must be a
   multiple of the sector size, and at least twice as big as the sector size.
*/
FF_Disk_t * FF_SDDiskInit( const char * pcName )
{
    FF_Error_t xFFError;
    BaseType_t xPartitionNumber = 0;
    FF_CreationParameters_t xParameters;
    FF_Disk_t * pxDisk;

    xSDCardStatus = prvSDMMCInit( 0 );

    if( xSDCardStatus != pdPASS )
    {
        FF_PRINTF( "FF_SDDiskInit: prvSDMMCInit failed\n" );
        pxDisk = NULL;
    }
    else
    {
        pxDisk = ( FF_Disk_t * ) pvPortMalloc( sizeof( *pxDisk ) );

        if( pxDisk == NULL )
        {
            FF_PRINTF( "FF_SDDiskInit: Malloc failed\n" );
        }
        else
        {
            /* Initialise the created disk structure. */
            memset( pxDisk, '\0', sizeof( *pxDisk ) );

            /* The Atmel MMC driver sets capacity as a number of KB.
             * Divide by two to get the number of 512-byte sectors. */
            pxDisk->ulNumberOfSectors = xSDCardInfo.capacity << 1;

            if( xPlusFATMutex == NULL )
            {
                xPlusFATMutex = xSemaphoreCreateRecursiveMutex();
            }

            pxDisk->ulSignature = sdSIGNATURE;

            if( xPlusFATMutex != NULL )
            {
                memset( &xParameters, '\0', sizeof( xParameters ) );
                xParameters.ulMemorySize = sdIOMAN_MEM_SIZE;
                xParameters.ulSectorSize = 512;
                xParameters.fnWriteBlocks = prvFFWrite;
                xParameters.fnReadBlocks = prvFFRead;
                xParameters.pxDisk = pxDisk;

                /* prvFFRead()/prvFFWrite() are not re-entrant and must be
                 * protected with the use of a semaphore. */
                xParameters.xBlockDeviceIsReentrant = pdFALSE;

                /* The semaphore will be used to protect critical sections in
                 * the +FAT driver, and also to avoid concurrent calls to
                 * prvFFRead()/prvFFWrite() from different tasks. */
                xParameters.pvSemaphore = ( void * ) xPlusFATMutex;

                pxDisk->pxIOManager = FF_CreateIOManager( &xParameters, &xFFError );

                if( pxDisk->pxIOManager == NULL )
                {
                    FF_PRINTF( "FF_SDDiskInit: FF_CreateIOManager: %s\n", ( const char * ) FF_GetErrMessage( xFFError ) );
                    FF_SDDiskDelete( pxDisk );
                    pxDisk = NULL;
                }
                else
                {
                    pxDisk->xStatus.bIsInitialised = pdTRUE;
                    pxDisk->xStatus.bPartitionNumber = xPartitionNumber;

                    if( FF_SDDiskMount( pxDisk ) == 0 )
                    {
                        FF_SDDiskDelete( pxDisk );
                        pxDisk = NULL;
                    }
                    else
                    {
                        if( pcName == NULL )
                        {
                            pcName = "/";
                        }

                        FF_FS_Add( pcName, pxDisk );
                        FF_PRINTF( "FF_SDDiskInit: Mounted SD-card as root \"%s\"\n", pcName );
                        FF_SDDiskShowPartition( pxDisk );
                    }
                } /* if( pxDisk->pxIOManager != NULL ) */
            }     /* if( xPlusFATMutex != NULL) */
        }         /* if( pxDisk != NULL ) */
    }             /* if( xSDCardStatus == pdPASS ) */

    return pxDisk;
}
    FF_Error_t xError;
    FF_Disk_t *pxDisk = NULL;
    FF_CreationParameters_t xParameters;

    /* Check the validity of the xIOManagerCacheSize parameter. */
    configASSERT( ( xIOManagerCacheSize % sdSECTOR_SIZE ) == 0 );
    configASSERT( ( xIOManagerCacheSize >= ( 2 * sdSECTOR_SIZE ) ) );

    /* Attempt to allocated the FF_Disk_t structure. */
    pxDisk = ( FF_Disk_t * ) pvPortMalloc( sizeof( FF_Disk_t ) );

    if( pxDisk != NULL )
    {
        /* It is advisable to clear the entire structure to zero after it has been
        allocated - that way the media driver will be compatible with future
        FreeRTOS-Plus-FAT versions, in which the FF_Disk_t structure may include
        additional members. */
        memset( pxDisk, '�', sizeof( FF_Disk_t ) );

        /* The pvTag member of the FF_Disk_t structure allows the structure to be
        extended to also include media specific parameters.  The only media
        specific data that needs to be stored in the FF_Disk_t structure for a
        RAM disk is the location of the RAM buffer itself - so this is stored
        directly in the FF_Disk_t's pvTag member. */
        pxDisk->pvTag = ( void * ) pucDataBuffer;

        /* The signature is used by the disk read and disk write functions to
        ensure the disk being accessed is a RAM disk. */
        pxDisk->ulSignature = ramSIGNATURE;

        /* The number of sectors is recorded for bounds checking in the read and
        write functions. */
        pxDisk->ulNumberOfSectors = ulSectorCount;

        /* Create the IO manager that will be used to control the RAM disk -
        the FF_CreationParameters_t structure completed with the required
        parameters, then passed into the FF_CreateIOManager() function. */
        memset (&xParameters, '�', sizeof xParameters);
        xParameters.pucCacheMemory = NULL;
        xParameters.ulMemorySize = xIOManagerCacheSize;
        xParameters.ulSectorSize = sdSECTOR_SIZE;
        xParameters.fnWriteBlocks = prvWriteRAM;
        xParameters.fnReadBlocks = prvReadRAM;
        xParameters.pxDisk = pxDisk;

        /* The driver is re-entrant as it just accesses RAM using memcpy(), so
        xBlockDeviceIsReentrant can be set to pdTRUE.  In this case the
        semaphore is only used to protect FAT data structures, and not the read
        and write function. */
        xParameters.pvSemaphore = ( void * ) xSemaphoreCreateRecursiveMutex();
        xParameters.xBlockDeviceIsReentrant = pdTRUE;


        pxDisk->pxIOManager = FF_CreateIOManger( &xParameters, &xError );

        if( ( pxDisk->pxIOManager != NULL ) && ( FF_isERR( xError ) == pdFALSE ) )
        {
            /* Record that the RAM disk has been initialised. */
            pxDisk->xStatus.bIsInitialised = pdTRUE;

            /* Create a partition on the RAM disk.  NOTE!  The disk is only
            being partitioned here because it is a new RAM disk.  It is
            known that the disk has not been used before, and cannot already
            contain any partitions.  Most media drivers will not perform
            this step because the media will already been partitioned and
            formatted. */
            xError = prvPartitionAndFormatDisk( pxDisk );

            if( FF_isERR( xError ) == pdFALSE )
            {
                /* Record the partition number the FF_Disk_t structure is, then
                mount the partition. */
                pxDisk->xStatus.bPartitionNumber = ramPARTITION_NUMBER;

                /* Mount the partition. */
                xError = FF_Mount( pxDisk, ramPARTITION_NUMBER );
            }

            if( FF_isERR( xError ) == pdFALSE )
            {
                /* The partition mounted successfully, add it to the virtual
                file system - where it will appear as a directory off the file
                system's root directory. */
                FF_FS_Add( pcName, pxDisk->pxIOManager );
            }
        }
        else
        {
            /* The disk structure was allocated, but the disk's IO manager could
            not be allocated, so free the disk again. */
            FF_RAMDiskDelete( pxDisk );
            pxDisk = NULL;
        }
    }

    return pxDisk;
}