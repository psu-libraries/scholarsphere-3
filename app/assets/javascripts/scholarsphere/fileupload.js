Blacklight.onLoad(function() {
  $(":input").focusin(function () {
    $(this).addClass("has-focus");
  });
  $(":input").focusout(function () {
    $(this).removeClass("has-focus");
  });
});
