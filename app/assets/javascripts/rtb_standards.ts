// Type declarations for jQuery plugins
declare global {
  interface JQuery {
    select2(options?: any): JQuery;
    DataTable(options?: any): any;
  }
}

interface OperatorMatch {
  ordinal: string | null;
  type: string | null;
}

$(document).ready(() => {
  console.log("Loading rtb_standards TypeScript");

  // Initialize Select2 dropdowns with no search
  $("select.nosearch").select2({
    minimumResultsForSearch: Infinity,
    width: '100%'
  });

  // Initialize Select2 dropdowns with search
  $("select.search").select2({
    tags: false,
    allowClear: true,
    placeholder: "Select or enter value, type to filter list",
    width: '100%'
  });

  // Initialize Select2 single select with tags
  $("select.select2_single").select2({
    tags: true,
    allowClear: true,
    placeholder: "Select or enter value, type to filter list",
    width: '100%'
  });

  // Initialize Select2 multiple select with tags
  $("select.select2_multiple").select2({
    tags: true,
    multiple: true,
    allowClear: true,
    placeholder: "Select or enter value",
    width: '100%'
  });

  // Operator mapping logic
  $("#rtb_standard_operator").on("select2:select", function(e) {
    const op = $(this).val() as string;
    let ordinal: string | null = null;
    let type: string | null = null;

    // Determine ordinal and type based on operator
    if (/^(EQUALS|NOT_EQUALS|LESS_THAN|LESS_THAN_EQUALS|GREATER_THAN|GREATER_THAN_EQUALS)$/.test(op)) {
      ordinal = "Scalar";
    } else if (/^(INTERSECTS|NOT_INTERSECTS|MEMBER|NOT_MEMBER)$/.test(op)) {
      ordinal = "List";
    } else if (/^(STRINGIN|NOT_STRINGIN|REGEX|NOT_REGEX)$/.test(op)) {
      ordinal = "Scalar";
      type = "String";
    } else if (/^(INRANGE|NOT_INRANGE)$/.test(op)) {
      ordinal = "List";
      type = "Double";
    } else if (/^(EXISTS|NOT_EXISTS)$/.test(op)) {
      ordinal = "";
      type = "";
    } else {
      // Default case for OR, DOMAIN, NOT_DOMAIN, etc.
      ordinal = null;
      type = null;
    }

    // Update operand_type if type is defined
    if (type !== null) {
      $("#rtb_standard_operand_type option").filter(function() {
        return $(this).text() === type;
      }).prop('selected', true).trigger("change");
    }

    // Update operand_ordinal if ordinal is defined
    if (ordinal !== null) {
      $("#rtb_standard_operand_ordinal option").filter(function() {
        return $(this).text() === ordinal;
      }).prop('selected', true).trigger("change");
    }
  });

  // DataTable configuration
  const dtShowCols: number[] = [0, 1, 2, 3, 4];
  const dtActionCols: number[] = [5, 6, 7, 8];

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
});

export {};
