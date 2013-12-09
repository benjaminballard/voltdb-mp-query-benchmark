# VoltDB Example App: Ad Performance#

This repository is a variant of the VoltDB Ad Performance example application, with an additional query benchmark for testing Multi-partition queries.

Use Case
--------
This application simulates a high velocity stream of events (impressions, clickthroughs, conversions) that are enriched and ingested.  These events are randomly generated in the client, but represent a stream of events that would be received from web traffic.

The "TrackEvent" stored procedure processes these events.  It looks up the corresponding advertiser and campaign based on the creative ID which represents which ad was shown.  It also retrieves the corresponding web site and page based on the inventory ID from the event.  The timestamp and event type fields are converted to aid in aggregation, and all of this data is then inserted into the impression_data table.

Several views maintain real-time aggregations on this table to provide a minutely summary for each advertiser, plus drill-down reports grouped by campaign and creative to show detail-level metrics, costs and rates with real-time accuracy.

Code organization
-----------------
The code is divided into two projects:

- "db": the database project, which contains the schema, stored procedures and other configurations that are compiled into a catalog and run in a VoltDB database.  
- "client": a java client that loads a set of cards and then generates random card transactions a high velocity to simulate card activity.
- "web": a web dashboard client (static html page with dynamic content)

See below for instructions on running these applications.  For any questions, 
please contact fieldengineering@voltdb.com.

Pre-requisites
--------------
Before running these scripts you need to have VoltDB installed, and you should add the voltdb-$(VERSION)/bin directory to your PATH environment variable, for example:

    export PATH="$PATH:$HOME/voltdb-$(VERSION)/bin"


Instructions
------------

1. Start the database in the background

    ./start_db.sh
     
2. Run the client application

    ./run_client.sh

3. Open the web/adperformance.html page in a web browser to view the real-time dashboard

4. Run the query client application

    ./run_query_client.sh

5. To stop the database and clean up temp files

    voltadmin shutdown
    ./clean.sh


Options
-------
You can control various characteristics of the demo by modifying the parameters passed into the InvestmentBenchmark java application in the run_client.sh script.

Speed & Duration:

    --duration=120                (benchmark duration in seconds)
    --autotune=true               (true = ignore rate limit, run at max throughput until latency is impacted)
                                  (false = run at the specified rate limit)
    --ratelimit=20000             (when autotune=false, run up to this rate of requests/second)

Metadata volumes and ratios:

    --sites=100                   (number of web sites where ad events may occur)
    --pagespersite=10             (number of pages per web site)
    --advertisers=100             (number of advertisers)
    --campaignsperadvertiser=10   (number of campaigns per advertiser)
    --creativespercampaign=5      (number of creatives or banners per campaign)

You can also set the following parameters in the run_query_client.sh script to change the behavior of the query benchmark:

    --duration=120                  (benchmark duration in seconds)
    --autotune=true                 (true = ignore rate limit, run at max throughput until latency is impacted)
                                    (false = run at the specified rate limit)
    --ratelimit=20000               (when autotune=false, run up to this rate of requests/second)
    --queryname=advertiser_summary  (the other option: =advertiser_minutely_clicks)

Instructions for running on a cluster
-------------------------------------

Before running this demo on a cluster, make the following changes:

1. On each server, edit the start_db.sh file to set the HOST variable to the name of the **first** server in the cluster:
    
    HOST=voltserver01
    
2. On each server, edit db/deployment.xml to change hostcount from 1 to the number of servers:

    <cluster hostcount="1" sitesperhost="3" kfactor="0" />

4. On each server, run the start script:

    ./start_db.sh
    
5. On one server, Edit the run_client.sh script to set the SERVERS variable to a comma-separated list of the servers in the cluster

    SERVERS=voltserver01,voltserver02,voltserver03
    
6. Run the client script:

    ./run_client.sh



