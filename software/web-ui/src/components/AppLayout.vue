<template>
    <div class="bg-[#0ea3e7] relative flex min-h-screen flex-col justify-center overflow-hidden dark:bg-slate-900 bg-gray-50 py-6 sm:py-12 ">
    <!-- <div class=" relative flex min-h-screen flex-col justify-center overflow-hidden dark:bg-slate-900 bg-gray-50 py-6 sm:py-12 "> -->
        <div class="absolute inset-0 bg-gradient-to-br from-riscv-blue-l via-[#0a6b7c] to-riscv-blue-l "></div>
        <!-- <div class="absolute inset-0 bg-[url(https://cdn.mattgilpin.au/thesis/assets/grid.svg)] dark:bg-[url(https://cdn.mattgilpin.au/thesis/assets/grid-dark.svg)] bg-center [mask-image:linear-gradient(180deg,white,rgba(255,255,255,0)) "></div> -->
        <div class="relative dark:bg-[#1a1a1a] bg-white pb-8 pt-10 shadow-xl ring-1 ring-gray-900/5 sm:mx-auto  sm:rounded-lg  ">



            <div class="mx-auto">
                <slot />
            </div>
        </div>
    </div>
</template>

<script>
export default {

}
</script>

<style>

</style>