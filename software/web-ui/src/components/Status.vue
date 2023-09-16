<template>
  <div class="my-2 bg-gray-50 rounded-lg p-2 shadow w-1/2 mx-auto cursor-pointer hover:bg-gray-100">
    <div class="min-w-0 flex-auto">
      <div class="flex items-center gap-x-3">
        <div class="flex-none rounded-full p-1" :class="isOnline ? 'text-green-500 bg-green-200':'text-gray-500 bg-gray-200'">
          <div class="h-2 w-2 rounded-full bg-current"></div>
        </div>
        <h2 class="min-w-0 text-sm font-semibold leading-6 text-riscv-blue-d">
            <span class="truncate">{{title}}</span>
        </h2>
      </div>
      <div
        class="mt-3 flex items-center gap-x-2.5 text-xs leading-5 text-gray-400"
      >
        <p class="truncate">{{isOnline ? 'Online' : 'Offline'}}</p>
        <svg viewBox="0 0 2 2" class="h-0.5 w-0.5 flex-none fill-gray-300">
          <circle cx="1" cy="1" r="1" />
        </svg>
        <p class="whitespace-nowrap">{{subtitle}}</p>
      </div>
    </div>
  </div>
</template>

<script>
export default {
    props: {
        title: String,
        subtitle: String,
        status: Number
    },
    computed: {
        isOnline() {
            return this.status.toString() == '1'
        }
    }
    
};
</script>

<style>
</style>