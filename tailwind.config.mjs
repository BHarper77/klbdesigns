/** @type {import('tailwindcss').Config} */
export default {
	content: ['./src/**/*.{astro,html,js,jsx,md,mdx,svelte,ts,tsx,vue}', './node_modules/flowbite/**/*.js'],
	theme: {
		extend: {
			boxShadow: {
				'card': '0 2px 8px rgba(0, 0, 0, 0.08)',
				'card-hover': '0 4px 16px rgba(0, 0, 0, 0.12)',
			},
			backgroundImage: {
				'overlay-gradient': 'linear-gradient(to top, rgba(0, 0, 0, 0.7), transparent)',
				'overlay-teal': 'linear-gradient(to top, rgba(93, 163, 153, 0.85), transparent)',
			},
		},
		fontFamily: {
			sans: ['Poppins', 'sans-serif'],
			serif: ['Playfair Display', 'Georgia', 'serif']
		},
		colors: {
			"main": "#5da399",
			"main-dark": "#4a8a81",
			"main-light": "#7ab8af",
			"secondary": "#3c3c3b",
			"overlay": {
				"dark": "rgba(0, 0, 0, 0.7)",
				"light": "rgba(0, 0, 0, 0.5)",
			},
			"white": "#ffffff",
			"black": "#000000",
			"gray": {
				"50": "#f9fafb",
				"100": "#f3f4f6",
				"200": "#e5e7eb",
				"300": "#d1d5db",
				"400": "#9ca3af",
				"500": "#6b7280",
				"600": "#4b5563",
				"700": "#374151",
				"800": "#1f2937",
				"900": "#111827",
			}
		}
	},
	plugins: [
		require('flowbite/plugin')
	],
}
