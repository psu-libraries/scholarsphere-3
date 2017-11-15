ScholarSphere.creatorBehavior = {
    /**
     * Object for activating add/remove functionality
     */
  activateAddButton: function () {
    $('.add-creator').on('click', function () {
      var creator = Object.create(ScholarSphere.creator)

      ScholarSphere.creatorIndex.index += 1
      creator.index = ScholarSphere.creatorIndex.index

      var template = $('#creator_template').html()
      var render = Mustache.render(template, creator)
      $('.creator_container').append(render)
      ScholarSphere.creatorBehavior.activateRemoveButton()
      $('.creator_container').trigger("managed_field:add")
        if ($('.remove-creator').length == 1)
            $('.remove-creator').hide()
        else
            $('.remove-creator').show()
    })
  },
  activateRemoveButton: function () {
    $('.creator_container').on('click', '.remove-creator', function () {
        $(this).parent().remove()
        if ($('.remove-creator').length == 1)
            $('.remove-creator').hide()
        else
            $('.remove-creator').show()
    })
  }
}

Blacklight.onLoad(function () {
  ScholarSphere.creatorBehavior.activateAddButton()
  ScholarSphere.creatorBehavior.activateRemoveButton()
  ScholarSphere.creatorIndex.index = $('.creator_inputs').length - 1
})
