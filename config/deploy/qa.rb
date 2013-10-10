role :web, "ss1qa.dlt.psu.edu", "ss2qa.dlt.psu.edu"
role :app, "ss1qa.dlt.psu.edu", "ss2qa.dlt.psu.edu"
role :solr, "ss1qa.dlt.psu.edu" # This is where resolrize will run
role :db,  "ss1qa.dlt.psu.edu", :primary => true # This is where Rails migrations will run
#role :db,  "your slave db-server here"
