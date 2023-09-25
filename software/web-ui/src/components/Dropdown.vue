<template>
  <div>
        <div class="mt-8 w-44">
            <label for="location" class="block text-sm font-medium leading-6 text-gray-600">{{title}}</label>
            <div class="mt-2">
                <select id="location" name="location" class="px-2 block w-full rounded-md border-0 py-1.5 text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 placeholder:text-gray-400 focus:ring-2 focus:ring-inset focus:ring-indigo-600 sm:text-sm sm:leading-6">
                    <option v-for="option in options" :key="option.title" :selected="modelValue == option.value" @click="$emit('update:modelValue', option.value)">{{option.title}}</option>
                    
                </select>
            </div>
        </div>
    </div>
</template>

<script>
export default {
    props: {
        options: Array,
        modelValue: String,
        title: String,
    },

}
</script>

<style>

</style>