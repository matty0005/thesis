

<template>
  <AppLayout >
      <div class=" w-[76rem]">
        <nav class="flex flex-row mb-8 mx-10">
          <RouterLink class="mx-2 hover:bg-white text-riscv-blue-d hover:text-riscv-blue-l text-2xl font-bold flex-grow" to="/">RISC<span class="font-bold text-[#ffc72c]">y</span> Firewall</RouterLink>
          <RouterLink class="mx-2 text-riscv-blue-d hover:bg-gray-200 p-2 rounded-lg px-4" to="/about">About</RouterLink>
          <RouterLink class="mx-2 text-riscv-blue-d hover:bg-gray-200 p-2 rounded-lg px-4" to="/config">Config</RouterLink>
        </nav>
      </div>

      <div class="h-40 bg-riscv-blue-d mb-8">
        <div class="text-white mt-4 font-semibold pt-8 my-auto text-4xl text-center ">
          {{pageTitle}}
        </div>
        <div class="text-white mt-2 my-auto text-xl text-center ">
          {{pageDescription}}
        </div>
      </div>

    <RouterView class="mx-10 h-[48rem]" />
  </AppLayout>
</template>

<script>
import { RouterLink, RouterView } from 'vue-router'
import AppLayout from './components/AppLayout.vue'

export default {
  layout: [AppLayout],
  components: {
    RouterLink,
    RouterView,
    AppLayout
  },
  data: () => {
    return {
      pageTitle: 'RISCy Firewall',
      pageDescription: ''
    }
  },
  watch: {
    '$route': function(to, from) {
      switch(to.path) {
        case '/':
          this.pageTitle = 'RISCy Firewall';
          this.pageDescription = 'Welcome to RISCy Firewall, a RISC-V based firewall running on top of a Xilinx Artix 7 FPGA';
          break;
        case '/about':
          this.pageTitle = 'About';
          this.pageDescription = 'More details about the project.';
          break;
        case '/config':
          this.pageTitle = 'Config';
          this.pageDescription = 'Manage and configure the firewall settings';
          break;
      }
    }
  },
}

</script>

<style scoped>


</style>
 