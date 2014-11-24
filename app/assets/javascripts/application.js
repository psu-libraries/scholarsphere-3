//= require jquery
//= require jquery_ujs
//= require blacklight/blacklight
//= require sufia
//= require batch_edit
//= require scholarsphere_fileupload
//= require hydra/batch_select
//= require hydra_collections
//= require sufia/single_use_link
//= require edit_ajax

function modal_collection_list(action, event){
  if(action == 'open'){
    $(".collection-list-container").css("visibility", "visible");
  }
  else if(action == 'close'){
    $(".collection-list-container").css("visibility", "hidden");
  }

  event.preventDefault();
}
