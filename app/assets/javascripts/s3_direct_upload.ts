/// <reference types="jquery" />
/// <reference types="blueimp-file-upload" />

interface S3UploaderSettings {
  path: string;
  additional_data: Record<string, any> | null;
  before_add: ((file: File & { unique_id?: string }) => boolean) | null;
  remove_completed_progress_bar: boolean;
  remove_failed_progress_bar: boolean;
  progress_bar_target: JQuery | null;
  click_submit_target: JQuery | null;
  allow_multiple_files: boolean;
}

interface S3FileData {
  files: Array<File & { unique_id?: string }>;
  context?: JQuery;
  submit: () => void;
  loaded?: number;
  total?: number;
  result?: Document | string;
  errorThrown?: string;
}

interface S3Content {
  url?: string;
  filepath?: string;
  filename: string;
  filesize?: number;
  lastModifiedDate?: Date;
  filetype?: string;
  unique_id?: string;
  relativePath?: string;
  mediaId?: string;
  error_thrown?: string;
  [key: string]: any;
}

interface S3UploaderInstance {
  initialize: () => S3UploaderInstance;
  path: (new_path: string) => void;
  additional_data: (new_data: Record<string, any>) => void;
}

declare global {
  interface JQuery {
    S3Uploader(options?: Partial<S3UploaderSettings>): JQuery;
  }

  interface Window {
    FormData?: any;
    tmpl?: (templateId: string, data: any) => string;
  }
}

