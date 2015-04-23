module SufiaHelper
  include ::BlacklightHelper
  include Blacklight::CatalogHelperBehavior
  include Sufia::BlacklightOverride
  include Sufia::SufiaHelperBehavior

  def render_characterization_terms
    if characterization_terms.values.flatten.map(&:empty?).reduce(true) { |sum, value| sum && value }
      "not yet characterized"
    else
      render partial: "show_characterization_details"
    end
  end

  def characterization_terms terms = Hash.new
    FitsDatastream.terminology.terms.each_pair do |k, v|
      next unless v.respond_to? :proxied_term
      term = v.proxied_term
      begin
        value = @generic_file.send(term.name)
        terms[term.name] = value unless value.empty?
      rescue NoMethodError
        next
      end
    end
    terms
  end
end
