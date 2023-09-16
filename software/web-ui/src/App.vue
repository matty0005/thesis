

<template>
  <AppLayout >
      <div class="wrapper w-[76rem]">
        <nav class="flex flex-row mb-8 mx-10">
          <RouterLink class="mx-2 hover:bg-white text-riscv-blue-d hover:text-riscv-blue-l text-2xl font-bold flex-grow" to="/">RISCy Firewall</RouterLink>
          <RouterLink class="mx-2 text-white bg-riscv-blue-l hover:bg-riscv-blue-d p-2 rounded-lg px-4" to="/about">About</RouterLink>
          <RouterLink class="mx-2 text-white bg-riscv-blue-l hover:bg-riscv-blue-d p-2 rounded-lg px-4" to="/config">Config</RouterLink>
        </nav>
      </div>

      <div class="h-48 bg-riscv-blue-d mb-8">
        <div class="text-white font-semibold  my-auto text-4xl text-center">
          Config
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
  }
}

</script>

<style scoped>


</style>
