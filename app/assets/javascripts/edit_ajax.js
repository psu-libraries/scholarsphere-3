// Adding in this file since sufia is adding loading onto the wrong div, so no loading indication is given
//  This override should be removed once sufia changes to add loading onto detail_ instead of collapse_ here:
// https://github.com/projecthydra/sufia/blob/master/app/assets/javascripts/sufia/batch_edit.js#L107 & https://github.com/projecthydra/sufia/blob/master/app/assets/javascripts/sufia/batch_edit.js#L117

//$( document ).ajaxSend(function( event, jqxhr, settings ) {
//    form_id = settings["form"];
//    if ((form_id) && (typeof(myVar) != 'undefined')) {
//        var key = form_id.replace("form_", "");
//        if (key) {
//            var outer_div = "#detail_" + key;
//            $(outer_div).addClass("loading");
//        }
//    }
//});
//
//$( document ).ajaxSuccess(function( event, jqxhr, settings ) {
//    form = settings["form"];
//    form_id = settings["form"];
//    if ((form_id) && (typeof(myVar) != 'undefined')) {
//        var key = form_id.replace("form_", "");
//        if (key) {
//            var outer_div = "#detail_" + key;
//            $(outer_div).removeClass("loading");
//        }
//    }
//});
//
//$( document ).ajaxError(function( event, jqxhr, settings ) {
//    form = settings["form"];
//    form_id = settings["form"];
//    if (form_id) {
//        var key = form_id.replace("form_", "");
//        if (key) {
//            var outer_div = "#detail_" + key;
//            $(outer_div).removeClass("loading");
//        }
//    }
//    }
//});