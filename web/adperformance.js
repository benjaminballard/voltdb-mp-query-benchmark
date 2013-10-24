// variables for selected row of table
var selectedCampaign = $('#table_ad_sum').children('td:first').text();
var selectedIndex = -1;

function RefreshTable1(){
    con.BeginExecute('advertiser_summary', 
                     [30], 
                     function(response) {
                         DrawTable(response,'#table_ad_sum',selectedIndex)}
                    );
}

function RefreshTable2(){
    con.BeginExecute('campaign_summary', 
                     [30,selectedCampaign], 
                     function(response) {
                         DrawTable(response,'#table_camp_sum',-1);
                     }
                    );
}

function RefreshData(){
    RefreshTable1();
    RefreshTable2();
}

// when you click to select a row
$('#table_ad_sum').on('click', 'tbody tr', function(event) {
    // row was clicked
    selectedCampaign = $(this).children('td:first').text();
    selectedIndex = $(this).index();
    $(this).addClass('success').siblings().removeClass('success');
    // immediately refresh the drill-down table
    RefreshTable2();
});
