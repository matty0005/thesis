<template>
    <div>
        <div class="mt-8">
            <label for="email" class="block text-sm font-medium leading-6 text-gray-600">{{title}}</label>
            <div class="mt-2">
                <input type="email" name="email" id="email" v-model="inputVal" class="px-2 block w-full rounded-md border-0 py-1.5 text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 placeholder:text-gray-400 focus:ring-2 focus:ring-inset focus:ring-indigo-600 sm:text-sm sm:leading-6" :placeholder="placeholder">
            </div>
        </div> 
    </div>
</template>

<script>
export default {
    props: {
        title: String,
        modelValue: String,
        placeholder: String,
    },
    computed: {
        inputVal: {
            get () {
                return this.modelValue
            },
            set (val) {
                this.$emit('update:modelValue', val.trim())
            }
        }
    }

}
</script>

<style>

</style>