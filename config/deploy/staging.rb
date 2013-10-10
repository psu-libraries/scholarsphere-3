role :web, "ss1stage.dlt.psu.edu", "ss2stage.dlt.psu.edu"
role :app, "ss1stage.dlt.psu.edu", "ss2stage.dlt.psu.edu"
role :solr, "ss1stage.dlt.psu.edu"  # This is where resolrize will run
role :db,  "ss1stage.dlt.psu.edu", :primary => true # This is where Rails migrations will run
#role :db,  "your slave db-server here"
