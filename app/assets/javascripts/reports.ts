// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

// Type definitions for external libraries
declare const $: any;
declare const moment: any;

interface Select2Options {
    minimumResultsForSearch?: number | string;
    width?: string;
    tags?: boolean;
    allowClear?: boolean;
    multiple?: string;
    placeholder?: string;
}

interface DateTimePickerOptions {
    format?: string;
    sideBySide?: boolean;
}

// Initialize reports page functionality
$(document).ready((): void => {
    console.log("Loading reports TypeScript");

    // Update load time with current timestamp
    $("#load_time").text(`Updated ${moment().format("lll (Z)")}`);

    // Initialize select2 for dropdowns without search
    const noSearchOptions: Select2Options = {
        minimumResultsForSearch: Infinity,
        width: '150px'
    };
    $("select.nosearch").select2(noSearchOptions);

    // Initialize select2 for multi-select with search functionality
    const searchRulesOptions: Select2Options = {
        tags: false,
        allowClear: true,
        multiple: "multiple",
        placeholder: "select multiple entries, enter text to filter list"
    };
    $("select.search_rules").select2(searchRulesOptions);

    // Initialize datetime picker
    const datePickerOptions: DateTimePickerOptions = {
        format: "MM/DD/YYYY HH:mm",
        sideBySide: true
    };
    $('.datepicker').datetimepicker(datePickerOptions);
});
