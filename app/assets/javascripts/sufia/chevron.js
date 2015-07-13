Blacklight.onLoad(function () {
    // plus/minus
    $('.glyphicon-chevron-right').on('click', function() {
        toggle_chevron(this)
    });

    // plus/minus
    $('.glyphicon-chevron-down').on('click', function() {
        toggle_chevron(this);
    });

    function toggle_chevron(item) {
        var array = item.id.split("expand_");
        if (array.length > 1) {
            var docId = array[1];
            $("#expand_" + docId ).toggleClass('glyphicon-chevron-right glyphicon-chevron-down');
        }
    }


});
