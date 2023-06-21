<template>
  <div class="config">
    <h1>This is a config page</h1>

    <button type="button" @click="enableFirewall" class="rounded-md bg-white/10 px-2.5 py-1.5 text-sm font-semibold text-white shadow-sm hover:bg-white/20 m-2">Enable</button>
    <button type="button" @click="getStats" class="rounded-md bg-white/10 px-2.5 py-1.5 text-sm font-semibold text-white shadow-sm hover:bg-white/20 m-2">Refresh Stats</button>
    <button type="button" class="rounded-md bg-white/10 px-2.5 py-1.5 text-sm font-semibold text-white shadow-sm hover:bg-white/20 m-2">Restart</button>
    <button type="button" class="rounded-md bg-white/10 px-2.5 py-1.5 text-sm font-semibold text-white shadow-sm hover:bg-white/20 m-2">Reset Phy</button>
    <button type="button" class="rounded-md bg-white/10 px-2.5 py-1.5 text-sm font-semibold text-white shadow-sm hover:bg-white/20 m-2">Save</button>

    <div class="mt-8">
        <label for="email" class="block text-sm font-medium leading-6 text-gray-600">IP Address</label>
        <div class="mt-2">
            <input type="email" name="email" id="email" class="block w-full rounded-md border-0 py-1.5 text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 placeholder:text-gray-400 focus:ring-2 focus:ring-inset focus:ring-indigo-600 sm:text-sm sm:leading-6" placeholder="10.0.0.10">
        </div>
    </div>


    <div class="mt-8">
        <label for="comment" class="block text-sm font-medium leading-6 text-gray-600">Firewall Rules</label>
        <div class="mt-2">
            <textarea rows="4" name="comment" id="comment" class="block w-full rounded-md border-0 py-1.5 text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 placeholder:text-gray-400 focus:ring-2 focus:ring-inset focus:ring-indigo-600 sm:text-sm sm:leading-6"></textarea>
        </div>
    </div>
  </div>
</template>

<script>
export default {
    methods: {
        async getStats() {
            const response = await fetch('/api/stats');
            const data = await response.json();
            console.log("Data: ", data);
        },
        async enableFirewall() {
            const response = await fetch('/api/enable');
        }
    },


}
</script>

<style>

</style>