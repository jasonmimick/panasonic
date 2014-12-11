class HSPanasonic.ScanPoint.SearchSubjectSampleOperation extends Ens.BusinessOperation
{

/// List the fields your search operation supports here
/// in a comma delimited list with the following format:
/// fieldName1:display,fieldName2:display,fieldName3:display,...
/// where display = 0 or 1 and determines if the field will display on
/// the KV-SS1000 device (this is used to send 'hidden' fields along with
/// the document submit request).
/// 
/// a request for /searchSubjectMeta will return back the value here to
/// the client
Property SearchFields As %String(MAXLEN = 5000);

/// <p>Mapping of the fields returned by an (external) search 
/// operation to how the fields are displayed on the KV-SS1100
/// device. Order is respected.
/// Format: <br/>
/// field1:display1,field2:display2,field3,field4:display4,... <br/>
/// Comma delimited string where each comma-piece has 2 parts: <br/>
/// the name of the field coming back from the search and a display
/// value. If the display value is not specified, then the field will
/// be hidden on the device but still available to send along with
/// the submit document request.
Property ResultDisplayFields As %String(MAXLEN = 5000);

Parameter SETTINGS = "SearchFields:HSPanasonic,ResultDisplayFields:HSPanasonic"; 


method OnMessage(request as HSPanasonic.ScanPoint.SearchSubjectRequest,
			     response as HSPanasonic.ScanPoint.SearchSubjectResponse) 
				As %Status
{
	set currNS = $namespace
	try {
   	  if ('request.%Extends("HSPanasonic.ScanPoint.SearchSubjectRequest") ) 
	  {
		return $$$ERROR("Request not supported.")
	  }
	  
	  set response = ##class(HSPanasonic.ScanPoint.SearchSubjectResponse).%New()
	  set response.Hostname = $system.INetInfo.LocalHostName()
	  set response.SessionID = $Get($$$JobSessionId,"XXX") 	
	  // TODO - use the search request parameters in SQL
	  new $namespace
	  set $namespace = "SAMPLES"
	  set name = "%"_request.SearchFields.GetAt("LastName")
	  set name=name_"%,%"_request.SearchFields.GetAt("FirstName")_"%"
	  set sql="select ID from Sample.Person where Name Like ?"
	  set rs=##class(%ResultSet).%New()
	  $$$THROWONERROR(sc, rs.Prepare(sql) )
	  $$$THROWONERROR(sc, rs.Execute(name) )
	  while ( rs.Next() ) {
		set person = ##class(Sample.Person).%OpenId(rs.Data("ID"))
		set o=##class(%ArrayOfDataTypes).%New()
	    do o.SetAt($piece(person.Name,",",1),"LastName")
	    do o.SetAt($piece(person.Name,",",2),"FirstName")
		do o.SetAt(person.SSN,"SSN")
		do response.Results.Insert( o )	
	  }
	  set $namespace=currNS
      set response.Status = "OK"
   } catch error {
	  set $namespace=currNS
	  set response = ##class(HSPanasonic.ScanPoint.SearchSubjectResponse).%New()
	  set response.Hostname = $system.INetInfo.LocalHostName()
	  set response.SessionID = $Get($$$JobSessionId,"XXX")	
	  set response.Status = "ERROR: " _ error.DisplayString()
   } 
   return $$$OK
}
}
