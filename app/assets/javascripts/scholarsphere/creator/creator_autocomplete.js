ScholarSphere.creatorAutocomplete = {
  /**
   * Object for setting up Typeahead and Bloodhound
   */
  nameQuery: {},
  initBloodhound: function () {
    this.nameQuery = new Bloodhound({
      datumTokenizer: Bloodhound.tokenizers.obj.whitespace('given_name','sur_name'),
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
        source: this.nameQuery,
        templates: {
          empty: '<p>  Unable to find any results  </p>',
          suggestion: function (data) {
            return '<p>' + data.display_name + '</p>'
          }
        },
        display: function (data) {
          return data.display_name
        }
      })
  },
  typeaheadSelect: function (index) {
    $('#find_creator').bind('typeahead:select', function (ev, suggestion) {
      var creator = Object.create(ScholarSphere.creator)
      creator.firstName = suggestion.given_name
      creator.lastName = suggestion.sur_name
      creator.displayName = suggestion.display_name
      creator.email = suggestion.email
      creator.psuId = suggestion.psu_id
      creator.orcidId = suggestion.orcid_id
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
