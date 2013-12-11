role :web, "ss1demo.dlt.psu.edu"
role :app, "ss1demo.dlt.psu.edu"
role :solr, "ss1demo.dlt.psu.edu" # This is where resolrize will run
role :db,  "ss1demo.dlt.psu.edu", :primary => true # This is where Rails migrations will run
#role :db,  "your slave db-server here"
