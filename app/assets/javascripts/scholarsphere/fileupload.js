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

  // Using Bootstrap's tab links won't work if they're outside of the tabs they're controlling.
  // Here we do it "manually"
  $('.tabfaker').on('click', function(event) {
    var metadata_tab = $("ul.nav-tabs li")[0];
    var files_tab = $("ul.nav-tabs li")[1];

    $("ul.nav-tabs li").removeClass("active");
    $("div.tab-content div").removeClass("active");

    if ($(this).attr("href") == "#metadata") {
      $(metadata_tab).addClass("active");
      $("div#metadata").addClass("active");
    }

    if ($(this).attr("href") == "#files"){
      $(files_tab).addClass("active");
      $("div#files").addClass("active");
    }
  });
});
