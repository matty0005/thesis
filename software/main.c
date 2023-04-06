#include <stdint.h>

/* FreeRTOS kernel includes. */
#include <FreeRTOS.h>
#include <semphr.h>
#include <queue.h>
#include <task.h>

/* NEORV32 includes. */
#include <neorv32.h>

#define BAUD_RATE 19200


extern void main_project( void );


extern void freertos_risc_v_trap_handler( void );

/*
 * Prototypes for the standard FreeRTOS callback/hook functions implemented
 * within this file.  See https://www.freertos.org/a00016.html
 */
void vApplicationMallocFailedHook( void );
void vApplicationIdleHook( void );
void vApplicationStackOverflowHook( TaskHandle_t pxTask, char *pcTaskName );


void vApplicationTickHook(void);



/* Prepare hardware to run the demo. */
static void prvSetupHardware( void );

/* System */
void vToggleLED( void );
void vSendString( const char * pcString );





int main( void )
{
  prvSetupHardware();

    /* say hi */
  neorv32_uart0_printf("FreeRTOS %s on NEORV32 Demo\n\n", tskKERNEL_VERSION_NUMBER);

  main_project();

}





/* Handle NEORV32-specific interrupts */
void freertos_risc_v_application_interrupt_handler(void) {

  // acknowledge/clear ALL pending interrupt sources here - adapt this for your setup
  neorv32_cpu_csr_write(CSR_MIP, 0);

  // debug output - Use the value from the mcause CSR to call interrupt-specific handlers
  neorv32_uart0_printf("\n<NEORV32-IRQ> mcause = 0x%x </NEORV32-IRQ>\n", neorv32_cpu_csr_read(CSR_MCAUSE));
}

/* Handle NEORV32-specific exceptions */
void freertos_risc_v_application_exception_handler(void) {

  // debug output - Use the value from the mcause CSR to call exception-specific handlers
  neorv32_uart0_printf("\n<NEORV32-EXC> mcause = 0x%x </NEORV32-EXC>\n", neorv32_cpu_csr_read(CSR_MCAUSE));
}

/*-----------------------------------------------------------*/

static void prvSetupHardware( void )
{
  // install the freeRTOS trap handler
  neorv32_cpu_csr_write(CSR_MTVEC, (uint32_t)&freertos_risc_v_trap_handler);

  // clear GPIO.out port
  neorv32_gpio_port_set(0);

  // init UART at default baud rate, no parity bits, ho hw flow control
  neorv32_uart0_setup(BAUD_RATE, PARITY_NONE, FLOW_CONTROL_NONE);

  // check clock tick configuration
  if (NEORV32_SYSINFO.CLK != (uint32_t)configCPU_CLOCK_HZ) {
    neorv32_uart0_printf("Warning! Incorrect 'configCPU_CLOCK_HZ' configuration!\n"
                         "Is %u Hz but should be %u Hz.\n\n", (uint32_t)configCPU_CLOCK_HZ, NEORV32_SYSINFO.CLK);
  }

  // check available hardware ISA extensions and compare with compiler flags
  neorv32_rte_check_isa(0); // silent = 0 -> show message if isa mismatch

  // enable and configure further NEORV32-specific modules if required
  // ...

  // enable NEORV32-specific interrupts if required
  // ...
}

/*-----------------------------------------------------------*/

void vToggleLED( void )
{
	neorv32_gpio_pin_toggle(0);
}

/*-----------------------------------------------------------*/

void vSendString( const char * pcString )
{
	neorv32_uart0_puts( ( const char * ) pcString );
}

/*-----------------------------------------------------------*/

void vApplicationMallocFailedHook( void )
{
	/* vApplicationMallocFailedHook() will only be called if
	configUSE_MALLOC_FAILED_HOOK is set to 1 in FreeRTOSConfig.h.  It is a hook
	function that will get called if a call to pvPortMalloc() fails.
	pvPortMalloc() is called internally by the kernel whenever a task, queue,
	timer or semaphore is created.  It is also called by various parts of the
	demo application.  If heap_1.c or heap_2.c are used, then the size of the
	heap available to pvPortMalloc() is defined by configTOTAL_HEAP_SIZE in
	FreeRTOSConfig.h, and the xPortGetFreeHeapSize() API function can be used
	to query the size of free heap space that remains (although it does not
	provide information on how the remaining heap might be fragmented). */
	taskDISABLE_INTERRUPTS();
  neorv32_uart0_puts("FreeRTOS_FAULT: vApplicationMallocFailedHook (solution: increase 'configTOTAL_HEAP_SIZE' in FreeRTOSConfig.h)\n");
	__asm volatile( "ebreak" );
	for( ;; );
}
/*-----------------------------------------------------------*/

void vApplicationIdleHook( void )
{
	/* vApplicationIdleHook() will only be called if configUSE_IDLE_HOOK is set
	to 1 in FreeRTOSConfig.h.  It will be called on each iteration of the idle
	task.  It is essential that code added to this hook function never attempts
	to block in any way (for example, call xQueueReceive() with a block time
	specified, or call vTaskDelay()).  If the application makes use of the
	vTaskDelete() API function (as this demo application does) then it is also
	important that vApplicationIdleHook() is permitted to return to its calling
	function, because it is the responsibility of the idle task to clean up
	memory allocated by the kernel to any task that has since been deleted. */
  neorv32_cpu_sleep();
}

/*-----------------------------------------------------------*/

void vApplicationStackOverflowHook( TaskHandle_t pxTask, char *pcTaskName )
{
	( void ) pcTaskName;
	( void ) pxTask;

	/* Run time stack overflow checking is performed if
	configCHECK_FOR_STACK_OVERFLOW is defined to 1 or 2.  This hook
	function is called if a stack overflow is detected. */
	taskDISABLE_INTERRUPTS();
  neorv32_uart0_puts("FreeRTOS_FAULT: vApplicationStackOverflowHook\n");
	__asm volatile( "ebreak" );
	for( ;; );
}



/*-----------------------------------------------------------*/

/* This handler is responsible for handling all interrupts. Only the machine timer interrupt is handled by the kernel. */
void SystemIrqHandler( uint32_t mcause )
{
  neorv32_uart0_printf("freeRTOS: Unknown interrupt (0x%x)\n", mcause);
}

void vApplicationTickHook(void)
{
    // Leave empty
}