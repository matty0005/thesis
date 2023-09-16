# *****************************************************************************
# USER CONFIGURATION
# *****************************************************************************
# User's application sources (*.c, *.cpp, *.s, *.S); add additional files here
APP_SRC ?= $(wildcard ./*.c) $(wildcard ./*.s) $(wildcard ./*.cpp) $(wildcard ./*.S)

# User's application include folders (don't forget the '-I' before each entry)
APP_INC ?= -I .
# User's application include folders - for assembly files only (don't forget the '-I' before each entry)
ASM_INC ?= -I .

# Optimization
EFFORT ?= -Os

# CPU architecture and ABI
MARCH ?= rv32i
MABI  ?= ilp32

# User flags for additional configuration (will be added to compiler flags)
USER_FLAGS ?=  "-Wl,--defsym,__neorv32_ram_size=168k,--defsym,__neorv32_rom_size=256k"
# *****************************************************************************


# -----------------------------------------------------------------------------
# FreeRTOS
# -----------------------------------------------------------------------------
FREERTOS_HOME ?= /home/matt/FreeRTOS

# FreeRTOS RISC-V specific
APP_SRC += $(wildcard $(FREERTOS_HOME)/FreeRTOS/Source/portable/GCC/RISC-V/*.c)
APP_SRC += $(FREERTOS_HOME)/FreeRTOS/Source/portable/GCC/RISC-V/portASM.S

APP_INC += -I $(FREERTOS_HOME)/FreeRTOS/Source/portable/GCC/RISC-V

# FreeRTOS core
APP_SRC += $(wildcard $(FREERTOS_HOME)/FreeRTOS/Source/*.c)
APP_SRC += $(wildcard $(FREERTOS_HOME)/FreeRTOS/Source/portable/MemMang/heap_4.c) # Can change to heap 5 if needed

APP_INC += -I $(FREERTOS_HOME)/FreeRTOS/Source/include

APP_INC += -I $(FREERTOS_HOME)/FreeRTOS/Demo/Common/include

# NEORV32 specific
ASM_INC += -DportasmHANDLE_INTERRUPT=SystemIrqHandler

APP_INC += -I chip_specific_extensions/neorv32

ASM_INC += -I chip_specific_extensions/neorv32




# -----------------
# FreeRTOS-Plus-CLI
# -----------------
APP_SRC += $(FREERTOS_HOME)/FreeRTOS-Plus/Source/FreeRTOS-Plus-CLI/FreeRTOS_CLI.c
APP_INC += -I $(FREERTOS_HOME)/FreeRTOS-Plus/Source/FreeRTOS-Plus-CLI


# -----------------
# FreeRTOS-Plus-TCP
# -----------------
APP_SRC += $(FREERTOS_HOME)/FreeRTOS-Plus/Source/FreeRTOS-Plus-TCP/source/FreeRTOS_ARP.c
APP_SRC += $(FREERTOS_HOME)/FreeRTOS-Plus/Source/FreeRTOS-Plus-TCP/source/FreeRTOS_DHCP.c
APP_SRC += $(FREERTOS_HOME)/FreeRTOS-Plus/Source/FreeRTOS-Plus-TCP/source/FreeRTOS_DNS.c
APP_SRC += $(FREERTOS_HOME)/FreeRTOS-Plus/Source/FreeRTOS-Plus-TCP/source/FreeRTOS_IP.c
APP_SRC += $(FREERTOS_HOME)/FreeRTOS-Plus/Source/FreeRTOS-Plus-TCP/source/FreeRTOS_Sockets.c
APP_SRC += $(FREERTOS_HOME)/FreeRTOS-Plus/Source/FreeRTOS-Plus-TCP/source/FreeRTOS_Stream_Buffer.c
APP_SRC += $(FREERTOS_HOME)/FreeRTOS-Plus/Source/FreeRTOS-Plus-TCP/source/FreeRTOS_TCP_IP.c
APP_SRC += $(FREERTOS_HOME)/FreeRTOS-Plus/Source/FreeRTOS-Plus-TCP/source/FreeRTOS_TCP_WIN.c
APP_SRC += $(FREERTOS_HOME)/FreeRTOS-Plus/Source/FreeRTOS-Plus-TCP/source/FreeRTOS_UDP_IP.c



APP_SRC += $(FREERTOS_HOME)/FreeRTOS-Plus/Source/FreeRTOS-Plus-TCP/source/FreeRTOS_DNS_Cache.c
APP_SRC += $(FREERTOS_HOME)/FreeRTOS-Plus/Source/FreeRTOS-Plus-TCP/source/FreeRTOS_DNS_Callback.c
APP_SRC += $(FREERTOS_HOME)/FreeRTOS-Plus/Source/FreeRTOS-Plus-TCP/source/FreeRTOS_DNS_Networking.c
APP_SRC += $(FREERTOS_HOME)/FreeRTOS-Plus/Source/FreeRTOS-Plus-TCP/source/FreeRTOS_DNS_Parser.c
APP_SRC += $(FREERTOS_HOME)/FreeRTOS-Plus/Source/FreeRTOS-Plus-TCP/source/FreeRTOS_ICMP.c
APP_SRC += $(FREERTOS_HOME)/FreeRTOS-Plus/Source/FreeRTOS-Plus-TCP/source/FreeRTOS_IP_Timers.c
APP_SRC += $(FREERTOS_HOME)/FreeRTOS-Plus/Source/FreeRTOS-Plus-TCP/source/FreeRTOS_IP_Utils.c
APP_SRC += $(FREERTOS_HOME)/FreeRTOS-Plus/Source/FreeRTOS-Plus-TCP/source/FreeRTOS_TCP_Reception.c
APP_SRC += $(FREERTOS_HOME)/FreeRTOS-Plus/Source/FreeRTOS-Plus-TCP/source/FreeRTOS_TCP_State_Handling.c
APP_SRC += $(FREERTOS_HOME)/FreeRTOS-Plus/Source/FreeRTOS-Plus-TCP/source/FreeRTOS_TCP_Transmission.c
APP_SRC += $(FREERTOS_HOME)/FreeRTOS-Plus/Source/FreeRTOS-Plus-TCP/source/FreeRTOS_TCP_Utils.c
APP_SRC += $(FREERTOS_HOME)/FreeRTOS-Plus/Source/FreeRTOS-Plus-TCP/source/FreeRTOS_Tiny_TCP.c

APP_SRC += $(FREERTOS_HOME)/FreeRTOS-Plus/Source/FreeRTOS-Plus-TCP/source/portable/BufferManagement/BufferAllocation_2.c

APP_INC += -I $(FREERTOS_HOME)/FreeRTOS-Plus/Source/FreeRTOS-Plus-TCP/source/include
APP_INC += -I $(FREERTOS_HOME)/FreeRTOS-Plus/Source/FreeRTOS-Plus-TCP/source/portable/Compiler/GCC


# -----------------
# FreeRTOS-Plus-FAT
# -----------------
APP_SRC += $(FREERTOS_HOME)/FreeRTOS-FAT/ff_crc.c
# APP_SRC += $(FREERTOS_HOME)/FreeRTOS-FAT/ff_dev_support.c
APP_SRC += $(FREERTOS_HOME)/FreeRTOS-FAT/ff_dir.c
APP_SRC += $(FREERTOS_HOME)/FreeRTOS-FAT/ff_error.c
APP_SRC += $(FREERTOS_HOME)/FreeRTOS-FAT/ff_fat.c
APP_SRC += $(FREERTOS_HOME)/FreeRTOS-FAT/ff_file.c
APP_SRC += $(FREERTOS_HOME)/FreeRTOS-FAT/ff_format.c
APP_SRC += $(FREERTOS_HOME)/FreeRTOS-FAT/ff_ioman.c
APP_SRC += $(FREERTOS_HOME)/FreeRTOS-FAT/ff_locking.c
APP_SRC += $(FREERTOS_HOME)/FreeRTOS-FAT/ff_memory.c
APP_SRC += $(FREERTOS_HOME)/FreeRTOS-FAT/ff_stdio.c
APP_SRC += $(FREERTOS_HOME)/FreeRTOS-FAT/ff_string.c
APP_SRC += $(FREERTOS_HOME)/FreeRTOS-FAT/ff_sys.c
APP_SRC += $(FREERTOS_HOME)/FreeRTOS-FAT/ff_time.c

APP_INC += -I $(FREERTOS_HOME)/FreeRTOS-FAT/include
APP_INC += -I $(FREERTOS_HOME)/FreeRTOS-FAT/portable/common



# Modify this variable to fit your NEORV32 setup (neorv32 home folder)
NEORV32_HOME ?= /home/matt/code/neorv32
# NEORV32_HOME ?= /home/matt/riscv/neorv32

include ./filelist.mk

include $(NEORV32_HOME)/sw/common/common.mk
