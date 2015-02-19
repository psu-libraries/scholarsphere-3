Sitemap::Generator.instance.load(host: 'scholarsphere.psu.edu') do
  path :root, priority: 1, change_frequency: 'weekly'
  path :catalog_index, priority: 1, change_frequency: 'weekly'
  User.all.each do |user|
    literal Sufia::Engine.routes.url_helpers.profile_path(user.login), priority: 0.8, change_frequency: 'daily'
  end
  read_group = Solrizer.solr_name('read_access_group', :symbol)
  GenericFile.where(read_group => 'public').each do |f|
    literal Sufia::Engine.routes.url_helpers.generic_file_path(f), priority: 1, change_frequency: 'weekly'
  end
  Collection.where(read_group => 'public').each do |c|
    literal Hydra::Collections::Engine.routes.url_helpers.collection_path(c), priority: 1, change_frequency: 'weekly'
  end
end
