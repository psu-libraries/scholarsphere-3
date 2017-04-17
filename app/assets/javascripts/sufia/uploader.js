// Overrides Sufia's uploader.js
// Injects new UI behavior where auto-uploading is disabled and a new button is provided to
// being uploading all the files after their records are individually added to the DOM.
// Although this does add on additional step to the workflow, it avoids the problems
// we were seeing in #453, while at the same time enables non-sequential, concurrent
// uploading for increased performance.

//= require fileupload/tmpl
//= require fileupload/jquery.iframe-transport
//= require fileupload/jquery.fileupload.js
//= require fileupload/jquery.fileupload-process.js
//= require fileupload/jquery.fileupload-validate.js
//= require fileupload/jquery.fileupload-ui.js
//
/*
 * jQuery File Upload Plugin JS Example
 * https://github.com/blueimp/jQuery-File-Upload
 *
 * Copyright 2010, Sebastian Tschan
 * https://blueimp.net
 *
 * Licensed under the MIT license:
 * http://www.opensource.org/licenses/MIT
 */

(function( $ ){
  'use strict';

  $.fn.extend({
    sufiaUploader: function( options ) {
      // Initialize our jQuery File Upload widget.
      this.fileupload($.extend({
        sequentialUploads: false,
        limitConcurrentUploads: 6,
        maxNumberOfFiles: 100,
        maxFileSize: 500000000, // bytes, i.e. 500 MB
        autoUpload: false,
        url: '/uploads/',
        type: 'POST',
        dropZone: $(this).find('.dropzone')
      }, options))
      .bind('fileuploadadded', function (e, data) {
        $(e.currentTarget).find('button.cancel').removeClass('hidden');
        $(e.currentTarget).find('div#all_files').removeClass('hidden');
      })
      .bind('fileuploadcompleted', function (e, data) {
        if ($('button.start').length == 0)
          $(e.currentTarget).find('div#all_files').addClass('hidden');
      });

      $(document).bind('dragover', function(e) {
        var dropZone = $('.dropzone'),
            timeout = window.dropZoneTimeout;
        if (!timeout) {
            dropZone.addClass('in');
        } else {
            clearTimeout(timeout);
        }
        var found = false,
            node = e.target;
        do {
            if (node === dropZone[0]) {
                found = true;
                break;
            }
            node = node.parentNode;
        } while (node !== null);
        if (found) {
            dropZone.addClass('hover');
        } else {
            dropZone.removeClass('hover');
        }
        window.dropZoneTimeout = setTimeout(function () {
            window.dropZoneTimeout = null;
            dropZone.removeClass('in hover');
        }, 100);
      });

      $('button.all').on('click', function(event) {
        event.preventDefault();
        $('button.start').click();
      });
    }
  });
})(jQuery);
