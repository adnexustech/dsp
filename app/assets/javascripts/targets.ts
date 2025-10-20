// TypeScript conversion of targets.coffee
// Handles map-based targeting with Google Maps API integration

// Global declarations
declare const google: any;
declare const BootstrapDialog: any;
declare const $: any;

interface Root {
  map: any | null;
  mapOverlay: any | null;
}

// Module-level variables
const root: Root = (typeof exports !== 'undefined' ? exports : (window as any)) as Root;
root.map = null;
root.mapOverlay = null;

const mapId = "mapCanvasId";

const mapHtml =
  '<div id="mapCanvasId" class="form-control" style="width:100%;height:400px;padding:0px;">Map goes here</div>' +
  '<span id="mapAddCircle" class="badge badge-pink crosshair" title="Add a circle overlay to the map">Add Area</span>' +
  '&nbsp;&nbsp;&nbsp;&nbsp;<span id="mapDeleteCircle" class="badge badge-grey crosshair" title="Remove the circle overlay.">Remove Area</span>' +
  '<input type="hidden" id="mapzoom">' +
  '<input type="hidden" id="mapcenter_lat">' +
  '<input type="hidden" id="mapcenter_lng">';

function setMapZoom(): void {
  const zoomlevel = root.map.getZoom();
  $("#mapzoom").val(zoomlevel);
}

function addCircleOverlay(radius: number | string | null): void {
  const center = root.map.getCenter();
  const lat = center.lat();
  const lng = center.lng();
  const color = "#FF0066";

  let radiusNum: number;
  if (isNaN(Number(radius)) || radius === null || radius === "") {
    radiusNum = 1000;
  } else {
    radiusNum = Number(radius);
  }

  if (root.mapOverlay) {
    root.mapOverlay.setMap(null);
  }

  root.mapOverlay = new google.maps.Circle({
    strokeColor: color,
    strokeOpacity: 0.8,
    strokeWeight: 2,
    fillColor: color,
    fillOpacity: 0.35,
    editable: true,
    map: root.map,
    center: new google.maps.LatLng(lat, lng),
    radius: radiusNum
  });
}

function deleteCircleOverlay(): void {
  if (root.mapOverlay) {
    root.mapOverlay.setMap(null);
  }
  root.mapOverlay = null;
}

function checkNumber(val: any, defaultVal: number): number {
  if (isNaN(val) || val === "" || val === null) {
    return defaultVal;
  }
  return Number(val);
}

$(document).ready(() => {
  console.log("Loading targets typescript");

  // Initialize select2 components
  $("select.nosearch").select2({
    minimumResultsForSearch: Infinity,
    width: '100%'
  });

  $("select.search").select2({
    multiple: "multiple",
    placeholder: "select multiple entries, enter text to filter list",
    width: '100%'
  });

  $("select.search_single").select2({
    tags: false,
    allowClear: true,
    include_blank: true,
    placeholder: "Select or enter value, type to filter list",
    width: '100%'
  });

  // Initialize datepicker
  $('.datepicker').datetimepicker({
    format: "MM/DD/YYYY HH:mm",
    sideBySide: true
  });

  // Campaign change handler
  $('select[name="target[campaign_id]"]').on('change', function(this: any) {
    const id = $(this).val();
    $.ajax("/getCampaignDates", {
      type: 'GET',
      data: { id: $(this).val() },
      success: (data: string) => {
        const parsed = JSON.parse(data);
        $('input[name="activate_time"]').val(parsed.start).change();
        $('input[name="expire_time"]').val(parsed.end).change();
      }
    });
  });

  // Map dialog handler
  $('.mapdialog').on('click', () => {
    BootstrapDialog.show({
      size: BootstrapDialog.SIZE_WIDE,
      message: mapHtml,
      onshown: (dialog: any) => {
        const defaultLat = 37.8236;
        const defaultLng = -122.4211;
        const lat = checkNumber($("input[name='target[geo_latitude]']").val(), defaultLat);
        const lng = checkNumber($("input[name='target[geo_longitude]']").val(), defaultLng);
        const radius = $("input[name='target[geo_range]']").val();
        const initZoom = 8;

        const mapOptions = {
          zoom: initZoom,
          center: {
            lat: lat,
            lng: lng
          },
          mapTypeId: google.maps.MapTypeId.ROADMAP,
          disableDefaultUI: false,
          zoomControl: true
        };

        root.map = new google.maps.Map(document.getElementById("mapCanvasId"), mapOptions);

        if (!isNaN(radius) && radius !== "" && radius !== null) {
          addCircleOverlay(Number(radius));
        }

        $("#mapAddCircle").on('click', () => addCircleOverlay(radius));
        $("#mapDeleteCircle").on('click', () => deleteCircleOverlay());
      },
      buttons: [
        {
          label: 'Cancel',
          cssClass: "btn btn-sm btn-default",
          action: (dialog: any) => {
            dialog.close();
          }
        },
        {
          label: 'Save',
          cssClass: "btn btn-sm btn-primary",
          action: (dialog: any) => {
            let lat: number | string;
            let lng: number | string;
            let radius: number | string;

            if (!root.mapOverlay) {
              lat = "";
              lng = "";
              radius = "";
            } else {
              radius = parseInt(root.mapOverlay.getRadius());
              const center = root.mapOverlay.getCenter();
              lat = Math.round(center.lat() * 100000) / 100000;  // round to 5 decimal places
              lng = Math.round(center.lng() * 100000) / 100000;
              console.log("circle lat=" + lat + ",lng=" + lng);
            }

            $("input[name='target[geo_latitude]']").val(lat);
            $("input[name='target[geo_longitude]']").val(lng);
            $("input[name='target[geo_range]']").val(radius);
            dialog.close();
          }
        }
      ]
    });
  });

  // DataTable configuration
  const dtShowCols = [0, 1, 2, 3, 4];
  const dtActionCols = [5, 6, 7];

  $('#listtable').DataTable({
    dom: 'Bfrtip',
    paging: false,
    order: [[0, "asc"]],
    columnDefs: [
      { "targets": dtActionCols, "visible": true, "sortable": false, "className": "noVis" },
      { "targets": dtShowCols, "visible": true, "sortable": true }
    ],
    colReorder: true,
    fixedHeader: true,
    stateSave: true,
    buttons: [
      { extend: 'colvis', className: "btn-xs", columns: dtShowCols, postfixButtons: ['colvisRestore'] },
      { extend: 'copyHtml5', className: "btn-xs", columns: dtShowCols },
      { extend: 'csvHtml5', className: "btn-xs", columns: dtShowCols }
    ]
  });
});
