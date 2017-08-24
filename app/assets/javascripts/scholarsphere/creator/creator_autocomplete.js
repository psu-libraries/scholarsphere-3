ScholarSphere.creatorAutocomplete = {
  /**
   * Object for setting up Typeahead and Bloodhound
   */
  nameQuery: {},
  initBloodhound: function () {
    this.nameQuery = new Bloodhound({
      datumTokenizer: Bloodhound.tokenizers.obj.whitespace('first_name_tesim','last_name_tesim'),
      queryTokenizer: Bloodhound.tokenizers.whitespace,
      limit: 10,
      remote: {
        url: '/creators/name_query?q=%QUERY',
        wildcard: '%QUERY'
      }
    })
    this.nameQuery.initialize()
  },
  activateTypeahead: function (index) {
    $('#find_creator').typeahead({
      highlight: true
    },
      {
        name: 'creators',
        display: 'first_name_tesim',
        source: this.nameQuery,
        templates: {
          empty: '<p>  Unable to find any results  </p>',
          suggestion: function (data) {
            return '<p>' + data.first_name_tesim + ' ' + data.last_name_tesim + '</p>'
          }
        },
        display: function (data) {
          return data.first_name_tesim + ' ' + data.last_name_tesim
        }
      })
  },
  typeaheadSelect: function (index) {
    $('#find_creator').bind('typeahead:select', function (ev, suggestion) {
      var creator = Object.create(ScholarSphere.creator)
      creator.firstName = suggestion.first_name_tesim
      creator.lastName = suggestion.last_name_tesim
      creator.index = $('.creator_inputs').length
      creator.id = suggestion.id
      creator.readonly = 'readonly'
      var template = $('#creator_template').html()
      var render = Mustache.render(template, creator)
      $('.creator_container').append(render)
    })
  },
  typeaheadClose: function () {
    $('#find_creator').bind('typeahead:close', function (ev, suggestion) {
      $('#find_creator').val('')
    })
  }
}

Blacklight.onLoad(function () {
  ScholarSphere.creatorAutocomplete.initBloodhound()
  ScholarSphere.creatorAutocomplete.activateTypeahead()
  ScholarSphere.creatorAutocomplete.typeaheadSelect()
  ScholarSphere.creatorAutocomplete.typeaheadClose()
})
