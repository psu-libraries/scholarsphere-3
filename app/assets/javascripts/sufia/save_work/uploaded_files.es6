// Overrides Sufia to add the fileuploaddestroyed callback so the form re-checks that the file requirement
// is met. Avoids a bug where works could be created without files if the file was uploaded then deleted.

export class UploadedFiles {
    // Monitors the form and runs the callback when files are added
    // Adds a fileuploaddestroyed callback which is not present in the source code
    // but is documented in the jQuery-File-Upload Github wiki.
    constructor(form, callback) {
        this.form = form
        this.element = $('#fileupload')
        this.element.bind('fileuploadcompleted', callback)
        this.element.bind('fileuploaddestroyed', callback)
    }

    get hasFileRequirement() {
        let fileRequirement = this.form.find('li#required-files')
        return fileRequirement.size() > 0
    }

    get inProgress() {
        return this.element.fileupload('active') > 0
    }

    get hasFiles() {
        let fileField = this.form.find('input[name="uploaded_files[]"]')
        this.updatePercentageLimit
        if (fileField.size() > 0) {
            if (this.totalUploadSize <= this.totalLimit) {
                this.element.find("#sizealert").addClass("hidden")
                return true
            }
            else {
                this.element.find("#sizealert").removeClass("hidden")
                return false
            }
        }
        else {
            this.element.find("#sizealert").addClass("hidden")
            return false
        }
    }

    get hasNewFiles() {
        // In a future release hasFiles will include files already on the work plus new files,
        // but hasNewFiles() will include only the files added in this browser window.
        return this.hasFiles
    }

    get totalUploadSize() {
        let total = 0
        this.form.find('.size').map(function() {
            if (!isNaN($(this).data('size')))
                total = total + $(this).data('size')
        })
        return total
    }

    get totalLimit() {
        return this.element.data('limit')
    }

    get updatePercentageLimit() {
        let percentage_value = Math.round((this.totalUploadSize * 100 / this.totalLimit)) + '%'
        $('#sizeprogress').css('width', percentage_value)
        $('#sizeprogress').text(percentage_value)
    }
}
