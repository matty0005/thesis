<template>
  <div class="home ">
    <div class="flex flex-col ">
       <div class="flex flex-row">
        <div class="flex-grow"></div>
        <button type="button" @click="getStats" class="rounded-lg bg-gray-200 dark:bg-white/10 px-4 py-2 text-sm font-semibold text-gray-600 shadow-sm hover:bg-riscv-blue-d mx-2">Refresh</button>
        <!-- <button type="button" @click="filterRules" class="rounded-lg bg-riscv-blue-l dark:bg-white/10 px-2 py-1 text-sm font-semibold text-white shadow-sm hover:bg-riscv-blue-d mx-2">Load Rules</button> -->
    </div>
      <div class="text-2xl text-gray-700 font-semibold w-8/12 mx-auto ">Statistics</div>
      <div class=" text-gray-500 w-8/12 mx-auto ">The current recorded statistics measured by the firewall. These do not update automatically, instead click the refresh button.</div>
      <div class="flex flex-row mx-auto space-x-4 mt-2">
        <Stats 
          title="Total packets" 
          :value="packetTotal" 
          icon="M19.5 13.5L12 21m0 0l-7.5-7.5M12 21V3" 
        />
        <Stats 
          title="Blocked packets" 
          customClass="bg-red-500"
          :value="blockedTotal" 
          icon="M12 9v3.75m0-10.036A11.959 11.959 0 013.598 6 11.99 11.99 0 003 9.75c0 5.592 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.31-.21-2.57-.598-3.75h-.152c-3.196 0-6.1-1.249-8.25-3.286zm0 13.036h.008v.008H12v-.008z"
          />

        <Stats 
          title="Percentage blocked" 
          customClass="bg-yellow-500"
          :value="`${packetTotal == 0 ? 0: Math.round(blockedTotal/packetTotal * 10000) / 100}%`" 
          icon="M9 14.25l6-6m4.5-3.493V21.75l-3.75-1.5-3.75 1.5-3.75-1.5-3.75 1.5V4.757c0-1.108.806-2.057 1.907-2.185a48.507 48.507 0 0111.186 0c1.1.128 1.907 1.077 1.907 2.185zM9.75 9h.008v.008H9.75V9zm.375 0a.375.375 0 11-.75 0 .375.375 0 01.75 0zm4.125 4.5h.008v.008h-.008V13.5zm.375 0a.375.375 0 11-.75 0 .375.375 0 01.75 0z"
          />
      </div>

    <div class="text-2xl text-gray-700 font-semibold w-8/12 mx-auto mt-12">Status</div>
    <div class=" text-gray-500 w-8/12 mx-auto ">View the current status of the different tasks and states. Some tasks can be controlled by clicking on them.</div>
      <div class="w-1/2 mx-auto mb-8 space-y-4 mt-2">
        <Status title="UDP Ping server" subtitle="Click to toggle state" :status="status.udp_ping" v-on:click="statusClick('udp_ping')"/>
        <Status title="Command Line Interface" subtitle="Click to toggle state" :status="status.cli" v-on:click="statusClick('cli')"/>
        <Status title="Packet filter" subtitle="Use onboard switch" :status="status.packet_filter"/>
      </div>
    </div>
  </div>
</template>

<script>
import Stats from '../components/Stats.vue'
import Status from '../components/Status.vue'

export default {
  components: {
    Stats,
    Status
  },
  data: () => {
    return {
      packetTotal: 1234,
      blockedTotal: 54,
      status: {
        udp_ping: 1,
        cli: 0,
        packet_filter: 1
      }
    }
  },
  mounted() {
    this.getStats()
  },
  methods: {
    async statusClick(type) {
      const data = type
      var url = '/api/' + type + '/toggle'

      fetch(url, {
          method: 'POST',
          headers: {
              'Content-Type': 'text/plain'
          },
          body: data
      });

      this.status[type] = this.status[type] == '0' ? '1' : '0'
    },
    async getStats() {

      try {
          const response = await fetch('/api/stats');

          if (!response.ok) {
            throw new Error(`HTTP error! Status: ${response.status}`);
          }

          const rawData = await response.text();  // Get raw text data
          const data = rawData.split(',')

          if (data.length < 5) {
            return
          }

          if (typeof data[0] != Number) {
            data[0] = 0
            data[1] = 0
            data[2] = 0
            data[3] = 0
            data[4] = 0
          }

          this.packetTotal = data[0]
          this.blockedTotal = data[1]
          this.status.udp_ping = data[2]
          this.status.cli = data[3]
          this.status.packet_filter = data[4]



      } catch (error) {
        this.packetTotal = 10
        this.blockedTotal = 1
        console.error('Fetch error:', error.message);
      }
    }
  }
}
</script>

<style>

</style>
