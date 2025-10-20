// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

interface Select2Options {
  allowClear: boolean;
  placeholder: string;
  minimumResultsForSearch?: number;
  width: string;
  tags?: boolean;
  multiple?: string;
}

interface CampaignDates {
  start: string;
  end: string;
}

interface AceEditor {
  setShowPrintMargin(show: boolean): void;
  setTheme(theme: string): void;
  getSession(): AceSession;
  setValue(value: string): void;
  clearSelection(): void;
  focus(): void;
  resize(): void;
  getValue(): string;
}

interface AceSession {
  setUseWorker(use: boolean): void;
  setMode(mode: string): void;
  setUseWrapMode(use: boolean): void;
}

declare const ace: {
  edit(id: string): AceEditor;
};

declare const $: any;

$(document).ready(() => {
  console.log("Loading banner_videos TypeScript");

  // Initialize select2 for nosearch elements
  $("select.nosearch").select2({
    allowClear: true,
    placeholder: "Select an option",
    minimumResultsForSearch: Infinity,
    width: '100%'
  } as Select2Options);

  // Initialize select2 for search_rules elements
  $("select.search_rules").select2({
    tags: false,
    allowClear: true,
    multiple: "multiple",
    placeholder: "select multiple entries, enter text to filter list",
    width: '100%'
  } as Select2Options);

  // Initialize ACE editor if container exists
  if ($("#editor_container").length > 0) {
    const editor: AceEditor = ace.edit("editor");
    editor.setShowPrintMargin(false);
    editor.setTheme("ace/theme/chrome");
    editor.getSession().setUseWorker(false);
    editor.getSession().setMode("ace/mode/html");
    editor.getSession().setUseWrapMode(true);
    editor.setValue($('textarea[name="banner_video[vast_video_outgoing_file]"]').val());
    editor.clearSelection();
    editor.focus();
    editor.resize();

    // Update textarea on form submit
    $("form").submit(() => {
      const code: string = editor.getValue();
      $('textarea[name="banner_video[vast_video_outgoing_file]"]').val(code);
    });

    // Make editor container resizable
    $("#editor_container").resizable({
      resize: (event: any, ui: any) => {
        editor.resize();
      }
    });
  }

  // Initialize datetimepicker
  $('.datepicker').datetimepicker({
    format: "MM/DD/YYYY HH:mm",
    sideBySide: true
  });

  // Handle campaign selection change
  $('select[name="banner_video[campaign_id]"').on('change', function() {
    const id: string = $(this).val();

    // Get campaign dates
    $.ajax("/getCampaignDates", {
      type: 'GET',
      data: { id: $(this).val() },
      success: (data: string) => {
        const parsedData: CampaignDates = JSON.parse(data);
        $('input[name="interval_start"]').val(parsedData.start).change();
        $('input[name="interval_end"]').val(parsedData.end).change();
      }
    });

    // Get exchange attributes
    $.ajax("/getExchangeAttributes", {
      type: 'GET',
      data: { id: id },
      success: (html: string) => {
        $("#exchange_attributes_div").html(html);

        // Re-initialize select2 elements in the new content
        $("select.nosearch").select2({
          allowClear: true,
          placeholder: "Select an option",
          minimumResultsForSearch: Infinity,
          width: '100%'
        } as Select2Options);

        $("select.search_rules").select2({
          tags: false,
          allowClear: true,
          multiple: "multiple",
          placeholder: "select multiple entries, enter text to filter list",
          width: '100%'
        } as Select2Options);
      }
    });
  });

  // Initialize DataTable
  const dtShowCols: number[] = [0, 1, 2, 3, 4];
  const dtActionCols: number[] = [5, 6, 7];

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

  // Deal table row template
  let propertyRowTemplate = '<tr><td><input type="text" class="form-control input-sm" name="deal_id[]"  value=""/></td>';
  propertyRowTemplate += '<td><div class="input-group input-group-sm">';
  propertyRowTemplate += '<span class="input-group-addon">$</span><input type="text" class="form-control input-sm" name="deal_price[]"  value=""/>';
  propertyRowTemplate += '</div></td>';
  propertyRowTemplate += '<td style="vertical-align:middle"><span class="input-sm"><span class="glyphicon glyphicon-plus-sign tableRowAdd"></span></span>';
  propertyRowTemplate += '<span class="input-sm"><span class="glyphicon glyphicon-minus-sign tableRowRemove"></span></span>';
  propertyRowTemplate += '</td></tr>';

  // Remove deal row
  $("#deals_table").on("click", ".tableRowRemove", function() {
    $(this).closest('tr').remove();
  });

  // Add deal row
  $("#deals_table").on("click", ".tableRowAdd", function() {
    $(this).closest('tr').after(propertyRowTemplate);
  });

  // Handle deal type radio change
  $('input[type=radio][name=deal_type]').on('change', function() {
    const val: string = $(this).val();
    if (val === "none") {
      $("#deals_table_div").hide();
    } else {
      $("#deals_table_div").show();
      if (val === "private_only") {
        $('input[name="banner_video[bid_ecpm]"]').val("0");
      }
    }
  });

  // Handle size match type radio change
  $('input[type=radio][name=size_match_type]').on('change', function() {
    const val: string = $(this).val();
    if (val === "none") {
      $("#width_height_only_div").hide();
      $("#width_height_range_div").hide();
      $("#width_height_list_div").hide();
    } else if (val === "width_height_only") {
      $("#width_height_only_div").show();
      $("#width_height_range_div").hide();
      $("#width_height_list_div").hide();
    } else if (val === "width_height_range") {
      $("#width_height_only_div").hide();
      $("#width_height_range_div").show();
      $("#width_height_list_div").hide();
    } else if (val === "width_height_list") {
      $("#width_height_only_div").hide();
      $("#width_height_range_div").hide();
      $("#width_height_list_div").show();
    }
  });
});
