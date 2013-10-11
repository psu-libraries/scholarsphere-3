role :web, "ss1prod.dlt.psu.edu", "ss2prod.dlt.psu.edu"
role :app, "ss1prod.dlt.psu.edu", "ss2prod.dlt.psu.edu"
role :solr, "ss1prod.dlt.psu.edu"  # This is where resolrize will run
role :db,  "ss1prod.dlt.psu.edu", :primary => true # This is where Rails migrations will run
#role :db,  "your slave db-server here"
