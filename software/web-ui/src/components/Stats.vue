<template>
        <div class="relative overflow-hidden rounded-lg bg-white px-4 pb-6 pt-5 shadow sm:px-6 sm:pt-6">
            <dt>
                <div class="absolute rounded-md p-3" :class="customClass">
                <svg class="h-6 w-6 text-white" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" aria-hidden="true">
                    <path stroke-linecap="round" stroke-linejoin="round" :d="icon" />
                </svg>
                </div>
                <p class="ml-16 truncate text-sm font-medium text-gray-500">{{title}}</p>
            </dt>
            <dd class="ml-16 flex items-baseline">
                <p class="text-2xl font-semibold text-gray-900">{{formatedValue}}</p>
            </dd>
        </div>
</template>

<script>
export default {
    props: {
        icon: {
            type: String,
            default: "M12 19.5v-15m0 0l-6.75 6.75M12 4.5l6.75 6.75"
        },
        title: String,
        value: String,
        customClass: {
            type: String,
            default: "bg-riscv-blue-l"
        }
    },
    computed: {
        formatedValue() {
            if (this.value.toString().includes("%")) {
                return this.value
            }
            return this.value.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
        }
    }

}
</script>

<style>

</style>