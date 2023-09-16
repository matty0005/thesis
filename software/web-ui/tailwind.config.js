/** @type {import('tailwindcss').Config} */
module.exports = {
  content: ["./src/**/*.{html,js,vue}"],
  theme: {
    extend: {
      colors: {
        'riscv-blue-l': '#0a3799',
        'riscv-blue-d': '#011e41',
        'riscv-yellow-d': '#ffc72c',
        'riscv-yellow-l': '#fdda64',
        'riscv-pink-l': '#feb9bb1',
        'riscv-pink-d': '#cb007b',
        'nice-yellow' : '#ffcc00'
      },
    },
  },
  plugins: [],
}