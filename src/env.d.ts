/// <reference path="../.astro/types.d.ts" />
/// <reference types="astro/client" />

interface ImportMetaEnv {
	CONTENTFUL_ACCESS_TOKEN: string
	CONTENTFUL_SPACE_ID: string
}

interface Window {
	posthog?: {
		__loaded?: boolean
		capture: (event: string, properties?: Record<string, unknown>) => void
	}
}