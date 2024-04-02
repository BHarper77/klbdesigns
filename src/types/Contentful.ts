export type ContentfulResponse = {
	sys: {
		type: string
	}
	total: number
	skip: number
	limit: number
	items: Array<{
		metadata: {
			tags: Array<{
				sys: {
					type: string
					linkType: string
					id: string
				}
			}>
		}
		sys: {
			space: {
				sys: {
					type: string
					linkType: string
					id: string
				}
			}
			id: string
			type: string
			createdAt: string
			updatedAt: string
			environment: {
				sys: {
					id: string
					type: string
					linkType: string
				}
			}
			revision: number
			contentType: {
				sys: {
					type: string
					linkType: string
					id: string
				}
			}
			locale: string
		}
		fields: {
			media: {
				sys: {
					type: string
					linkType: string
					id: string
				}
			}
			alt: string
		}
	}>
	includes: {
		Asset: Array<{
			metadata: {
				tags: Array<any>
			}
			sys: {
				space: {
					sys: {
						type: string
						linkType: string
						id: string
					}
				}
				id: string
				type: string
				createdAt: string
				updatedAt: string
				environment: {
					sys: {
						id: string
						type: string
						linkType: string
					}
				}
				revision: number
				locale: string
			}
			fields: {
				title: string
				file: {
					url: string
					details: {
						size: number
						image: {
							width: number
							height: number
						}
					}
					fileName: string
					contentType: string
				}
			}
		}>
	}
}