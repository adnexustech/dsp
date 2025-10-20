// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

// Global jQuery declaration for TypeScript
declare const $: any;

// Categories page initialization
$(document).ready((): void => {
    console.log("loading categories typescript");

    // Initialize non-searchable select dropdowns
    $("select.nosearch").select2({
        minimumResultsForSearch: Infinity,
        width: '100%'
    });

    // Initialize searchable multi-select for documents
    $("select.search_documents").select2({
        tags: false,
        allowClear: true,
        multiple: true,
        placeholder: "select multiple entries, enter text to filter list",
        width: '100%'
    });
});
