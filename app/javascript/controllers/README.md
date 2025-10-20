# Stimulus Controllers Documentation

This application uses [Stimulus](https://stimulus.hotwired.dev/) for JavaScript interactions. All jQuery has been replaced with Stimulus controllers.

## Available Controllers

### 1. Select2 Controller

Wraps Select2 jQuery plugin for enhanced dropdowns.

**Usage:**

```erb
<!-- Simple select with search disabled -->
<%= select_tag :category_id, options_for_select(@categories),
    data: {
      controller: "select2",
      select2_no_search_value: true
    } %>

<!-- Multi-select with tags -->
<%= select_tag :tags, options_for_select(@tags),
    multiple: true,
    data: {
      controller: "select2",
      select2_tags_value: true,
      select2_multiple_value: true,
      select2_placeholder_value: "Select multiple tags"
    } %>

<!-- AJAX select -->
<%= select_tag :user_id, options_for_select([]),
    data: {
      controller: "select2",
      select2_ajax_value: "/api/users/search"
    } %>
```

**Values:**
- `no-search` (boolean): Disable search functionality
- `tags` (boolean): Allow creating new tags
- `multiple` (boolean): Allow multiple selections
- `allow-clear` (boolean): Show clear button
- `placeholder` (string): Placeholder text
- `ajax` (string): AJAX endpoint URL

---

### 2. DataTable Controller

Wraps DataTables jQuery plugin for enhanced tables.

**Usage:**

```erb
<table data-controller="datatable"
       data-datatable-order-value='[[0, "asc"]]'
       data-datatable-page-length-value="25">
  <thead>
    <tr>
      <th>Name</th>
      <th>Email</th>
      <th>Created</th>
    </tr>
  </thead>
  <tbody>
    <% @users.each do |user| %>
      <tr>
        <td><%= user.name %></td>
        <td><%= user.email %></td>
        <td><%= user.created_at %></td>
      </tr>
    <% end %>
  </tbody>
</table>
```

**Values:**
- `order` (array): Default sort order [[column, direction]]
- `page-length` (number): Rows per page
- `searching` (boolean): Enable search
- `paging` (boolean): Enable pagination
- `info` (boolean): Show table info
- `responsive` (boolean): Enable responsive mode

---

### 3. ACE Editor Controller

Wraps ACE Editor for code editing.

**Usage:**

```erb
<div data-controller="ace-editor"
     data-ace-editor-mode-value="html"
     data-ace-editor-theme-value="chrome">

  <%= text_area_tag "code", @code,
      data: { ace_editor_target: "textarea" },
      style: "display:none" %>

  <div id="editor"
       data-ace-editor-target="editor"
       style="height: 400px;"></div>
</div>
```

**Values:**
- `mode` (string): Language mode (html, javascript, css, etc.)
- `theme` (string): Editor theme (chrome, monokai, etc.)
- `readonly` (boolean): Make editor read-only
- `show-gutter` (boolean): Show line numbers
- `show-print-margin` (boolean): Show print margin
- `wrap-mode` (boolean): Enable line wrapping

**Targets:**
- `textarea`: Hidden textarea for form submission
- `editor`: Visible editor container

---

### 4. Datepicker Controller

Wraps Bootstrap Datetimepicker.

**Usage:**

```erb
<%= text_field_tag :start_date, @start_date,
    class: "form-control",
    data: {
      controller: "datepicker",
      datepicker_format_value: "YYYY-MM-DD HH:mm"
    } %>
```

**Values:**
- `format` (string): Date format (default: "YYYY-MM-DD HH:mm")
- `min-date` (string): Minimum allowed date
- `max-date` (string): Maximum allowed date
- `default-date` (string): Default selected date

---

### 5. Toggle Controller

Shows/hides elements based on input value.

**Usage:**

```erb
<!-- Radio buttons that toggle visibility -->
<%= radio_button_tag :deal_type, "open", true,
    data: {
      controller: "toggle",
      action: "change->toggle#toggle"
    } %>
<%= label_tag :deal_type_open, "Open Auction" %>

<%= radio_button_tag :deal_type, "private", false,
    data: {
      controller: "toggle",
      action: "change->toggle#toggle"
    } %>
<%= label_tag :deal_type_private, "Private Deal" %>

<!-- Elements to show/hide -->
<div data-toggle-target="hideable"
     data-toggle-value="open"
     style="display:none;">
  Open auction options...
</div>

<div data-toggle-target="hideable"
     data-toggle-value="private">
  Private deal options...
</div>
```

**Values:**
- `hide-others` (boolean): Hide other targets when one is shown

**Targets:**
- `hideable`: Elements to show/hide based on value

---

### 6. Dynamic Table Controller

Add/remove table rows dynamically.

**Usage:**

```erb
<table data-controller="dynamic-table">
  <tbody>
    <tr>
      <td><input type="text" name="items[][name]"></td>
      <td><input type="text" name="items[][value]"></td>
      <td>
        <button type="button"
                data-action="click->dynamic-table#addRow"
                class="tableRowAdd">Add</button>
        <button type="button"
                data-action="click->dynamic-table#removeRow"
                class="tableRowRemove">Remove</button>
      </td>
    </tr>
  </tbody>
</table>

<!-- Template for new rows -->
<template data-dynamic-table-target="template">
  <tr>
    <td><input type="text" name="items[][name]"></td>
    <td><input type="text" name="items[][value]"></td>
    <td>
      <button type="button"
              data-action="click->dynamic-table#addRow"
              class="tableRowAdd">Add</button>
      <button type="button"
              data-action="click->dynamic-table#removeRow"
              class="tableRowRemove">Remove</button>
    </td>
  </tr>
</template>
```

**Actions:**
- `addRow`: Adds a new row after current row
- `removeRow`: Removes the row (or marks for deletion)

**Targets:**
- `template`: Template for new rows

---

### 7. Campaign Selector Controller

Loads campaign data and updates form fields.

**Usage:**

```erb
<%= select_tag :campaign_id, options_for_select(@campaigns),
    data: {
      controller: "campaign-selector",
      campaign_selector_url_value: "/campaigns/load.json",
      action: "change->campaign-selector#change"
    } %>

<%= text_field_tag :interval_start, "",
    data: { campaign_selector_target: "intervalStart" } %>

<%= text_field_tag :interval_end, "",
    data: { campaign_selector_target: "intervalEnd" } %>

<div data-campaign-selector-target="exchangeAttributes">
  <!-- Exchange attributes loaded here -->
</div>
```

**Values:**
- `url` (string): AJAX endpoint for loading campaign data

**Targets:**
- `intervalStart`: Start date field
- `intervalEnd`: End date field
- `exchangeAttributes`: Container for exchange attributes HTML

---

## Migration from jQuery

### Before (jQuery):

```javascript
$(document).ready(function() {
  $("select.nosearch").select2({
    minimumResultsForSearch: Infinity,
    width: '100%'
  });

  $("#listtable").DataTable({
    order: [[0, 'asc']],
    pageLength: 25
  });
});
```

### After (Stimulus):

```erb
<%= select_tag :category, options_for_select(@categories),
    class: "nosearch",
    data: {
      controller: "select2",
      select2_no_search_value: true
    } %>

<table id="listtable"
       data-controller="datatable"
       data-datatable-order-value='[[0, "asc"]]'
       data-datatable-page-length-value="25">
  ...
</table>
```

---

## Best Practices

1. **One controller per element**: Each data-controller should focus on one responsibility
2. **Use values for configuration**: Pass configuration through data attributes
3. **Use targets for references**: Reference DOM elements through targets
4. **Use actions for events**: Connect events through data-action
5. **Clean up on disconnect**: Always clean up in disconnect() lifecycle method

---

## Debugging

Enable Stimulus debug mode in `app/javascript/controllers/application.js`:

```javascript
application.debug = true
```

Check controller connections in browser console:

```javascript
// List all connected controllers
Stimulus.controllers

// Get controller instance
document.querySelector('[data-controller="select2"]')
  .stimulusControllerFor('select2')
```

---

## Resources

- [Stimulus Handbook](https://stimulus.hotwired.dev/handbook/introduction)
- [Stimulus Reference](https://stimulus.hotwired.dev/reference/controllers)
- [Hotwire Turbo](https://turbo.hotwired.dev/)
