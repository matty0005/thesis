<template>
  <div class="home">
    <div class="flex flex-col">
      <div class="m-4 rounded-xl p-2 text-3xl font-bold text-gray-600">RISCy Firewall</div>
      <div class="m-4 rounded-xl p-2 text-gray-600">This website is hosted on a RISC-V processor on FPGA</div>
      <div class="flex flex-row mx-auto space-x-4">
        <Stats 
          title="Upload packets" 
          value="1024"
        />
        <Stats 
          title="Download packets" 
          value="16777216" 
          icon="M19.5 13.5L12 21m0 0l-7.5-7.5M12 21V3" 
        />
        <Stats 
          title="Blocked packets" 
          value="256" 
          icon="M12 9v3.75m0-10.036A11.959 11.959 0 013.598 6 11.99 11.99 0 003 9.75c0 5.592 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.31-.21-2.57-.598-3.75h-.152c-3.196 0-6.1-1.249-8.25-3.286zm0 13.036h.008v.008H12v-.008z"
          />
      </div>
    </div>
  </div>
</template>

<script>
import Stats from '../components/Stats.vue'

export default {
  components: {
    Stats
  }
}
</script>

<style>

</style>
