<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
         pageEncoding="ISO-8859-1" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.3/jquery.min.js"></script>
    <script src="http://maxcdn.bootstrapcdn.com/bootstrap/3.3.5/js/bootstrap.min.js"></script>
    <link rel="stylesheet" href="http://maxcdn.bootstrapcdn.com/bootstrap/3.3.5/css/bootstrap.min.css" type="text/css">
    <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
    <title>Database operations</title>
    <script>


        function getQuery() {
            var tab = [];
            var operationClass = $('.operations');

            for(i=0; i<operationClass.length; i++){
                if(!(operationClass[i].value=="" || $('.times')[i].value==""))
                    tab.push({"command" : operationClass[i].value, "times" : $('.times')[i].value})
            }

            return tab;
        }

        function sendCommand() {
            $('#commands').html("");
            $('#drawTable').html("");

                var insert = "<table class='table'>"
              var queryToSend=[];
                var counter=0;

                getQuery().forEach(function x(query){
                    queryToSend.push({"type": "",
                            "tableName": "",
                            "values": [],
                            "times": parseInt(query.times),
                            "command" : query.command
                    });


                    for(i=0; i<parseInt(query.times); i++){
                        insert += "<tr><td id='command" + counter + "'>" + query.command + "</td></tr>";
                        counter +=1;
                    }

                });
            insert += "</table>"
            $('#commands').html(insert);
            startChangeColor();

            $.ajax({
                type: "POST",
                contentType : 'application/json; charset=utf-8',
                url: "/operations/",
                headers: {
                    'Accept': 'application/json',
                    'Content-Type': 'application/json'
                },
                dataType: 'text',
                data: JSON.stringify(queryToSend),
                success: function (response) {
                    console.log(response);
                },
                error: function (response) {
                    console.log(response);
                }
            });
        }

        function startChangeColor(){
        var interval = setInterval(function changeColor(){
            $.ajax({
                type: "GET",
                url: "/operations/check/",
                dataType: 'json',
                headers: {
                    'Accept': 'application/json',
                    'Content-Type': 'application/json'
                },
                success: function (response) {
                    console.log(response);
                    $('#drawTable').html("");
                    response.forEach(function f(resp){
                            if(resp.split(" ::: ")[2].indexOf("error")>=0 || resp.split(" ::: ")[2].indexOf("blad")>=0)
                                $("#command" + resp.split(" ::: ")[0]).html(resp.split(" ::: ")[1].substring(1) + " " + resp.split(" ::: ")[2]).css('color', 'red');
                            else if(resp.split(" ::: ")[2].indexOf("null")>=0)
                                $("#command" + resp.split(" ::: ")[0]).html(resp.split(" ::: ")[1].substring(1) + " " + resp.split(" ::: ")[2]).css('color', 'red');
                            else if(resp.split(" ::: ")[1].toLocaleLowerCase().indexOf("select")>=0) {
                                $("#command" + resp.split(" ::: ")[0]).html(resp.split(" ::: ")[1].substring(1)).css('color', 'green');
                                var place = resp.split(" ::: ")[1].indexOf("from ");
                                var name = resp.split(" ::: ")[1].substring(place +5);

                                $('#drawTable').append(wrapTable(drawTable(resp.split(" ::: ")[2]),name));
                            }
                            else
                                $("#command" + resp.split(" ::: ")[0]).html(resp.split(" ::: ")[1].substring(1)).css('color', 'green');

                    });

                    var hasStyle=true;
                    for(i=0; i<document.getElementsByTagName('td').length; i++){
                        if(!document.getElementsByTagName('td')[i].hasAttribute('style')){
                            hasStyle=false;
                            break;
                        }
                    }
                    if(hasStyle==true)
                        clearInterval(interval);
                },
                error: function (response) {
                    console.log(response);
                }
            });
        }, 1000);}

        function drawTable(response){

            init = response.indexOf('[');
            fin = response.indexOf(']')

            var columnName = response.substr(init+1 , fin-init-1).split(",");

            response = response.substr(fin+1);

            init = response.indexOf('[');
            fin = response.indexOf(']');

            rows = response.substr(init+1 , fin-init-1).slice(1,-1).replace(/['"]+/g, '').replace(/ /g,'').split("},{");


            var table ="<table class='table'>";
            columnName.forEach(function x(column){
                table += "<td>" + column.slice(1, -1) + "</td>"
            })

            rows.forEach(function x(row){
                table += "<tr>";
                row.split(",").forEach(function y(cell){
                    table +="<td>" + cell + "</td>";
                });
                table += "</tr>";
            })
            table +="</table>";

            return table;


        }

        function wrapTable(table, name){
            console.log(name);
            var wrap = '<div class="panel panel-primary">' +
                    '<div class="panel-heading" style="text-align: center">' + name +'</div><br>' + table + "<div>";
            return wrap;
        }

        function isNumber(n) {
            return !isNaN(parseFloat(n)) && isFinite(n);
        }

        function getFirstNumber(n){
            var counter = 0;
            var result="";
            while(isNumber(n.charAt(counter))){
                result += n.charAt(counter);
                counter++;
            }
            return result;
        }

        function insertFields(){
            var fields = "<div class='form-inline'>" +
                    "<input type='text' class='operations form-control' name='operations'  placeholder='command'> " +
                    "<input type='number' class='times form-control' name='times' placeholder='times'> " +
                    "<button type='buttonModal' class='btn btn-default' onclick=$(this).parent('div').remove()>remove</button>" +
                    "</div>";
            $("#insertCommands").append(fields);
        }

    </script>


</head>
<body>




<div class="panel panel-primary">
    <div class="panel-heading" style="text-align: center">Database operations</div><br>
    <div id="insertCommands" style="text-align: center">
        <div class="form-inline">
            <input type="text" class="operations form-control" name="operations" placeholder="command">
            <input type="number" class="times form-control" name="times" placeholder="times">
            <button type="buttonModal" class="btn btn-default" onclick="insertFields()">add</button>
            <button type="buttonModal" class="btn btn-default" onclick="sendCommand()">send</button>
        </div>

    </div><br>
    <div id="commands" style="text-align: center">
    </div>
</div>

<div id="drawTable"></div>




</body>
</html>