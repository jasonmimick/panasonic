Class HSPanasonic.OpenEMR.SendDocumentToOpenEMR Extends Ens.BusinessOperation
{

Parameter ADAPTER = "EnsLib.HTTP.OutboundAdapter";

Property Adapter As EnsLib.HTTP.OutboundAdapter;

Parameter INVOCATION = "Queue";

// Property OpenEMRBaseUrl As %String(MAXLEN = 1000);

/// The base url for the OpenEMR xml api, for example,
/// http://zanec.com/openemr/api/
Parameter SETTINGS As %String = "Credentials:Basic:credentialsSelector";

ClassMethod Test()
{
	try {
	set request = ##class(HSPanasonic.ScanPoint.SubmitDocumentRequest).%New()
	//do request.Subject.SetAt("John","FirstName")
	//do request.Subject.SetAt("Smith","LastName")
	do request.Subject.SetAt(1,"pid")
	set request.Type = "html"	
	set doc = ##class(%Stream.GlobalBinary).%New()
	do doc.WriteLine("<html><body>")
	for i=1:1:10 {
		do doc.WriteLine("<li>Hello Dude #" _ i _ "</li>")
	}
	do doc.WriteLine("</body></html>")
	do doc.Rewind()
	set request.Body = ##class(%Stream.GlobalBinary).%New()
	while ( ' doc.AtEnd ) {
		do request.Body.Write( $system.Encryption.Base64Encode(doc.Read()))
	}
	set request.Size = request.Body.Size
	set request.Name = "TestDocument" _ $increment(^hspansonic.openemr.test)
	
	set operation = ..%New("Testing")
	set operation.Adapter.HTTPServer = "172.16.224.180"
	set operation.Adapter.HTTPPort = 80
	set operation.Adapter.URL = "/openemr/api"
	$$$THROWONERROR(sc, ##class(Ens.Config.Credentials).SetCredential("OpenEMRTest","healthshare","password",1) )	
	set cred = ##class(Ens.Config.Credentials).%OpenId("OpenEMRTest")
	set operation.Adapter.%CredentialsObj = cred
	set sc=operation.AddDocument(request,.response)
	do $system.OBJ.DisplayError( sc )

	} catch (error) {

		write error.DisplayString()

	}

}
/// pRequest.StringValue =mpiid_"~"_p("link")_"~"_p("externalId")_"~"_p("encounter")
Method AddDocument(request As HSPanasonic.ScanPoint.SubmitDocumentRequest
			, Output response As HSPanasonic.ScanPoint.SubmitDocumentResponse) As %Status
{
	#dim error as %Exception.AbstractException
	set sc=$$$OK
	set response = ##class(HSPanasonic.ScanPoint.SubmitDocumentResponse).%New()
	set response.Hostname = $system.INetInfo.LocalHostName()
	set response.SessionID = $Get($$$JobSessionId,"XXX") 	
	set response.Status = "OK"
	try {
		
		set ^EnsLib.HTTP.Test=0
		set user = ..Adapter.%CredentialsObj.Username,pass=..Adapter.%CredentialsObj.Password
		set ..Adapter.%CredentialsObj=""
		$$$TRACE("user="_user_" pass="_pass)
		//$$$TRACE("Link="_link)
	    set ip = ..Adapter.HTTPServer
		set token = ##class(HSPanasonic.OpenEMR.XMLHTTPOperation).loginProviderAndGetToken(user,pass,ip)
		$$$TRACE("token=" _ token )
	    if ( $length( token ) < 10 ) {	// not a valid token
			throw ##class(%Exception.General).%New("Invalid token received from OpenEMR token="_token)
		}
		/*
		// First use the info in the request.Subject to search OpenEMR for
		// a patient ID to link this document against.
		set lastname = request.Subject.GetAt("LastName")
		set firstname = request.Subject.GetAt("FirstName")
		set url = ..Adapter.URL_"/searchpatient.php"
		$$$TRACE("url="_url)
		set formValues("token")=token
		set formValues("lastname")=lastname
		set formValues("firstname")=firstname
		set formVars = "token,lastname,firstname"
		set sc=..Adapter.PostURL(url,.searchResponse,formVars,token,lastname,firstname)
	    // parse out the response
		set sr=""
		do searchResponse.Data.Rewind()
		while ( 'searchResponse.Data.AtEnd ) {
			set sr = sr _ searchResponse.Data.Read()
		}		
		$$$TRACE("sr=" _ sr )
		set status = $piece($piece(sr,"</status>",1),"<status>",2)
		$$$TRACE("search status = " _ status)
		if ( status '= "0" ) {
			$$$TRACE("OpenEMR search result = " _ sr)
			throw ##class(%Exception.General).%New("OpenEMR search returned an error")
		}
		set patientId = ..parseSearchResponse( sr ) 
		*/
		set patientId = request.Subject.GetAt("pid")
		$$$TRACE("Sending document with patientId = " _ patientId)
		if ( patientId = 0 ) {
			throw ##class(%Exception.GeneralException).%New("Unable to find patient in OpenEMR")
		}
		kill formVars,formValues
		//set url = ..OpenEMRBaseUrl_"addpatientdocument.php?"
		set url = ..Adapter.URL _ "/addpatientdocument.php"
		// docDate,listId,categoryId,data,docType,mimeType
		set formVars = "patientId,docName,data,docType,mimeType,listId,categoryId,token"
		// Base64Encode the request.Body
		set b64=##class(%Stream.GlobalBinary).%New()
		do request.Body.Rewind()
		/*
		while ( ' request.Body.AtEnd ) {
			do b64.Write( $system.Encryption.Base64Encode( request.Body.Read() ) )
		}
		do b64.Rewind()
		do request.Body.Rewind()
		set streamToPost = b64
		if ( b64.Read(100) = request.Body.Read(100) ) {	// it's already b64!
			set streamToPost = request.Body
		}
		*/
		//set sc=..Adapter.PostURL(url,.addDocumentResponse,formVars,patientId,request.Name
		//						  ,streamToPost,request.Type,"application/"_request.Type,1,4,token)
		set sc=..Adapter.PostURL(url,.addDocumentResponse,formVars,patientId,request.Name
								  ,request.Body,request.Type,"application/"_request.Type,1,4,token)
	    // parse out the response
		set sr=""
		do addDocumentResponse.Data.Rewind()
		while ( 'addDocumentResponse.Data.AtEnd ) {
			set sr = sr _ addDocumentResponse.Data.Read()
		}		
		set status = $piece($piece(sr,"</status>",1),"<status>",2)
		$$$TRACE("add document status = " _ status)
	} catch (error) {
		do error.Log()
		set sc=error.AsStatus()
		set response = ##class(HSPanasonic.ScanPoint.SubmitDocumentResponse).%New()
	    set response.Hostname = $system.INetInfo.LocalHostName()
	    set response.SessionID = $Get($$$JobSessionId,"XXX")	
	    set response.Status = "ERROR: " _ error.DisplayString()
    }
	Quit sc
}

ClassMethod parseSearchResponse(xml as %String) as %String [ internal ]
{
	$$$THROWONERROR(sc, ##class(%XML.TextReader).ParseString(xml,.textReader) )
	while ( textReader.Read() ) {
		if ( textReader.NodeType = "element" ) {
			if ( textReader.Name = "pid" ) {
				do textReader.Read()
				set pids = $listbuild( textReader.Value )
			}
		}
	}
	if ( '$listvalid(pids) ) {
		$$$TRACE("No results found!")
		return 0
	}
	if ( $listlength(pids) > 1 ) {
		$$$TRACE("Found multiple results for patient search!")
	}

	return $list(pids,1)
}

XData MessageMap
{
<MapItems>
	<MapItem MessageType="HSPanasonic.ScanPoint.SubmitDocumentRequest"> 
		<Method>AddDocument</Method>
	</MapItem>
</MapItems>
}

}

