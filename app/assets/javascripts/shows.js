
$(document).ready(function() {
    $('#show-img-select').on('click', function(e) {
        $('#show-img-file').click();
    });

    $("#show-img-file").change(function(e) {
        var ext = $(this).val().split('.').pop().toLowerCase();
        if($.inArray(ext, ['gif','png','jpg','jpeg']) == -1) {
            alert("Please upload an image with a valid extension.");
            return;
        }
        showBannerPreview(this);
    });
});

function showBannerPreview(input) {
    if (input.files && input.files[0]) {
        var reader = new FileReader();

        reader.onload = function(e) {
            $('#banner_preview_cont').removeClass('hidden');
            $('#banner_preview').attr('src', e.target.result);
        }

        reader.readAsDataURL(input.files[0]);
    }
}