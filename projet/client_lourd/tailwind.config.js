/** @type {import('tailwindcss').Config} */
module.exports = {
  content: ['./src/**/*.{html,ts}', './projects/**/*.{html,ts}'],
  theme: {
    extend: {
      fontFamily:{
        poppins:["Poppins", "sans-serif"]
      },
      colors: {
        primary:"var(--color-primary)",
        secondary:"var(--color-secondary)",
        bgPrimary:"var(--color-bg-primary)",
        tBase:"var(--color-text-base)"
      }
    },
  },
  plugins: [],
}
