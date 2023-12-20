/** @type {import('tailwindcss').Config} */
export default {
	content: ['./src/**/*.{astro,html,js,jsx,md,mdx,svelte,ts,tsx,vue}', './node_modules/flowbite/**/*.js'],
	theme: {
		extend: {},
		fontFamily: {
			serif: ['Poppins', "sans-serif"]
		},
		colors: {
			"main": "#5da399",
			"links": "#3c3c3b"
		}
	},
	plugins: [
		require('flowbite/plugin')
	],
}
