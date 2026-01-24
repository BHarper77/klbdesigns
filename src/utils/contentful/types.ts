type WebsiteContentModel = {
	media: {
		sys: {
			type: string
			linkType: string
			id: string
		}
	}
	alt: string
	title?: string
	instagramUrl?: string
	etsyUrl?: string
}

export type TagsQueryResponse = {
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
		fields: WebsiteContentModel
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

export type TagsResponse = {
	sys: {
	  type: string
	}
	total: number
	skip: number
	limit: number
	items: Array<{
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
		createdBy: {
		  sys: {
			type: string
			linkType: string
			id: string
		  }
		}
		updatedBy: {
		  sys: {
			type: string
			linkType: string
			id: string
		  }
		}
		version: number
		visibility: string
	  }
	  name: string
	}>
}