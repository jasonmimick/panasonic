class HSPanasonic.UsageCharts extends %CSP.Page
{

classmethod OnPage() as %Status
{
	set ns="scanpointtest1"
	//set d=##class(HSPanasonic.AdminQueries).DocumentsSubmittedPerDay(ns)
	set d=##class(HSPanasonic.AdminQueries).SubjectSearchesPerDay(ns)
	&html<
<!DOCTYPE html>
<html>
 <head>
  <link rel="stylesheet" 
		href="//cdnjs.cloudflare.com/ajax/libs/morris.js/0.5.1/morris.css">
  <script src="//ajax.googleapis.com/ajax/libs/jquery/1.9.0/jquery.min.js"></script>
  <script src="//cdnjs.cloudflare.com/ajax/libs/raphael/2.1.0/raphael-min.js"></script>
  <script src="//cdnjs.cloudflare.com/ajax/libs/morris.js/0.5.1/morris.min.js"></script>
 </head>
 <body>
  <div id="myfirstchart" style="height: 250px;"></div>
 </body>
 <script type="text/javascript">
	var raw_data = #(d)#; 
	console.dir( raw_data );
	var data = [];
	raw_data.forEach( function(d) {
		data.push( { "Date" : d.TimeProcessed.split(' ')[0],
					 "Messages" : d.NumberOfMessages });
	});
	console.dir(data);
new Morris.Line({
  // ID of the element in which to draw the chart.
  element: 'myfirstchart',
  // Chart data records -- each entry in this array corresponds to a point on
  // the chart.
  /*
  data: [
    { year: '2008', value: 20 },
    { year: '2009', value: 10 },
    { year: '2010', value: 5 },
    { year: '2011', value: 5 },
    { year: '2012', value: 20 }
  ],
  */
  data : data,
  // The name of the data record attribute that contains x-values.
  //xkey: 'year',
  xkey: 'Date',
  // A list of names of data record attributes that contain y-values.
  //ykeys: ['value'],
  ykeys: ['Messages'],
  // Labels for the ykeys -- will be displayed when you hover over the
  // chart.
  labels: ['Value']
});
 </script>
</html>
	>
	quit $$$OK
}
}
