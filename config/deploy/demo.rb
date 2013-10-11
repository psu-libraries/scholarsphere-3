role :web, "ss3test.dlt.psu.edu"
role :app, "ss3test.dlt.psu.edu"
role :solr, "ss3test.dlt.psu.edu" # This is where resolrize will run
role :db,  "ss3test.dlt.psu.edu", :primary => true # This is where Rails migrations will run
#role :db,  "your slave db-server here"
