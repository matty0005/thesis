<template>
  <div>
    <div class="relative flex items-start">
      <div class="flex h-6 items-center">
        <input id="comments" v-model="inputVal" aria-describedby="comments-description" :name="title" type="checkbox" class="h-4 w-4 rounded border-gray-300 text-indigo-600 focus:ring-indigo-600">
      </div>
      <div class="ml-3 text-sm leading-6">
        <label for="comments" class="font-medium text-gray-900 dark:text-gray-200">{{title}}</label>
      </div>
    </div>

  </div>
</template>

<script>
export default {
    props: {
        title: String,
        modelValue: Boolean
    },
    computed: {
        inputVal: {
            get () {
                return this.modelValue
            },
            set (val) {
                this.$emit('update:modelValue', val)
            }
        }
    }
}
</script>

<style>

</style>