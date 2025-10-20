// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

// Type definitions for external libraries
declare const $: any;
declare const ace: any;

interface CampaignDates {
  start: string;
  end: string;
}

interface Select2Config {
  allowClear?: boolean;
  placeholder?: string;
  minimumResultsForSearch?: number;
  width?: string;
  tags?: boolean;
  multiple?: string;
}

interface DataTableColumnDef {
  targets: number[];
  visible: boolean;
  sortable: boolean;
  className?: string;
}

interface DataTableButton {
  extend: string;
  className: string;
  columns?: number[];
  postfixButtons?: string[];
}

// Initialize Select2 for nosearch dropdowns
const initNoSearchSelect2 = (): void => {
  const config: Select2Config = {
    allowClear: true,
    placeholder: "Select an option",
    minimumResultsForSearch: Infinity,
    width: '100%'
  };
  $("select.nosearch").select2(config);
};

// Initialize Select2 for searchable multi-select dropdowns
const initSearchRulesSelect2 = (): void => {
  const config: Select2Config = {
    tags: false,
    allowClear: true,
    multiple: "multiple",
    placeholder: "select multiple entries, enter text to filter list",
    width: '100%'
  };
  $("select.search_rules").select2(config);
};

// Initialize ACE editor if present
const initAceEditor = (): void => {
  if ($("#editor_container").length === 0) return;

  const editor = ace.edit("editor");
  editor.setShowPrintMargin(false);
  editor.setTheme("ace/theme/chrome");
  editor.getSession().setUseWorker(false);
  editor.getSession().setMode("ace/mode/html");
  editor.getSession().setUseWrapMode(true);
  editor.setValue($('textarea[name="banner[htmltemplate]"]').val());
  editor.clearSelection();
  editor.focus();
  editor.resize();

  // Update textarea on form submit
  $("form").submit(function(): void {
    const code = editor.getValue();
    $('textarea[name="banner[htmltemplate]"]').val(code);
  });

  // Make editor resizable
  $("#editor_container").resizable({
    resize: (event: any, ui: any): void => {
      editor.resize();
    }
  });
};

// Initialize datetimepicker
const initDateTimePicker = (): void => {
  $('.datepicker').datetimepicker({
    format: "MM/DD/YYYY HH:mm",
    sideBySide: true
  });
};

// Handle campaign selection change
const initCampaignChangeHandler = (): void => {
  $('select[name="banner[campaign_id]"]').on('change', function(): void {
    const id = $(this).val();

    // Fetch campaign dates
    $.ajax("/getCampaignDates", {
      type: 'GET',
      data: { id: id },
      success: (data: string): void => {
        const parsedData: CampaignDates = JSON.parse(data);
        $('input[name="interval_start"]').val(parsedData.start).change();
        $('input[name="interval_end"]').val(parsedData.end).change();
      }
    });

    // Fetch exchange attributes
    $.ajax("/getExchangeAttributes", {
      type: 'GET',
      data: { id: id },
      success: (html: string): void => {
        $("#exchange_attributes_div").html(html);
        // Re-initialize Select2 on new content
        initNoSearchSelect2();
        initSearchRulesSelect2();
      }
    });
  });
};

// Initialize DataTable
const initDataTable = (): void => {
  const dtShowCols: number[] = [0, 1, 2, 3, 4];
  const dtActionCols: number[] = [5, 6, 7];

  const columnDefs: DataTableColumnDef[] = [
    { targets: dtActionCols, visible: true, sortable: false, className: "noVis" },
    { targets: dtShowCols, visible: true, sortable: true }
  ];

  const buttons: DataTableButton[] = [
    { extend: 'colvis', className: "btn-xs", columns: dtShowCols, postfixButtons: ['colvisRestore'] },
    { extend: 'copyHtml5', className: "btn-xs", columns: dtShowCols },
    { extend: 'csvHtml5', className: "btn-xs", columns: dtShowCols }
  ];

  $('#listtable').DataTable({
    dom: 'Bfrtip',
    paging: false,
    order: [[0, "asc"]],
    columnDefs: columnDefs,
    colReorder: true,
    fixedHeader: true,
    stateSave: true,
    buttons: buttons
  });
};

// Initialize deals table
const initDealsTable = (): void => {
  const propertyRowTemplate = `
    <tr>
      <td><input type="text" class="form-control input-sm" name="deal_id[]" value=""/></td>
      <td>
        <div class="input-group input-group-sm">
          <span class="input-group-addon">$</span>
          <input type="text" class="form-control input-sm" name="deal_price[]" value=""/>
        </div>
      </td>
      <td style="vertical-align:middle">
        <span class="input-sm"><span class="glyphicon glyphicon-plus-sign tableRowAdd"></span></span>
        <span class="input-sm"><span class="glyphicon glyphicon-minus-sign tableRowRemove"></span></span>
      </td>
    </tr>
  `;

  // Remove row handler
  $("#deals_table").on("click", ".tableRowRemove", function(): void {
    $(this).closest('tr').remove();
  });

  // Add row handler
  $("#deals_table").on("click", ".tableRowAdd", function(): void {
    $(this).closest('tr').after(propertyRowTemplate);
  });
};

// Handle deal type radio button changes
const initDealTypeHandler = (): void => {
  $('input[type=radio][name=deal_type]').on('change', function(): void {
    const val = $(this).val();

    if (val === "none") {
      $("#deals_table_div").hide();
    } else {
      $("#deals_table_div").show();
      if (val === "private_only") {
        $('input[name="banner[bid_ecpm]"]').val("0");
      }
    }
  });
};

// Handle size match type radio button changes
const initSizeMatchTypeHandler = (): void => {
  $('input[type=radio][name=size_match_type]').on('change', function(): void {
    const val = $(this).val();

    // Hide all sections first
    $("#width_height_only_div").hide();
    $("#width_height_range_div").hide();
    $("#width_height_list_div").hide();

    // Show appropriate section based on selection
    switch (val) {
      case "width_height_only":
        $("#width_height_only_div").show();
        break;
      case "width_height_range":
        $("#width_height_range_div").show();
        break;
      case "width_height_list":
        $("#width_height_list_div").show();
        break;
      // "none" case - all sections remain hidden
    }
  });
};

// Main initialization
$(document).ready((): void => {
  console.log("Loading banners TypeScript");

  // Initialize all components
  initNoSearchSelect2();
  initSearchRulesSelect2();
  initAceEditor();
  initDateTimePicker();
  initCampaignChangeHandler();
  initDataTable();
  initDealsTable();
  initDealTypeHandler();
  initSizeMatchTypeHandler();
});
