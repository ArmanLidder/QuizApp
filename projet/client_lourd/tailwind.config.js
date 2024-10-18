/** @type {import('tailwindcss').Config} */
module.exports = {
  content: ['./src/**/*.{html,ts}', './projects/**/*.{html,ts}'],
  theme: {
    extend: {
      fontFamily:{
        poppins:["Poppins", "sans-serif"]
      }
    },
  },
  plugins: [],
}
