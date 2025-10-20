//= require s3_direct_upload

// Interface for S3 upload content
interface S3UploadContent {
  filename: string;
  filepath: string;
  filesize?: number;
  url: string;
  filetype?: string;
  lastModifiedDate?: Date;
  unique_id?: string;
  relativePath?: string;
}

// Interface for S3Uploader options
interface S3UploaderOptions {
  progress_bar_target?: any;
  remove_completed_progress_bar?: boolean;
  additional_data?: Record<string, any>;
}

// Declare jQuery as available globally
declare const $: any;

// jQuery ready handler
$(() => {
  // Initialize S3 uploader
  $("#s3-uploader").S3Uploader({
    progress_bar_target: $('.js-progress-bars'),
    remove_completed_progress_bar: true,
    additional_data: {
      id: $("#item_id").val() as string,
      attachto: "description"
    }
  });

  // Handle upload complete event
  $('#s3-uploader').bind("s3_upload_complete", (e: any, content: S3UploadContent) => {
    // console.log("Updating s3_direct_update script started...")
    // console.log("Content " + JSON.stringify(content))

    $('#uploads_container').append(`<br/><span>${content.filename} uploaded.</span>`);
    $('#media_filetype').val(content.filetype || '');
    $('#media_filepath').val(unescape(content.filepath));
    $('#media_filesize').val(content.filesize?.toString() || '');
    $('#media_s3_url').val(unescape(content.url));
    $('#media_last_modified').val(content.lastModifiedDate?.toString() || '');

    // console.log("Updating s3_direct_update script ended.")
  });
});
