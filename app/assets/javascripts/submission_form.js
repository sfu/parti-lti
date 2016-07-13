$(document).ready(function () {

    var ua = navigator.userAgent.toLowerCase();
    var isAndroid = ua.indexOf("android") > -1; //&& ua.indexOf("mobile");
    var isChrome = ua.indexOf("chrome") > -1;
    var isFirefox = ua.indexOf("firefox") > -1;
    if(isAndroid && !isChrome && !isFirefox) {
        $('#flash').append('<div class="flash notice">For Android devices, Chrome and Firefox are the recommended browsers for uploading images. You may experience problems with other browsers.</div>');
    }

    var preview = $('#preview');
    var fileField = $('#select_image');
    var selectButton = $('<button>').text('Select Image...');
    var submitButton = $('form').find('input[type="submit"]');
    var lastSubmission = $('#last_submission');

    // Add the "Select Image..." button to replace the file field
    selectButton.on('click', function (event) {
        event.preventDefault();
        fileField.click();
    });
    selectButton.insertBefore(submitButton);
    fileField.hide();

    fileField.on('change', handleFileSelect);
    submitButton.prop('disabled', true);

    function displayError(filename, error) {
        fileField.val('');
        alert("Cannot accept file '" + filename + "'. " + error);
    }

    function handleFileSelect(event) {
        var file = event.target.files[0]; // Get the first file from the FileList object
        var previewImage = preview.find('img');
        var reader;

        // Reset states; these can be enabled/shown later as needed
        submitButton.prop('disabled', true);
        preview.hide();

        if (typeof file == 'undefined') { // No file selected; selection likely canceled by user
            preview.hide();
            previewImage.attr('src', '');
            return;
        }

        if (typeof file.type === 'undefined' || file.type.length === 0) {
            // report this as an error
            // recommend that they use another browser
            displayError(file.name, "Cannot determine the type of this file. You either have a corrupted file or you need to use another browser like Chrome or Firefox.");
            return;
        }

        if (file.type.match('image.*')) { // Only process image files
            reader = new FileReader();
            reader.onload = function () {
                // Preview the selected image
                previewImage.attr('src', reader.result);
                preview.show();
                lastSubmission.hide();
            };

            if (file.size > 10000000) {
                displayError(file.name, 'You need to upload an image smaller than 10MB.');
            } else {
                // Read in the image file as a data URL
                reader.readAsDataURL(file);
                submitButton.prop('disabled', false);
            }
        } else {
            displayError(file.name, 'You need to upload an image, such as jpg, jpeg, png, and gif.');
        }
    }
});
