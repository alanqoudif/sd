<script lang="ts">
    import { onMount, getContext } from 'svelte';
    import { toast } from 'svelte-sonner';
    import { user } from '$lib/stores';
    import { goto } from '$app/navigation';
    
    const i18n = getContext('i18n');

    let files = [];
    let isLoading = true;
    let currentFolder = '/';
    let parentFolders = [];
    let isAuthenticated = false;
    let isAdminUser = false;

    const getFileIcon = (fileName) => {
        const ext = fileName.split('.').pop().toLowerCase();
        
        if (['pdf'].includes(ext)) {
            return 'pdf';
        } else if (['doc', 'docx'].includes(ext)) {
            return 'word';
        } else if (['xls', 'xlsx'].includes(ext)) {
            return 'excel';
        } else if (['jpg', 'jpeg', 'png', 'gif', 'bmp', 'svg'].includes(ext)) {
            return 'image';
        } else if (['txt', 'md'].includes(ext)) {
            return 'text';
        } else {
            return 'file';
        }
    };

    const navigateToFolder = async (folder) => {
        currentFolder = folder;
        await loadFiles();
    };

    const navigateUp = async () => {
        if (parentFolders.length > 0) {
            const parentFolder = parentFolders.pop();
            currentFolder = parentFolder;
            await loadFiles();
        }
    };

    const checkAuth = () => {
        isAuthenticated = $user && $user.token;
        isAdminUser = isAuthenticated && $user.role === 'admin';
        
        if (!isAuthenticated) {
            toast.error($i18n.t('You need to be logged in to access the library'));
            goto('/');
            return false;
        }
        
        if (!isAdminUser) {
            toast.error($i18n.t('You need to be an admin to access the library'));
            goto('/');
            return false;
        }
        
        return true;
    };

    const loadFiles = async () => {
        if (!checkAuth()) return;
        
        isLoading = true;
        files = [];
        
        try {
            const response = await fetch(`/api/v1/library?path=${encodeURIComponent(currentFolder)}`, {
                headers: {
                    Authorization: `Bearer ${$user?.token || localStorage.getItem('token')}`
                }
            });
            
            if (!response.ok) {
                const errorData = await response.json().catch(() => ({}));
                throw new Error(errorData.detail || 'Failed to load files');
            }
            
            const data = await response.json();
            files = data.files.sort((a, b) => {
                // Sort directories first, then files
                if (a.type === 'directory' && b.type !== 'directory') return -1;
                if (a.type !== 'directory' && b.type === 'directory') return 1;
                // Then sort alphabetically
                return a.name.localeCompare(b.name);
            });
            
            // Update parentFolders for breadcrumb navigation
            if (currentFolder !== '/' && !parentFolders.includes(currentFolder)) {
                parentFolders.push(currentFolder);
            }
            
        } catch (error) {
            console.error('Error loading files:', error);
            toast.error(error.message || $i18n.t('Failed to load files'));
        } finally {
            isLoading = false;
        }
    };

    const formatDate = (timestamp) => {
        try {
            return new Date(timestamp).toLocaleString();
        } catch (e) {
            return timestamp;
        }
    };

    const downloadFile = async (fileName) => {
        if (!checkAuth()) return;
        
        try {
            const response = await fetch(`/api/v1/library/download?path=${encodeURIComponent(currentFolder)}&filename=${encodeURIComponent(fileName)}`, {
                headers: {
                    Authorization: `Bearer ${$user?.token || localStorage.getItem('token')}`
                }
            });
            
            if (!response.ok) {
                const errorData = await response.json().catch(() => ({}));
                throw new Error(errorData.detail || 'Failed to download file');
            }
            
            const blob = await response.blob();
            const url = window.URL.createObjectURL(blob);
            const a = document.createElement('a');
            a.style.display = 'none';
            a.href = url;
            a.download = fileName;
            document.body.appendChild(a);
            a.click();
            window.URL.revokeObjectURL(url);
            document.body.removeChild(a);
            
        } catch (error) {
            console.error('Error downloading file:', error);
            toast.error(error.message || $i18n.t('Failed to download file'));
        }
    };

    onMount(async () => {
        // Subscribe to user changes
        const unsubscribe = user.subscribe(value => {
            if (value) {
                isAuthenticated = true;
                isAdminUser = value.role === 'admin';
            } else {
                isAuthenticated = false;
                isAdminUser = false;
            }
        });
        
        // Attempt to load files if user is authenticated
        if (checkAuth()) {
            await loadFiles();
        }
        
        return () => {
            unsubscribe();
        };
    });
</script>

