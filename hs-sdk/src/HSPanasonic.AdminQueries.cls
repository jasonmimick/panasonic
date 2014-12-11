/// Provides a set of classmethods to run 
/// administrative queries such as 
/// How many /subjectSearch requests per day?
/// How many /submitDocument request per day?
/// Results are always returned as JSON arrays
/// for consumption by webby clients
class HSPanasonic.AdminQueries extends %RegisteredObject
{

/// Returns the number of subject searchs per day
/// for a given ScanPoint namespace
classmethod SubjectSearchesPerDay(ScanPointNS as %String) as %String
{
	return ..searchesPerDay(ScanPointNS,
					      "HSPanasonic.ScanPoint.SearchSubjectRequest")
}
/// Returns the number of subject searchs per day
/// for a given ScanPoint namespace
classmethod DocumentsSubmittedPerDay(ScanPointNS as %String) as %String
{
	return ..searchesPerDay(ScanPointNS,
					      "HSPanasonic.ScanPoint.SubmitDocumentRequest")
}
classmethod searchesPerDay(ScanPointNS as %String,request) 
			as %String [ internal ]
{
	try {
		new $namespace
		set $namespace = ScanPointNS
		set sql(1) = "select Count(*) as NumberOfMessages,TimeProcessed " 
    	set sql(2) = "  from Ens.MessageHeader where "
    	set sql(3) = " MessageBodyClassName = ? "
    	//set sql(3) = " MessageBodyClassName = 'HSPanasonic.ScanPoint.SearchSubjectRequest'"
		set sql(4) = " group by Day(TimeProcessed)"
		set sql = 4
		return ..SQLToJSON(.sql,request)
	} catch error {
		set po = ##class(%ZEN.proxyObject).%New()
		set po.Status = "ERROR"
		set po.Error = error.DisplayString()
	    $$$THROWONERROR(sc,##class(Ens.Util.JSON).ObjectToJSONStream(po,.stream))
		do stream.Rewind()
		set json = ""
		while ( 'stream.AtEnd ) { //'
			set json = json _ stream.Read()
		}
		return json	
	}
} 


classmethod SQLToJSON(ByRef sql as %String, params... as %String) 
			as %String [ internal ]
{
	set stmt = ##class(%SQL.Statement).%New()
	$$$THROWONERROR(sc,stmt.%Prepare(.sql))
	set result = stmt.%Execute(params...)
	// iterate over row, build proxy objects
	set array = ##class(%ListOfObjects).%New()
	set columns = stmt.%Metadata.columns
	for i=1:1:columns.Count() {
		set cols(i)=columns.GetAt(i).colName
	}
	set cols = i
	while ( result.%Next() ) {
		set po = ##class(%ZEN.proxyObject).%New()
		for i=1:1:cols {
			break
			set colName = cols(i)
			set $property(po, colName ) = result.%Get( colName )
		}
		//zw po
		do array.Insert( po )
	}
	$$$THROWONERROR(sc,##class(Ens.Util.JSON).ObjectToJSONStream(array,.stream))
	do stream.Rewind()
	set json = ""
	while ( 'stream.AtEnd ) { //'
		set json = json _ stream.Read()
	}
	return json
}
}