(function($: JQueryStatic) {
  $.fn.S3Uploader = function(options?: Partial<S3UploaderSettings>): JQuery {
    // Support multiple elements
    if (this.length > 1) {
      this.each(function() {
        $(this).S3Uploader(options);
      });
      return this;
    }

    const $uploadForm = this;

    const settings: S3UploaderSettings = {
      path: '',
      additional_data: null,
      before_add: null,
      remove_completed_progress_bar: true,
      remove_failed_progress_bar: false,
      progress_bar_target: null,
      click_submit_target: null,
      allow_multiple_files: true,
      ...options
    };

    let current_files: S3FileData[] = [];
    let forms_for_submit: S3FileData[] = [];

    if (settings.click_submit_target) {
      settings.click_submit_target.click(() => {
        forms_for_submit.forEach(form => form.submit());
        return false;
      });
    }

    const $wrapping_form = $uploadForm.closest('form');
    if ($wrapping_form.length > 0) {
      $wrapping_form.off('submit').on('submit', () => {
        $wrapping_form.find('.s3_uploader input').prop('disabled', true);
        return true;
      });
    }

    const cleanedFilename = (filename: string): string => {
      return filename.replace(/\s/g, '_').replace(/[^\w.-]/gi, '');
    };

    const hasRelativePath = (file: any): boolean => {
      return !!(file.relativePath || file.webkitRelativePath);
    };

    const buildRelativePath = (file: any): string | undefined => {
      if (file.relativePath) {
        return file.relativePath;
      }
      if (file.webkitRelativePath) {
        const parts = file.webkitRelativePath.split('/');
        return parts.slice(0, -1).join('/') + '/';
      }
      return undefined;
    };

    const buildContentObject = (
      $uploadForm: JQuery,
      file: File & { unique_id?: string },
      result?: Document | string
    ): S3Content => {
      const content: S3Content = {
        filename: file.name
      };

      if (result) {
        // Use the S3 response to set the URL to avoid character encoding bugs
        const $result = $(result);
        content.url = $result.find('Location').text();
        content.filepath = $('<a />').attr('href', content.url!)[0].pathname;
      } else {
        // IE <= 9 returns a null result object so we use the file object instead
        const domain = $uploadForm.find('input[type=file]').data('url');
        const key = $uploadForm.find('input[name=key]').val() as string;
        content.filepath = key
          .replace('/${filename}', '')
          .replace('/{cleaned_filename}', '');
        content.url = domain + key.replace('/${filename}', encodeURIComponent(file.name));
        content.url = content.url.replace('/{cleaned_filename}', cleanedFilename(file.name));
      }

      console.log('Build settings:' + JSON.stringify(settings));

      if ('size' in file) content.filesize = file.size;
      if ('lastModifiedDate' in file) content.lastModifiedDate = (file as any).lastModifiedDate;
      if ('type' in file) content.filetype = file.type;
      if (file.unique_id) content.unique_id = file.unique_id;
      if (hasRelativePath(file)) {
        const relativePath = buildRelativePath(file);
        if (relativePath) content.relativePath = relativePath;
      }

      if (settings.additional_data) {
        Object.assign(content, settings.additional_data);
      }

      return content;
    };

    const setUploadForm = (): void => {
      $uploadForm.find("input[type='file']").fileupload({
        add: (e: JQueryEventObject, data: S3FileData) => {
          const file = data.files[0];
          file.unique_id = Math.random().toString(36).substr(2, 16);

          if (!settings.before_add || settings.before_add(file)) {
            current_files.push(data);

            if ($('#template-upload').length > 0) {
              const tmpl = window.tmpl;
              if (tmpl) {
                data.context = $($.trim(tmpl('template-upload', file)));
                $(data.context).appendTo(settings.progress_bar_target || $uploadForm);
              }
            } else if (!settings.allow_multiple_files) {
              data.context = settings.progress_bar_target || undefined;
            }

            if (settings.click_submit_target) {
              if (settings.allow_multiple_files) {
                forms_for_submit.push(data);
              } else {
                forms_for_submit = [data];
              }
            } else {
              data.submit();
            }
          }
        },

        start: (e: JQueryEventObject) => {
          $uploadForm.trigger('s3_uploads_start', [e]);
        },

        progress: (e: JQueryEventObject, data: S3FileData) => {
          if (data.context && data.loaded !== undefined && data.total !== undefined) {
            const progress = parseInt(String((data.loaded / data.total) * 100), 10);
            data.context.find('.bar').css('width', progress + '%');
          }
        },

        done: (e: JQueryEventObject, data: S3FileData) => {
          const content = buildContentObject($uploadForm, data.files[0], data.result);
          const callback_url = $uploadForm.data('callback-url');

          if (callback_url) {
            const callbackParam = $uploadForm.data('callback-param');
            content[callbackParam] = content.url;

            // Hardcode media_id attribute. Not passed by default
            const mediaId = $uploadForm.data('media-id');
            if (mediaId) {
              content.mediaId = mediaId;
            }

            $.ajax({
              type: $uploadForm.data('callback-method'),
              url: callback_url,
              data: content,
              beforeSend: (xhr: JQueryXHR, ajaxSettings: JQueryAjaxSettings) => {
                const event = $.Event('ajax:beforeSend');
                $uploadForm.trigger(event, [xhr, ajaxSettings]);
                return event.result;
              },
              complete: (xhr: JQueryXHR, status: string) => {
                const event = $.Event('ajax:complete');
                $uploadForm.trigger(event, [xhr, status]);
                return event.result;
              },
              success: (responseData: any, status: string, xhr: JQueryXHR) => {
                const event = $.Event('ajax:success');
                $uploadForm.trigger(event, [responseData, status, xhr]);
                return event.result;
              },
              error: (xhr: JQueryXHR, status: string, error: string) => {
                const event = $.Event('ajax:error');
                $uploadForm.trigger(event, [xhr, status, error]);
                return event.result;
              }
            });
          }

          if (data.context && settings.remove_completed_progress_bar) {
            data.context.remove();
          }

          $uploadForm.trigger('s3_upload_complete', [content]);

          const index = current_files.indexOf(data);
          if (index > -1) {
            current_files.splice(index, 1);
          }

          if (!current_files.length) {
            $uploadForm.trigger('s3_uploads_complete', [content]);
          }
        },

        fail: (e: JQueryEventObject, data: S3FileData) => {
          const content = buildContentObject($uploadForm, data.files[0], data.result);
          content.error_thrown = data.errorThrown;

          if (data.context && settings.remove_failed_progress_bar) {
            data.context.remove();
          }

          $uploadForm.trigger('s3_upload_failed', [content]);
        },

        formData: function(form: HTMLFormElement) {
          const data = $uploadForm.find('input').serializeArray();
          let fileType = '';

          if (this.files && this.files[0] && 'type' in this.files[0]) {
            fileType = this.files[0].type;
          }

          data.push({
            name: 'content-type',
            value: fileType
          });

          let key = $uploadForm.data('key') as string;
          if (this.files && this.files[0]) {
            key = key
              .replace('{timestamp}', String(new Date().getTime()))
              .replace('{unique_id}', this.files[0].unique_id || '')
              .replace('{cleaned_filename}', cleanedFilename(this.files[0].name))
              .replace('{extension}', this.files[0].name.split('.').pop() || '');
          }

          // Substitute upload timestamp and unique_id into key
          const key_field = data.filter(n => n.name === 'key');

          if (key_field.length > 0) {
            key_field[0].value = settings.path + key;
          }

          // IE <= 9 doesn't have XHR2 hence it can't use formData
          // replace 'key' field to submit form
          if (!('FormData' in window)) {
            $uploadForm.find("input[name='key']").val(settings.path + key);
          }

          return data;
        }
      } as any);
    };

    // Public methods
    const instance: S3UploaderInstance = {
      initialize: function(): S3UploaderInstance {
        // Save key for IE9 Fix
        $uploadForm.data('key', $uploadForm.find("input[name='key']").val());
        setUploadForm();
        return this;
      },

      path: function(new_path: string): void {
        settings.path = new_path;
      },

      additional_data: function(new_data: Record<string, any>): void {
        settings.additional_data = new_data;
      }
    };

    return instance.initialize() as any;
  };
})(jQuery);
