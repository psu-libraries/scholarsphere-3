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
        return fileField.size() > 0
    }

    get hasNewFiles() {
        // In a future release hasFiles will include files already on the work plus new files,
        // but hasNewFiles() will include only the files added in this browser window.
        return this.hasFiles
    }
}