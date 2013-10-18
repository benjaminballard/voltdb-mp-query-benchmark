function RefreshData(){
    con.BeginExecute('advertiser_summary', 
                     [30], 
                     function(response) {
                         DrawTable(response,'#table1')}
                    );
}

