// Type definitions for jQuery DataTables
interface DataTablesButton {
  extend: string;
  className: string;
  columns?: number[];
  postfixButtons?: string[];
}

interface DataTablesColumnDef {
  targets: number[];
  visible: boolean;
  sortable: boolean;
  className?: string;
}

interface DataTablesSettings {
  dom: string;
  paging: boolean;
  order: [number, string][];
  columnDefs: DataTablesColumnDef[];
  colReorder: boolean;
  fixedHeader: boolean;
  stateSave: boolean;
  buttons: DataTablesButton[];
}

// Ensure jQuery and moment are available globally
declare const $: any;
declare const moment: any;

const root = typeof exports !== 'undefined' ? exports : window;

$(document).ready(() => {
  console.log('Loaded dashboard TypeScript.');

  // Update load time with current timestamp
  $('#load_time').text(`Updated ${moment().format('lll (Z)')}`);

  // Initialize popovers
  $('[data-toggle="popover"]').popover();

  // Define column groups for different time periods
  const dtShowCols_head: number[] = [0, 1, 2];
  const dtShowCols_1hr: number[] = [3, 4, 5, 6, 7];
  const dtShowCols_8hr: number[] = [8, 9, 10, 11, 12];
  const dtShowCols_24hr: number[] = [13, 14, 15, 16, 17];
  const dtShowCols_all: number[] = [18, 19, 20, 21, 22];

  // Combine all visible columns
  const dtShowCols: number[] = [
    ...dtShowCols_head,
    ...dtShowCols_1hr,
    ...dtShowCols_8hr,
    ...dtShowCols_24hr,
    ...dtShowCols_all
  ];

  // Initialize DataTable with configuration
  $('.listtable').DataTable({
    dom: 'Bfrtip',
    paging: false,
    order: [[0, 'asc']],
    columnDefs: [
      {
        targets: dtShowCols_head,
        visible: true,
        sortable: true
      },
      {
        targets: dtShowCols_1hr,
        visible: true,
        sortable: true,
        className: 'col_1hr'
      },
      {
        targets: dtShowCols_8hr,
        visible: true,
        sortable: true,
        className: 'col_8hr'
      },
      {
        targets: dtShowCols_24hr,
        visible: true,
        sortable: true,
        className: 'col_24hr'
      },
      {
        targets: dtShowCols_all,
        visible: true,
        sortable: true,
        className: 'col_all'
      }
    ],
    colReorder: true,
    fixedHeader: false,
    stateSave: true,
    buttons: [
      {
        extend: 'colvis',
        className: 'btn-xs',
        columns: dtShowCols,
        postfixButtons: ['colvisRestore']
      },
      {
        extend: 'copyHtml5',
        className: 'btn-xs',
        columns: dtShowCols
      },
      {
        extend: 'csvHtml5',
        className: 'btn-xs',
        columns: dtShowCols
      }
    ]
  } as DataTablesSettings);
});
