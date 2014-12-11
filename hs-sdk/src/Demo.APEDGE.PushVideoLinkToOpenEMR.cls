Class HSPanasonic.OpenEMR.SendDocumentToOpenEMR Extends Ens.BusinessOperation
{

Parameter ADAPTER = "EnsLib.HTTP.OutboundAdapter";

Property Adapter As EnsLib.HTTP.OutboundAdapter;

Parameter INVOCATION = "Queue";

// Property OpenEMRBaseUrl As %String(MAXLEN = 1000);

/// The base url for the OpenEMR xml api, for example,
/// http://zanec.com/openemr/api/
Parameter SETTINGS As %String = "Credentials:Basic:credentialsSelector";

/// pRequest.StringValue =mpiid_"~"_p("link")_"~"_p("externalId")_"~"_p("encounter")
Method PushLink(pRequest As Ens.StringRequest, Output pResponse As Ens.StringResponse) As %Status
{
	#dim error as %Exception.AbstractException
	set sc=$$$OK
	try {
		// given an mpiid, what is the external identifier??
		set pid=$piece(pRequest.StringValue,"~",3)
		if ( pid="" ) {
			$$$TRACE("No externalId found in request, cannot handle")
			quit
		}
		
		// http://sandbox.healthshare.us:58001/addVideoLink/4?
		/*
		http://welvu.zanec.com/openemr/api/addpatientdocumentwithlink.php?token=38ddbed11e0a4c50ac9867f5c17fb4a4&categoryId=4&patientId=3&link=http://welvu.zanec.com/video.mp4
		*/
		set link=$p(pRequest.StringValue,"~",2)
		set user = ..Adapter.%CredentialsObj.Username,pass=..Adapter.%CredentialsObj.Password
		$$$TRACE("user="_user_" pass="_pass)
		$$$TRACE("Link="_link)
		set token = ##class(Demo.OpenEMR.XMLHTTPOperation).loginProviderAndGetToken(user,pass)
		//set url=..OpenEMRBaseUrl_"addpatientdocumentwithlink.php?token="_token_"&categoryId=4&patientId="_pid_"&link="_link
		//$$$TRACE("url="_url)
		//do ##class(%Net.URLParser).Parse(.url)
		
		set sc=..Adapter.Get(.httpResponse,"token,categoryId,patientId,docType,mimeType,link",token,4,pid,"mp4","video/mp4",link)
		
		//set sc=..Adapter.GetURL(url("path")_"?"_url("query"),.httpResponse)
		$$$TRACE(sc)
		set stream=httpResponse.Data
		$$$TRACE("Got response size="_stream.Size)
		do stream.Rewind()
		set pResponse=##class(Ens.StringResponse).%New()
		set xp=""
		while ( 'stream.AtEnd ) {
			set xp=xp_stream.Read()
		}
		set pResponse.StringValue=xp
	} catch (error) {
		do error.Log()
		set sc=error.AsStatus()
	}
	Quit sc
}

XData MessageMap
{
<MapItems>
	<MapItem MessageType="Ens.StringRequest"> 
		<Method>PushLink</Method>
	</MapItem>
</MapItems>
}

}

