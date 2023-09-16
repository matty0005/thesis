<template>
  <div class="config">
    <h1>This is a config page</h1>

    <!-- <button type="button" @click="enableFirewall" class="rounded-md bg-white/10 px-2.5 py-1.5 text-sm font-semibold text-gray-300 shadow-sm hover:bg-white/20 m-2">Enable</button> -->
    <!-- <button type="button" @click="getStats" class="rounded-md bg-white/10 px-2.5 py-1.5 text-sm font-semibold text-gray-300 shadow-sm hover:bg-white/20 m-2">Refresh Stats</button> -->
    <!-- <button type="button" class="rounded-md bg-white/10 px-2.5 py-1.5 text-sm font-semibold text-gray-300 shadow-sm hover:bg-white/20 m-2">Restart</button> -->
    <!-- <button type="button" class="rounded-md bg-white/10 px-2.5 py-1.5 text-sm font-semibold text-gray-300 shadow-sm hover:bg-white/20 m-2">Reset Phy</button> -->
        <button type="button" @click="loadRules" class="rounded bg-riscv-blue-l dark:bg-white/10 px-2 py-1 text-sm font-semibold text-white shadow-sm hover:bg-riscv-blue-d mx-2">Load Rules</button>

    <firewall-rule v-for="(rule, index) in rules" :key="index" :index="index" :initialRule="rule" />

   
  </div>
</template>

<script>
import FirewallRule from '../components/FirewallRule.vue';
export default {
  components: { FirewallRule },
    methods: {
        async getStats() {
            const response = await fetch('/api/stats');
            const data = await response.json();
            console.log("Data: ", data);
        },
        async enableFirewall() {
            const response = await fetch('/api/enable');
        },
        async loadRules() {
            try {
                const response = await fetch('/api/firewall');

                if (!response.ok) {
                throw new Error(`HTTP error! Status: ${response.status}`);
                }

                const rawData = await response.text();  // Get raw text data
                this.rules = rawData.split('\n').filter(rule => rule.trim());

            } catch (error) {
                console.error('Fetch error:', error.message);
            }
        }
    },
    data: () => {
        return {
            rules: ["00060A1401780A00009F0000000006","010000000000000000000000000000"],

        }
    }


}
</script>

<style>

</style>