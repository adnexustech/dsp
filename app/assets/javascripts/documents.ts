// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

// Global declarations for TypeScript
declare const $: any;
declare const ace: any;
declare const require: any;

// Documents page initialization
$(document).on('ready page:load', (): void => {
    console.log("loading documents typescript");

    // Initialize non-searchable select dropdowns
    $("select.nosearch").select2({
        minimumResultsForSearch: Infinity,
        width: '100%'
    });

    // Initialize searchable multi-select for categories
    $("select.search_categories").select2({
        tags: false,
        allowClear: true,
        multiple: true,
        placeholder: "select categories",
        width: '100%'
    });

    // Initialize ACE editor if container exists
    if ($("#editor_container").length > 0) {
        const editor = ace.edit("editor");
        editor.setShowPrintMargin(false);
        editor.setTheme("ace/theme/chrome");
        require("ace/config").set("workerPath", "/ace");
        editor.getSession().setMode("ace/mode/html");
        editor.getSession().setUseWrapMode(true);
        editor.setValue($('textarea[name="document[code]"]').val());
        editor.clearSelection();
        editor.focus();
        editor.resize();

        // Sync editor content to textarea on form submit
        $("form").submit((): void => {
            const code: string = editor.getValue();
            $('textarea[name="document[code]"]').val(code);
        });

        // Make editor resizable
        $("#editor_container").resizable({
            resize: (event: any, ui: any): void => {
                editor.resize();
            }
        });
    }
});
