/** @type {import('tailwindcss').Config} */
module.exports = {
  content: ['./src/**/*.{html,ts,scss}', './projects/**/*.{html,ts,scss}'],
  theme: {
    extend: {
      fontFamily:{
        poppins:["Poppins", "sans-serif"]
      },
      colors: {
        primary:"var(--color-primary)",
        secondary:"var(--color-secondary)",
        bgPrimary:"var(--color-bg-primary)",
        bgSecondary:"var(--color-bg-secondary)",
        bgButton:"var(--color-bg-button)",
        error:"var(--color-error)",
      }
    },
  },
  plugins: [],
}
