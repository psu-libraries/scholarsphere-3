Blacklight.onLoad(function () {
    /*
     *  Tag cloud(s)
     */
    $(".tagcloud").blacklightTagCloud({
        size: {start: 0.9, end: 2.5, unit: 'em'},
        cssHooks: {granularity: 15},
        color: {start: '#667E45', end: '#468181'}
    });


});
