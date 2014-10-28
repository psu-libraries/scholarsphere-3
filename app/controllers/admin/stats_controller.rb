# -*- encoding : utf-8 -*-

class Admin::StatsController < ApplicationController
  def index
    @users_count = User.count

    # The 5 most recent users to join
    @users_stats = params.fetch(:users_stats, {})
    if @users_stats[:start_date]
      #@user_stats[:start_date] ||= 7.days.ago
      @recent_users = User.where('created_at >= ?',  @users_stats[:start_date])
    else
      @recent_users = User.order('created_at DESC').limit(5).select('display_name, login, created_at, department')
    end

    # Query Solr for top 5 depositors
    depositor_key = Solrizer.solr_name('depositor', :stored_searchable, type: :string)
    top_depositors_url = "#{ActiveFedora.solr_config[:url]}/terms?terms.fl=#{depositor_key}&terms.sort=count&terms.limit=5&wt=json&omitHeader=true"
    # Parse JSON response (looks like {"terms":{"depositor_tesim":["mjg36",3]}})
    depositors_json = open(top_depositors_url).read
    depositor_tuples = JSON.parse(depositors_json)['terms'][depositor_key] rescue []
    # Change to hash where keys = logins and values = counts
    @active_users = Hash[*depositor_tuples]

    # Count of documents by permissions
    ActiveFedora::SolrService.instance.conn.commit("expungeDeletes"=>true)
    @files_count = {}
    @files_count[:total] = GenericFile.count
    @files_count[:public] = GenericFile.where(Solrizer.solr_name('read_access_group', :symbol) => 'public').count
    @files_count[:psu] = GenericFile.where(Solrizer.solr_name('read_access_group', :symbol) =>'registered').count
    @files_count[:private] = @files_count[:total] - (@files_count[:psu] + @files_count[:public])

    # Query Solr for top 5 depositors
    format_key = Solrizer.solr_name('file_format', Solrizer::Descriptor.new(:string, :indexed, :multivalued))
    top_formats_url = "#{ActiveFedora.solr_config[:url]}/terms?terms.fl=#{format_key}&terms.sort=count&terms.limit=5&wt=json&omitHeader=true"
    formats_json = open(top_formats_url).read
    format_tuples = JSON.parse(formats_json)['terms'][format_key] rescue []
    # Change to hash where keys = logins and values = counts
    @top_formats = Hash[*format_tuples]

    render 'index'
  end
end
