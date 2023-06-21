

<template>
  <AppLayout >
      <div class="wrapper w-[24rem]">
        <nav>
          <RouterLink class="mx-2" to="/">Home</RouterLink>
          <RouterLink class="mx-2" to="/about">About</RouterLink>
          <RouterLink class="mx-2" to="/config">Config</RouterLink>
        </nav>
      </div>

    <RouterView />
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
