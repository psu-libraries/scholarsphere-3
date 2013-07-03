(function( $ ){

  $.fn.proxyRights = function( options ) {  

    // Create some defaults, extending them with any options that were provided
    var settings = $.extend( { }, options);

    var $container = this;

    function addContributor(name, id) {
      console.log("Adding");
      data = {name: name, id: id}
      row = tmpl("tmpl-proxy-row", data);
      $('#authorizedProxies tbody', $container).append(row);

      if (settings.afterAdd) {
        settings.afterAdd(this, cloneElem);
      }

      $.ajax({
        type: "POST",
        url: 'depositors',
        dataType: 'json',
        data: {grantee_id: id},
        success: function (data) { }
      })

      return false;
    }

    function removeContributor () {
      // remove the row
      $.ajax({
        url: $(this).closest('a').prop('href'),
        type: "post",
        dataType: "json",
        data: {"_method":"delete"}
      });
      $(this).closest('tr').remove();
      return false;
    }

    $("#user").userSearch();
    $("#user").on("change", function() {
      // Remove the choice from the select2 widget and put it in the table.
      obj = $("#user").select2("data")
      $("#user").select2("val", '')
      addContributor(obj.text, obj.id);
    });

    return this.each(function() {        
      $('.remove-proxy-button', this).click(removeContributor);
    });

  };
})( jQuery );  


$(function() {
  $('.proxy-rights').proxyRights();
});