{#if isAuthenticated && isAdminUser}
    <div class="container mx-auto py-6 px-4">
        <div class="flex flex-col h-full">
            <div class="mb-6">
                <h1 class="text-2xl font-bold">{$i18n.t('Library')}</h1>
                <p class="text-gray-500 dark:text-gray-400 mt-1">{$i18n.t('Browse and manage your files')}</p>
                <div class="mt-3 p-3 bg-blue-50 dark:bg-blue-900/20 rounded-lg text-sm text-blue-800 dark:text-blue-200">
                    <p class="font-medium">ملاحظة مهمة:</p>
                    <p>للوصول إلى صفحة المكتبة من متصفح آخر، تأكد من تسجيل دخولك كمسؤول. إذا ظهرت لك رسالة "CAA Chat Backend Required"، قم بفتح الرابط المباشر: <a href="/library" class="underline">http://localhost:5174/library</a> بعد تسجيل الدخول.</p>
                </div>
            </div>

            <!-- Breadcrumb navigation -->
            <div class="flex items-center mb-4 text-sm">
                <button 
                    class="px-2 py-1 rounded hover:bg-gray-100 dark:hover:bg-gray-800 transition"
                    on:click={() => navigateToFolder('/')}
                >
                    {$i18n.t('Home')}
                </button>
                
                {#if currentFolder !== '/'}
                    <span class="mx-2">/</span>
                    <button 
                        class="px-2 py-1 rounded hover:bg-gray-100 dark:hover:bg-gray-800 transition"
                        on:click={navigateUp}
                    >
                        {$i18n.t('Up')}
                    </button>
                    <span class="mx-2">/</span>
                    <span class="font-medium">{currentFolder.split('/').filter(Boolean).pop()}</span>
                {/if}
            </div>

            {#if isLoading}
                <div class="flex justify-center items-center h-64">
                    <div class="animate-spin rounded-full h-8 w-8 border-t-2 border-b-2 border-gray-900 dark:border-gray-100"></div>
                </div>
            {:else if files.length === 0}
                <div class="flex flex-col items-center justify-center h-64 text-gray-500 dark:text-gray-400">
                    <svg xmlns="http://www.w3.org/2000/svg" class="h-12 w-12 mb-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 19a2 2 0 01-2-2V7a2 2 0 012-2h4l2 2h4a2 2 0 012 2v1M5 19h14a2 2 0 002-2v-5a2 2 0 00-2-2H9a2 2 0 00-2 2v5a2 2 0 01-2 2z" />
                    </svg>
                    <p>{$i18n.t('No files found in this directory')}</p>
                </div>
            {:else}
                <div class="overflow-x-auto">
                    <table class="min-w-full divide-y divide-gray-200 dark:divide-gray-700">
                        <thead class="bg-gray-50 dark:bg-gray-800">
                            <tr>
                                <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wider">{$i18n.t('Name')}</th>
                                <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wider">{$i18n.t('Size')}</th>
                                <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wider">{$i18n.t('Modified')}</th>
                                <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wider">{$i18n.t('Actions')}</th>
                            </tr>
                        </thead>
                        <tbody class="bg-white dark:bg-gray-900 divide-y divide-gray-200 dark:divide-gray-700">
                            {#each files as file}
                                <tr class="hover:bg-gray-50 dark:hover:bg-gray-800 transition">
                                    <td class="px-6 py-4 whitespace-nowrap">
                                        <div class="flex items-center">
                                            {#if file.type === 'directory'}
                                                <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 text-yellow-500 mr-3" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 7v10a2 2 0 002 2h14a2 2 0 002-2V9a2 2 0 00-2-2h-6l-2-2H5a2 2 0 00-2 2z" />
                                                </svg>
                                                <button 
                                                    class="font-medium text-blue-600 dark:text-blue-400 hover:underline"
                                                    on:click={() => navigateToFolder(`${currentFolder === '/' ? '' : currentFolder}/${file.name}`)}
                                                >
                                                    {file.name}
                                                </button>
                                            {:else}
                                                {#if getFileIcon(file.name) === 'pdf'}
                                                    <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 text-red-500 mr-3" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
                                                    </svg>
                                                {:else if getFileIcon(file.name) === 'image'}
                                                    <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 text-green-500 mr-3" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z" />
                                                    </svg>
                                                {:else}
                                                    <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 text-gray-500 mr-3" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 21h10a2 2 0 002-2V9.414a1 1 0 00-.293-.707l-5.414-5.414A1 1 0 0012.586 3H7a2 2 0 00-2 2v14a2 2 0 002 2z" />
                                                    </svg>
                                                {/if}
                                                <span>{file.name}</span>
                                            {/if}
                                        </div>
                                    </td>
                                    <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500 dark:text-gray-400">
                                        {file.type === 'directory' ? '-' : file.size}
                                    </td>
                                    <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500 dark:text-gray-400">
                                        {formatDate(file.modified)}
                                    </td>
                                    <td class="px-6 py-4 whitespace-nowrap text-sm font-medium">
                                        {#if file.type !== 'directory'}
                                            <button 
                                                class="text-blue-600 dark:text-blue-400 hover:text-blue-900 dark:hover:text-blue-300 mr-3"
                                                on:click={() => downloadFile(file.name)}
                                            >
                                                {$i18n.t('Download')}
                                            </button>
                                        {/if}
                                    </td>
                                </tr>
                            {/each}
                        </tbody>
                    </table>
                </div>
            {/if}
        </div>
    </div>
{:else}
    <div class="flex flex-col items-center justify-center h-screen text-gray-700 dark:text-gray-300">
        <svg xmlns="http://www.w3.org/2000/svg" class="h-16 w-16 mb-4 text-red-500" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z" />
        </svg>
        <h2 class="text-xl font-bold mb-2">{$i18n.t('Authentication Required')}</h2>
        <p class="mb-4 text-center max-w-md">{$i18n.t('You need to be logged in as an admin to access the library.')}</p>
        <button 
            class="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition"
            on:click={() => goto('/')}
        >
            {$i18n.t('Go to Home')}
        </button>
    </div>
{/if} 