class HSPanasonic.ScanPoint.SubmitDocumentFileOperation 
	extends Ens.BusinessOperation
{

Parameter ADAPTER = "EnsLib.File.OutboundAdapter";
Property OutputDirectory As %String(MAXLEN=2000,MINLEN=1);
Parameter SETTINGS = "OutputDirectory:Basic";

Method OnMessage(request as HSPanasonic.ScanPoint.SubmitDocumentRequest,
			output response as HSPanasonic.ScanPoint.SubmitDocumentResponse)
		As %Status
{
	try {
		if ( ..OutputDirectory = "" ) {
			set path = $system.Util.ManagerDirectory() _ "../HSPanasonic/"
			set ..OutputDirectory = ##class(%File).GetDirectory(path) 
			$$$TRACE("OutputDirectory was empty defaulting to " _ ..OutputDirectory)
		}
		if ( '##class(%File).DirectoryExists(..OutputDirectory) ) { //'
			$$$TRACE("OutputDirectory = '"_..OutputDirectory_"' does not exists, attempting to create")	
			if ( '##class(%File).CreateDirectoryChain(..OutputDirectory) ) { //'
				return $$$ERROR("Unable to create " _ ..OutputDirectory)
			}
		}
		if ( ..OutputDirectory '= ..Adapter.FilePath ) {  //'
			$$$TRACE("Adapter.FilePath = '"_..Adapter.FilePath_"' did not match OutputDirectory")
			set ..Adapter.FilePath = ..OutputDirectory
		}
		set nn=$zstrip(request.Name,"*W")_"."_request.Type
		set fn=##class(%File).NormalizeFilename(nn,..Adapter.FilePath)
		$$$TRACE("Filename="_fn)
		// NEED TO Un b64 encode the request.Body here!
		set binStream = ##class(%Stream.GlobalBinary).%New()
		do request.Body.Rewind()
		while ( 'request.Body.AtEnd ) {
			do binStream.Write( $system.Encryption.Base64Decode( request.Body.Read() ) )
		}
		do binStream.Rewind()
		$$$TRACE("binStream.Size="_binStream.Size)
		$$$THROWONERROR(sc, ..Adapter.PutStream(nn,binStream) ) 
   	    set response = ##class(HSPanasonic.ScanPoint.SubmitDocumentResponse).%New()
	    set response.Hostname = $system.INetInfo.LocalHostName()
	    set response.SessionID = $Get($$$JobSessionId,"XXX")	
	    set response.Status = "OK"
	} catch error {
	  set response = ##class(HSPanasonic.ScanPoint.SubmitDocumentResponse).%New()
	  set response.Hostname = $system.INetInfo.LocalHostName()
	  set response.SessionID = $Get($$$JobSessionId,"XXX")	
	  set response.Status = "ERROR: " _ error.DisplayString()
	}
	return $$$OK
}

}
