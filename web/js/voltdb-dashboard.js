var con;
var intervalId;
var firsttime = 1;

function formatDecimal2(n) {
    return (Math.round(parseFloat(n) * 100) / 100).toFixed(2);
}

function DrawTable(response, tableName) {
    try {
        var tables = response.results;
        var hmt = tables[0];
        var colcount = hmt.schema.length;
        
        // first time only, initialize the table head
        if (firsttime == 1) {
            var theadhtml = '<tr>';
            for (var i=0; i<colcount; i++) {
                theadhtml += '<td>' + hmt.schema[i].name + '</td>';
            }
            $(tableName).append('<thead></thead>');
            $(tableName).append('<tbody></tbody>');
            $(tableName).children('thead').html(theadhtml);
            firsttime = 0;
        }
        
        var tbodyhtml;
        for(var r=0;r<hmt.data.length;r++){ // for each row
            tbodyhtml += '<tr>';
            for (var c=0;c<colcount;c++) { // for each column
                var f = hmt.data[r][c];

                // if type is DECIMAL
                if (hmt.schema[c].type == 22) {
                    f = formatDecimal2(f);
                }
                tbodyhtml += '<td>' + f + '</td>';
            }
            tbodyhtml += '</tr>';
        }
        $(tableName).children('tbody').html(tbodyhtml);

    } catch(x) {}
}

function SetRefreshInterval(interval) {
    if (intervalId != null) {
        clearInterval(intervalId);
        intervalId = null;
    }
    if(interval > 0)
        intervalId = setInterval(RefreshData, interval*1000);
}

$(document).ready(function(){
    con = VoltDB.AddConnection('localhost', 8080, false, null, null, false, (function(connection, success){}));
    SetRefreshInterval(1);
});

// Refresh drop-down actions
$('#refresh-1').click(function(e) {
    e.preventDefault();// prevent the default anchor functionality
    SetRefreshInterval(1);
});
$('#refresh-5').click(function(e) {
    e.preventDefault();// prevent the default anchor functionality
    SetRefreshInterval(5);
});
$('#refresh-10').click(function(e) {
    e.preventDefault();// prevent the default anchor functionality
    SetRefreshInterval(10);
});
$('#refresh-pause').click(function(e) {
    e.preventDefault();// prevent the default anchor functionality
    SetRefreshInterval(-1);
});

