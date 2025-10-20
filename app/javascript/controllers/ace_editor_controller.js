import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="ace-editor"
export default class extends Controller {
  static targets = ["textarea", "editor"]
  static values = {
    mode: { type: String, default: "html" },
    theme: { type: String, default: "chrome" },
    readonly: { type: Boolean, default: false },
    showGutter: { type: Boolean, default: true },
    showPrintMargin: { type: Boolean, default: false },
    wrapMode: { type: Boolean, default: true }
  }

  connect() {
    // Initialize ACE editor
    this.editor = ace.edit(this.editorTarget)

    // Configure editor
    this.editor.setTheme(`ace/theme/${this.themeValue}`)
    this.editor.setShowPrintMargin(this.showPrintMarginValue)
    this.editor.setReadOnly(this.readonlyValue)
    this.editor.renderer.setShowGutter(this.showGutterValue)

    // Set mode
    this.editor.session.setMode(`ace/mode/${this.modeValue}`)
    this.editor.session.setUseWrapMode(this.wrapModeValue)

    // Load content from textarea
    if (this.hasTextareaTarget && this.textareaTarget.value) {
      this.editor.setValue(this.textareaTarget.value)
      this.editor.clearSelection()
    }

    // Focus editor
    this.editor.focus()
    this.editor.resize()

    // Sync changes back to textarea
    this.editor.session.on('change', () => {
      if (this.hasTextareaTarget) {
        this.textareaTarget.value = this.editor.getValue()
      }
    })

    // Handle form submission
    const form = this.element.closest('form')
    if (form) {
      form.addEventListener('submit', this.handleSubmit.bind(this))
    }

    // Make editor resizable
    this.makeResizable()
  }

  disconnect() {
    if (this.editor) {
      this.editor.destroy()
      this.editor = null
    }
  }

  handleSubmit(event) {
    if (this.hasTextareaTarget) {
      this.textareaTarget.value = this.editor.getValue()
    }
  }

  makeResizable() {
    if (typeof $ !== 'undefined' && $.fn.resizable) {
      $(this.editorTarget).resizable({
        resize: () => {
          if (this.editor) {
            this.editor.resize()
          }
        }
      })
    }
  }

  getValue() {
    return this.editor ? this.editor.getValue() : ''
  }

  setValue(value) {
    if (this.editor) {
      this.editor.setValue(value)
      this.editor.clearSelection()
    }
  }
}
