/** @type {import('./$types').LayoutLoad} */
export function load() {
	return {
		routes: [
			{
				id: 'chat',
				pathname: '[chatId]',
				disabled: false
			},
			{
				id: 'workspace',
				pathname: 'workspace',
				disabled: false
			},
			{
				id: 'library',
				pathname: 'library',
				disabled: false
			},
			{
				id: 'notes',
				pathname: 'notes',
				disabled: false
			},
			{
				id: 'playground',
				pathname: 'playground',
				disabled: false
			},
			{
				id: 'tools',
				pathname: 'tools',
				disabled: false
			},
			{
				id: 'admin',
				pathname: 'admin',
				disabled: false
			}
		]
	};
} 