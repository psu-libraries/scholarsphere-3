// Callbacks for tracking events using Google Analytics
// This changes Sufia's implementation to use a css class instead of an id, enabling us
// to track multiple download links in a page.

$(document).on('click', '.ga-download', function(e) {
  _gaq.push(['_trackEvent', 'Files', 'Downloaded', $(this).data('label')]);

});

