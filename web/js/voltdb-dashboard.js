/*
 This file is part of VoltDB.
 Copyright (C) 2008-2013 VoltDB Inc.

 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU Affero General Public License as
 published by the Free Software Foundation, either version 3 of the
 License, or (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU Affero General Public License for more details.

 You should have received a copy of the GNU Affero General Public License
 along with VoltDB.  If not, see <http://www.gnu.org/licenses/>.
*/

var con;
var intervalId;

function formatDecimal2(n) {
    return (Math.round(parseFloat(n) * 100) / 100).toFixed(2);
}

function DrawTable(response, tableName) {
    try {
        var tables = response.results;
        var hmt = tables[0];
        var colcount = hmt.schema.length;
        
        // the first time, initialize the table head
        if ($(tableName+' thead tr').length == 0) {
            var theadhtml = '<tr>';
            for (var i=0; i<colcount; i++) {
                theadhtml += '<th>' + hmt.schema[i].name + '</th>';
            }
            $(tableName).append('<thead></thead>');
            $(tableName).append('<tbody></tbody>');
            $(tableName).children('thead').html(theadhtml);
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

