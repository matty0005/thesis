<template>
  <div class="overflow-auto">
    <!-- <button type="button" @click="enableFirewall" class="rounded-md bg-white/10 px-2.5 py-1.5 text-sm font-semibold text-gray-300 shadow-sm hover:bg-white/20 m-2">Enable</button> -->
    <!-- <button type="button" @click="getStats" class="rounded-md bg-white/10 px-2.5 py-1.5 text-sm font-semibold text-gray-300 shadow-sm hover:bg-white/20 m-2">Refresh Stats</button> -->
    <!-- <button type="button" class="rounded-md bg-white/10 px-2.5 py-1.5 text-sm font-semibold text-gray-300 shadow-sm hover:bg-white/20 m-2">Restart</button> -->
    <!-- <button type="button" class="rounded-md bg-white/10 px-2.5 py-1.5 text-sm font-semibold text-gray-300 shadow-sm hover:bg-white/20 m-2">Reset Phy</button> -->
    <div class="flex flex-row">
        <button type="button" @click="loadRules" class="rounded-lg bg-gray-200 dark:bg-white/10 px-4 py-2 text-sm font-semibold text-gray-600 shadow-sm hover:bg-riscv-blue-d mx-2">Load Rules</button>
        <!-- <button type="button" @click="filterRules" class="rounded-lg bg-riscv-blue-l dark:bg-white/10 px-2 py-1 text-sm font-semibold text-white shadow-sm hover:bg-riscv-blue-d mx-2">Load Rules</button> -->
        <div class="flex-grow"></div>
        <button type="button" @click="saveRules" class="rounded-lg bg-riscv-blue-l dark:bg-white/10 px-4 py-2 text-sm font-semibold text-white shadow-sm hover:bg-riscv-blue-d mx-2">Save Rules</button>
    </div>

    <div class="bg-gray-100 rounded-lg my-4 shadow-inner py-2 px-8">
        <div class="pb-8" v-if="viewableRules.length != 0">
            <div v-for="(rule, index) in viewableRules" :key="index">
                <firewall-rule :index="index" v-model="viewableRules[index]" @remove="removeRule(index)"/>
            </div>
        </div>
        <div v-if="viewableRules.length == 0" class="italic text-gray-500 text-center py-4">There are currently no rules</div>
    </div>

    <div v-if="viewableRules.length <= rules.length"  class="flex flex-row-reverse text-gray-600 my-8 mx-4">
        <div class="flex flex-row cursor-pointer" @click="addRule">
            <div class="my-auto mr-3 text-lg">
                Add rule
            </div>
            <div class="flex items-center justify-center  bg-gray-200 rounded-full w-8 h-8">
                <svg class="h-6 w-6" aria-hidden="true" fill="none" stroke="currentColor" stroke-width="1.5" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                    <path d="M12 4.5v15m7.5-7.5h-15" stroke-linecap="round" stroke-linejoin="round"></path>
                </svg>
            </div>
        </div>
    </div>

   
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
                this.filterRules();

            } catch (error) {
                console.error('Fetch error:', error.message);
            }
        },
        saveRules() {
            // Remove the first 2 digits of each rule and replace with index
            const rules = this.viewableRules.map((rule, index) => index.toString().padStart(2, '0') + rule.substring(2));
            const rulesLen = rules.length;

            // Add remaining number of rules - based on this.rules.length
            const remainingRules = this.rules.length - rules.length;
            for (let i = 0; i < remainingRules; i++) {
                rules.push((rulesLen + i).toString().padStart(2, '0') + "0000000000000000000000000000");
            }

            const data = rules.join('\n');

            fetch('/api/firewall/all', {
                method: 'POST',
                headers: {
                    'Content-Type': 'text/plain'
                },
                body: data
            });
        },
        filterRules() {
            this.viewableRules = this.rules.filter(rule => !/^0+$/.test(rule.substring(2)));
        },

        addRule() {
            this.viewableRules.push(this.viewableRules.length.toString().padStart(2, '0') + "0000000000000000000000000000")
        },
        removeRule(index) {
            this.viewableRules.splice(index, 1);
        }
    },

    data: () => {
        return {
            rules: ["00060A1401780A00009F0000000006","010000000000000000000000000000","020000000000000000000000000000","030000000000000000000000000000","040000000000000000000000000000","050000000000000000000000000000","060000000000000000000000000000","070000000000000000000000000000"],
            viewableRules: []

        }
    }


}
</script>

<style>

</style>