# frozen_string_literal: true

class FieldConfig
  attr_reader :label, :opts
  def initialize(opts_or_label)
    if opts_or_label.is_a? Hash
      @label = opts_or_label[:label]
      @opts = opts_or_label
    else
      @label = opts_or_label
      @opts = { label: opts_or_label, solr_type: :facetable }
    end
  end
end
