/*
Copyright © 2012 The Pennsylvania State University

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/


//= require jquery
// require jquery-1.8.2.min
//= require jquery_ujs
// require jquery_ujs.js
// require jquery-ui-1.8.23.custom.min
// require blacklight
//= require blacklight/blacklight
//= require sufia
//= require batch_edit
//= require bootstrap-tab
//= require scholarsphere_fileupload
//

// Patch for bootstrap-tab enabling linking/refreshing to a tab
// TODO move to sufia
$(document).ready(function(){
  // Javascript to enable link to tab
  var hash = document.location.hash;
  var prefix = "tab_";
  if (hash) {
      $('.nav-tabs a[href='+hash.replace(prefix,"")+']').tab('show');
  } 
  

  // Change hash for page-reload
  $('.nav-tabs a').on('shown', function (e) {
    window.location.hash = e.target.hash.replace("#", "#" + prefix);
  })
});
