# frozen_string_literal: true
module ApplicationHelper
  def collection_search_parameters?
    !params[:cq].blank?
  end

  def collection_helper_method(value)
    c = Collection.load_instance_from_solr(value)
    c.title
  end

  def link_to_help(subject)
    link_to '#', id: "#{subject}_help", rel: 'popover',
                 'data-content' => t("hydra.metadata_help.#{subject}_html"), 'data-original-title' => subject.titleize,
                 'aria-label' => "Help for #{subject.titleize}" do
      help_icon
    end
  end

  def help_icon
    content_tag 'i', nil, "aria-hidden" => true, class: "help-icon"
  end
end
