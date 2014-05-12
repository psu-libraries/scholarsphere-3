role :web, "ss2test.dlt.psu.edu"
role :app, "ss2test.dlt.psu.edu"
role :solr, "ss2test.dlt.psu.edu" # This is where resolrize will run
role :db,  "ss2test.dlt.psu.edu", primary: true # This is where Rails migrations will run
#role :db,  "your slave db-server here"
