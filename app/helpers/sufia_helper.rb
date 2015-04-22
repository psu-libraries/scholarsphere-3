module SufiaHelper
  include ::BlacklightHelper
  include Blacklight::CatalogHelperBehavior
  include Sufia::BlacklightOverride
  include Sufia::SufiaHelperBehavior

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
