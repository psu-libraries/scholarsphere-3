Blacklight.onLoad(function() {
  $(":input").focusin(function () {
    $(this).addClass("has-focus");
  });
  $(":input").focusout(function () {
    $(this).removeClass("has-focus");
  });

  $("#new_generic_work, #new_batch_upload_item, .edit_generic_work").on('submit', function(event) {
    $(".panel-footer").toggleClass("hidden");
  });
});
