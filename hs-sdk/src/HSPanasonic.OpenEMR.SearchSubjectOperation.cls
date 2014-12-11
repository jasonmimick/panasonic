class HSPanasonic.OpenEMR.SearchSubjectOperation extends Ens.BusinessOperation
{

Parameter ADAPTER = "EnsLib.HTTP.OutboundAdapter";

Property Adapter As EnsLib.HTTP.OutboundAdapter;

Parameter INVOCATION = "Queue";

ClassMethod Test()
{
	try {
	set request = ##class(HSPanasonic.ScanPoint.SearchSubjectRequest).%New()
	do request.SearchFields.SetAt("John","FirstName")
	do request.SearchFields.SetAt("Smith","LastName")
	
	set operation = ..%New("Testing")
	set operation.Adapter.HTTPServer = "172.16.224.177"
	set operation.Adapter.HTTPPort = 80
	set operation.Adapter.URL = "/openemr/api"
	set operation.SearchFields = "LastName:1,FirstName:1,MRN:1,SecretId:0"
	$$$THROWONERROR(sc,##class(Ens.Config.Credentials).SetCredential("OpenEMRTest","healthshare","password",1) )	
	set cred = ##class(Ens.Config.Credentials).%OpenId("OpenEMRTest")
	set operation.Adapter.%CredentialsObj = cred
	$$$THROWONERROR(sc,operation.OnMessage(request,.response))
	for i=1:1:response.Results.Count() {
		set item = response.Results.GetAt(i)
		zw item
	}

	} catch (error) {
		write error.DisplayString()
	}

}

// Parameter SearchFields = "LastName,FirstName,SSN";

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
	try {
   	  if ('request.%Extends("HSPanasonic.ScanPoint.SearchSubjectRequest") ) //'
	  {
		return $$$ERROR("Request not supported.")
	  }
	  set response = ##class(HSPanasonic.ScanPoint.SearchSubjectResponse).%New()
	  set response.Hostname = $system.INetInfo.LocalHostName()
	  set response.SessionID = $Get($$$JobSessionId,"XXX") 	
	  set response.Status = "OK"
	  set ip = ..Adapter.HTTPServer
      set user = ..Adapter.%CredentialsObj.Username
	  set pass=..Adapter.%CredentialsObj.Password
	  set ..Adapter.%CredentialsObj=""
      set token = ##class(HSPanasonic.OpenEMR.XMLHTTPOperation).loginProviderAndGetToken(user,pass,ip)
	  $$$TRACE("token=" _ token )
      if ( $length( token ) < 10 ) {	// not a valid token
		throw ##class(%Exception.General).%New("Invalid token received from OpenEMR token="_token)
	  }

      // First use the info in the request.Subject to search OpenEMR for
	  // a patient ID to link this document against.
	  set searchFields = $listfromstring(..SearchFields)
	  for i=1:1:$listlength(searchFields) {
		set field = $list(searchFields,i)
		set field = $piece(field,":",1)
		set lowerField = $zconvert(field,"L")
		set sf(lowerField)=request.SearchFields.GetAt(field)
		set $list(formVarsList,i)=lowerField
	  }
	  //set lname = request.SearchFields.GetAt("LastName")
	  //set fname = request.SearchFields.GetAt("FirstName")
	  //set ss = request.SearchFields.GetAt("SSN")
	  set url = ..Adapter.URL
	  // strip off any trailing forward-slash
	  set:$extract(url,$length(url))="/" url=$extract(url,1,$length(url)-1)
	  set url = url _ "/searchpatient.php"
	  $$$TRACE("url="_url)
	  //set formVars = "token,lname,fname,ss"
	  set formVars = "token,"_$listtostring(formVarsList)
	  set sf("token")=token
	  //set sc=..Adapter.PostURL(url,.searchResponse,formVars,token,lname,fname,ss)
	  //set sc=..Adapter.PostURL(url,.searchResponse,formVars,.sf)
	  set sc=..Adapter.SendFormDataArray(.searchResponse,"POST",,formVars,.sf,url)
	   // parse out the response
	  set sr=""
	  do searchResponse.Data.Rewind()
	  while ( 'searchResponse.Data.AtEnd ) {  //'
		set sr = sr _ searchResponse.Data.Read()
	  }		
	  $$$TRACE("sr=" _ sr )
	  set status = $piece($piece(sr,"</status>",1),"<status>",2)
	  $$$TRACE("search status = " _ status)
	  if ( status '= "0" ) {  //'
		$$$TRACE("OpenEMR search result = " _ sr)
		throw ##class(%Exception.General).%New("OpenEMR search returned an error")
	  }
  	  $$$THROWONERROR(sc, ##class(%XML.TextReader).ParseString(sr,.textReader) )
	  while ( textReader.Read() ) {
		if ( textReader.NodeType = "element" ) {
			if ( textReader.Name = "Patient" ) {
				set readingPatient = 1
		        set o=##class(%ArrayOfDataTypes).%New()
				while ( readingPatient ) {
					do textReader.Read()
					if ( textReader.NodeType = "endelement" ) {
						if ( textReader.Name = "Patient" ) {
							set readingPatient = 0 
							continue
						}
					}
					if ( textReader.NodeType = "element" ) {
					  set key = textReader.Name
					  // we got something we care about,
					  // advance and get it's value'
					  do textReader.Read()
					  set value = textReader.Value
		    		  do o.SetAt(value,key)
					}
				}
			}
			if ( $isobject($get(o)) ) {
				do response.Results.Insert(o)
				kill o
			}
		}
	}
   	return $$$OK

   } catch error {
	  set response = ##class(HSPanasonic.ScanPoint.SearchSubjectResponse).%New()
	  set response.Hostname = $system.INetInfo.LocalHostName()
	  set response.SessionID = $Get($$$JobSessionId,"XXX")	
	  set response.Status = "ERROR: " _ error.DisplayString()
	  return error.AsStatus()
   } 
}
}
