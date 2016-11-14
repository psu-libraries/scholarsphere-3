//500 MB  max file size 
max_file_size = 500000000;
max_file_size_str = "500 MB";
//500 MB max total upload size
max_total_file_size = 1000000000;
max_total_file_size_str = "1000 MB";

Blacklight.onLoad(function() {
    $(":input").focusin(function () {
        $(this).addClass("has-focus");
    });
    $(":input").focusout(function () {
        $(this).removeClass("has-focus");
    });
});
