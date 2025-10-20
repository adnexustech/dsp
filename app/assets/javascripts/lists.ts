// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

// List management initialization
document.addEventListener('DOMContentLoaded', (): void => {
    console.log('Loading lists TypeScript module');

    // Initialize Select2 for list-related dropdowns without search
    const noSearchSelects: NodeListOf<HTMLSelectElement> = document.querySelectorAll('select.nosearch');
    noSearchSelects.forEach((select: HTMLSelectElement): void => {
        if (typeof (window as any).$ !== 'undefined' && typeof (window as any).$.fn.select2 !== 'undefined') {
            (window as any).$(select).select2({
                minimumResultsForSearch: Infinity,
                width: '100%'
            });
        }
    });

    // Initialize Select2 for searchable list selectors
    const searchSelects: NodeListOf<HTMLSelectElement> = document.querySelectorAll('select.search_lists');
    searchSelects.forEach((select: HTMLSelectElement): void => {
        if (typeof (window as any).$ !== 'undefined' && typeof (window as any).$.fn.select2 !== 'undefined') {
            (window as any).$(select).select2({
                tags: false,
                allowClear: true,
                multiple: true,
                placeholder: 'Select multiple entries, enter text to filter list',
                width: '100%'
            });
        }
    });
});
