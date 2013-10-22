function RefreshData(){

    // todo get advertiser id from web page
    con.BeginExecute('advertiser_summary', 
                     [30], 
                     function(response) {
                         DrawTable(response,'#table_ad_sum')}
                    );

    // todo get campaign id from web page
    con.BeginExecute('campaign_summary', 
                     [30,1], 
                     function(response) {
                         DrawTable(response,'#table_camp_sum');
                     }
                    );

}

$('#table_ad_sum > tbody > tr').click(function() {
    // row was clicked
    console.log("you clicked a row!");
});
