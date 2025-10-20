// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

// Type definitions for jQuery plugins
interface Select2Options {
  minimumResultsForSearch?: number;
  width?: string;
  tags?: boolean;
  allowClear?: boolean;
  placeholder?: string;
  multiple?: string | boolean;
}

interface DateTimePickerOptions {
  format?: string;
  sideBySide?: boolean;
}

interface DataTableColumnDef {
  targets: number[];
  visible: boolean;
  sortable?: boolean;
  className?: string;
}

interface DataTableButton {
  extend: string;
  className: string;
  columns?: number[];
  postfixButtons?: string[];
}

interface DataTablesOptions {
  dom?: string;
  paging?: boolean;
  order?: [number, string][];
  columnDefs?: DataTableColumnDef[];
  colReorder?: boolean;
  fixedHeader?: boolean;
  stateSave?: boolean;
  buttons?: DataTableButton[];
}

interface BidderSyncResponse {
  status: string;
}

// Extend jQuery interface to include plugin methods
declare global {
  interface JQuery {
    select2(options: Select2Options): JQuery;
    datetimepicker(options: DateTimePickerOptions): JQuery;
    DataTable(options: DataTablesOptions): any;
  }
}

$(document).ready(() => {
  console.log("Loading campaign coffeescript");

  // Initialize select2 for dropdowns without search
  $("select.nosearch").select2({
    minimumResultsForSearch: Infinity,
    width: '100%'
  });

  // Initialize select2 for searchable dropdowns
  $("select.search").select2({
    tags: false,
    allowClear: true,
    placeholder: "select one",
    width: '100%'
  });

  // Initialize select2 for multi-select with search
  $("select.search_rules").select2({
    tags: false,
    allowClear: true,
    multiple: "multiple",
    placeholder: "select multiple entries, enter text to filter list",
    width: '100%'
  });

  // Initialize date/time picker
  $('.datepicker').datetimepicker({
    format: "MM/DD/YYYY HH:mm",
    sideBySide: true
  });

  // Handle exchange selection change
  $('select[name="exchanges[]"]').on('change', function() {
    const selectedValue = String($(this).val());
    console.log(`exchange selected ${selectedValue}`);

    if (selectedValue.match(/adx/)) {
      $("#noadx_budget").hide();
      $("#adx_budget").show();
    } else {
      $("#noadx_budget").show();
      $("#adx_budget").hide();
    }
  });

  // DataTable configuration
  const dtShowCols: number[] = [0, 1, 2, 3, 4, 5, 6];
  const dtActionCols: number[] = [7, 8, 9];

  $('#listtable').DataTable({
    dom: 'Bfrtip',
    paging: false,
    order: [[0, "asc"]],
    columnDefs: [
      {
        targets: dtActionCols,
        visible: true,
        sortable: false,
        className: "noVis"
      },
      {
        targets: dtShowCols,
        visible: true,
        sortable: true
      }
    ],
    colReorder: true,
    fixedHeader: true,
    stateSave: true,
    buttons: [
      {
        extend: 'colvis',
        className: "btn-xs",
        columns: dtShowCols,
        postfixButtons: ['colvisRestore']
      },
      {
        extend: 'copyHtml5',
        className: "btn-xs",
        columns: dtShowCols
      },
      {
        extend: 'csvHtml5',
        className: "btn-xs",
        columns: dtShowCols
      }
    ]
  });

  // Handle bidder sync all button click
  $('#bidder_sync_all').on('click', function() {
    document.body.style.cursor = 'wait';
    $("#bidder_sync_all_response").html('<span class="text-info">Synching bidders. Please wait...</span>');

    const id = $(this).val();

    $.ajax("/biddersSynchAll", {
      type: 'GET',
      success: (data: string) => {
        const parsedData: BidderSyncResponse = JSON.parse(data);
        document.body.style.cursor = 'default';

        if (parsedData.status === "OK") {
          $("#bidder_sync_all_response").html('<span class="text-success">Bidders synch completed OK.</span>');
        } else {
          $("#bidder_sync_all_response").html('<span class="text-danger">Error synching bidders.</span>');
        }
      },
      error: (jqXHR: JQueryXHR, textStatus: string, errorThrown: string) => {
        document.body.style.cursor = 'default';
        $("#bidder_sync_all_response").html('<span class="text-danger">Failed sending command. Please try again.</span>');
      }
    });
  });
});
