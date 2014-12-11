class HSPanasonic.SampleDocViewer.Viewer extends %CSP.Page
{

ClassMethod OnPage() As %Status
{
	&html<
	<!DOCTYPE html>
	<html>
	<head>
	</head>
	<body>
	>
	set sql="select * from HSPanasonic_ScanPoint.SubmitDocumentRequest"
	set stmt=##class(%SQL.Statement).%New()
	set sc=stmt.%Prepare(sql)
	set result = stmt.%Execute()
	&html<

	<h2> Scanned Documents Sample Viewer </h2>

	<table>
		<tr>
			<th>Subject</th>
			<th>Document Name</th>
			<th>Type</th>
			<th>Uploaded By</th>
		</tr>
	>
	while ( result.%Next(.sc) ) {
		quit:$$$ISERR(sc)
		set subject=result.%Get("Subject")
	    /*
		set key=subject.Next(""),s=""
		while ( key'="" ) {
			set s=s_key_"="_subject.GetAt(key)_"|"
			set key=subject.Next(key)
		}
		*/	
		&html<
		<tr>
			<td>#(subject)#
			</td>
			<td>#(result.%Get("Name"))#</td>
			<td>#(result.%Get("Type"))#</td>
			<td>#(result.%Get("User"))#</td>
		</tr>
		>	
	}	
	&html<
	</table>
	</body>
	
	</html>

	>
	quit $$$OK
}
}

