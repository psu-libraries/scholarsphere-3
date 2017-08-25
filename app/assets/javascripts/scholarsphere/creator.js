Blacklight.onLoad(function() {
  $('.add-creator').on('click',function() {
    var creatorInput = $(this).prev().find('.creator_inputs').first()
    creatorInput.wrap('<div>')
    $(this).prev().append(incrementCreator(creatorInput.parent().html()))
  })
})

function incrementCreator(creatorInput) {
  var inputCount = $('.creator_inputs').length
  return creatorInput.replace(/0/g,inputCount)
}