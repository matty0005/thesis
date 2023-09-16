<template>
  <div class="">
    <div class="flex flex-col">
      <div class="mx-4 rounded-xl px-2 text-3xl font-bold text-gray-600 mt-4">RISCy Firewall</div>
      <div class="mx-4 my-2 rounded-xl px-2  text-gray-600 break-normal w-[68rem]">This website is hosted on a NeoRV32 RISC-V processor on a FPGA, namely the Xilinx Artix 7 100T FPGA - part number XC7A100T-1CSG324. This device features fully customised Ethernet hardware for both the MAC and filtering aspects. The server is written in Vue.js and is been hosted on a basic HTTP server running over the top of the FreeRTOS Plus TCP networking stack.</div>

      <div class="mx-4 my-2 rounded-xl px-2  text-gray-600 break-normal w-[68rem]">This project is part of the undergraduate thesis project for the Bachelor of Engineering (Honours) degree at the University of Queensland.</div>

      <div class="mx-4 rounded-xl px-2 text-gray-600">Here is a <a class="text-riscv-blue-l" target="_blank" href="https://github.com/matty0005/thesis">link to the repository</a>.</div>
      <div class="mx-4 my-2  rounded-xl px-2 text-gray-600">Developed and written by Matthew Gilpin</div>

   <div class="flex flex-row w-[68rem] my-4 mx-4 px-2">
      <div class="flex-wrap w-1/2">
        <div class="my-4 mx-2">
          The packet filter is a stateless filter that is capable of filtering packets based on the five common fields. These fields are the: source IP address, destination IP address, source port, destination port and protocol. The diagram on the right shows how this is done in hardware. 
        </div>
        <div class="my-4 mx-2">
          First the packet is sent into a shift register 2 bits wide (coming straight from the RMII interface) at 50MHz. This then allows the packet to be processed in 32bit chunks. A FSM keeps track of which byte is currently being processed. It then controls the hardware to perform the filtering. A comparator is used to compare the current 32bits with part of the rule which is stored in BRAM. The result of this comparison is then ANDed with the current status of the rule and is stored in a register. It needs to be ANDed with the current status (the result of previous comparisons for the rule) to ensure that the whole rule is matched. After all fields have been compared, all bits in the register are ORed together as any bit being 1 means that a rule has been fully matched.  
        </div>

        <div class="my-4 mx-2">
          To include this packet filter in the design, the input from the RMII interface is sent into both the packet filter and a shift register of size 224 long by 2bits wide. This then allows the packet filter to take 224 clock cycles to process the headers (which is the minimum needed for the header plus some buffer). The packet filter then just controls a simple multiplexer to forward or drop the incomming packet. This adds a total delay of 4.48 microseconds.
        </div>
      </div>
      <div class="relative flex-grow h-[27rem]">
        <img src="/images/PacketFilterArchitecture.png" class="absolute top-0 left-0 w-full h-full object-contain" />
      </div>
    </div>




    </div>
  </div>
</template>


