class HSPanasonic.ScanPoint.EndpointOperation extends Ens.BusinessOperation
{

Property ScanRegistryURL As %String(MAXLEN=10000) [ InitialExpression = "https://localhost:20187"];
/// e.g. MySSLItem|mypassword
Property SSLConfig As %String;
Property SearchSubjectTarget As Ens.DataType.ConfigName;
Property SubmitDocumentTarget As Ens.DataType.ConfigName;

/// A comma-delmited list of valid document types
/// or '##class(SomeClass).SomeClassMethod()' which
/// returns a comma-delimited list of valid document
/// types.
Property DocumentTypes As %String;

Parameter SETTINGS = "DocumentTypes:HSPanasonic,ScanRegistryURL:HSPanasonic,SSLConfig:HSPanasonic:sslConfigSelector,SearchSubjectTarget:HSPanasonic:selector?multiSelect=0&context={Ens.ContextSearch/ProductionItems?targets=1&productionName=@productionId},SubmitDocumentTarget:HSPanasonic:selector?multiSelect=0&context={Ens.ContextSearch/ProductionItems?targets=1&productionName=@productionId}";

ClassMethod CreateResponse(ResponseCode as %String,
						   ByRef Headers = "",
						   Content As %String = "") as EnsLib.HTTP.GenericMessage [ internal ]
{
  set stream = ##class(%GlobalCharacterStream).%New()
  set stream.Attributes("ResponseCode")=ResponseCode
  if ( $data(Headers) ) {
    set header=$order(Headers(""))
    while ( header'="" ) {   //'
      set stream.Attributes(header)=Headers(header) 
      set header=$order(Headers(header))
    }
  }
  if ( ""'=Content ) {  //'
    do stream.Write(Content)
  }
  return ##class(EnsLib.HTTP.GenericMessage).%New(stream,,stream)

}
Parameter HeaderApiKey As %String ="x-healthshare-apikey";

Parameter ValidateApiUrl As %String = "/validateApi";

ClassMethod Test() 
{
	set req=##class(EnsLib.HTTP.GenericMessage).%OpenId(1362)
	set op=##class(HSPanasonic.ScanPoint.EndpointOperation).%New("FOO")
	set op.ScanRegistryURL="https://127.0.0.1:20187"
	set op.SSLConfig = "%SuperServer"
	set response=op.HandleValidateApiRequest(req)
	zw response
}
Method HandleValidateApiRequest(request as EnsLib.HTTP.GenericMessage)
			as EnsLib.HTTP.GenericMessage
{
	// create another HTTP request and send to 
	// ScanRegistryURL to validate the api-key
	set validateRequest = ##class(%Net.HttpRequest).%New()
	do validateRequest.SetHeader("HttpRequest","GET")
	do validateRequest.SetHeader("URL",..#ValidateApiUrl)
	set apikey=request.HTTPHeaders.GetAt(..#HeaderApiKey)
	do validateRequest.SetHeader(..#HeaderApiKey,apikey)
	do ##class(%Net.URLParser).Parse(..ScanRegistryURL,.sruParts)
    break	
	set validateRequest.Server=sruParts("host") 	
    do validateRequest.SetHeader("host",sruParts("host"))  //_":"_sruParts("port"))
	set validateRequest.Port = sruParts("port")
	if sruParts("scheme")="https" {
		set validateRequest.SSLConfiguration = "FOO" //..SSLConfig
		set validateRequest.SSLCheckServerIdentity=0
		set validateRequest.Https=1
	}
	zw validateRequest
	$$$THROWONERROR(sc,validateRequest.Get(..#ValidateApiUrl,2))
	//$$$THROWONERROR(sc,vop.OnMessage(validateRequest,.validateResponse))
	//$$$TRACE("validateResponse.HTTPHeaders.GetAt(""StatusLine"")="_validateResponse.HTTPHeaders.GetAt("StatusLine"))
	return validateRequest.HttpResponse
}

Method OnMessage(request as EnsLib.HTTP.GenericMessage,
				 response as EnsLib.HTTP.GenericMessage) as %Status
{
  try {
    set method=request.HTTPHeaders.GetAt("HttpRequest")
	set url = request.HTTPHeaders.GetAt("URL")
	set validateResponse=..HandleValidateApiRequest(request)
	//if ( validateResponse.HTTPHeaders.GetAt("StatusLine")'["200 OK" )   //'
	if ( validateResponse.StatusCode'="200" )   //'
	{
	  set response=validateResponse
	  return $$$OK
    }
	// else ok
	// todo - log IO here!
	$$$TRACE("validateResponse was ok")
	// otherwise, must be a post!
    if ( method'="POST" ) {  //'
      set response=..CreateResponse("405 Method Not Allowed")
	  return $$$OK
    }

	set validUrls = $listbuild("/subjectSearch","/meta/subjectSearch","/submitDocument","/meta/docTypes")
	if ( '$listfind(validUrls,url) ) {  //'
		set response=..CreateResponse("404 Not Found")
	} 
	if ( url = "/subjectSearch" ) {
		set response = ..HandleSearchSubject(request)
	}
	if ( url = "/meta/subjectSearch" ) {
		set response = ..HandleMetaSearchSubject(request)
	}
	if ( url = "/submitDocument" ) {
		set response = ..HandleSubmitDocument(request)
	}

    return $$$OK
  } catch error {
      set msg=error.DisplayString()
      set response=..CreateResponse("500 Internal Server Error",,msg)
      return $$$OK
  } 
}

classmethod jsonFromObject(object As %RegisteredObject) As %String
{
	set stream=##class(%Stream.TmpCharacter).%New()
	set sc=##class(%ZEN.Auxiliary.jsonProvider).%WriteJSONStreamFromObject(stream,.object)
	if ( $$$ISERR( sc ) ) 
	{
		throw ##class(%Exception.StatusException).CreateFromStatus(sc)	
	}
	do stream.Rewind()
	set json=""
	while ( 'stream.AtEnd ) { set json=json_stream.Read() }  //'
	return json
}

method proxyFromHTTPRequestBody(request as EnsLib.HTTP.GenericMessage)
		as %ZEN.proxyObject  [ internal ]
{
	set j=""
	do request.Stream.Rewind()
	while ( 'request.Stream.AtEnd ) { set j=j_request.Stream.Read() }  //'
	$$$THROWONERROR(sc,##class(%ZEN.Auxiliary.jsonProvider).%ConvertJSONToObject(j,,.obj))
	return obj
}
method HandleSearchSubject(request as EnsLib.HTTP.GenericMessage)
		as EnsLib.HTTP.GenericMessage  [ internal ]
{
	set ssr = ##class(HSPanasonic.ScanPoint.SearchSubjectRequest).%New()
	set obj = ..proxyFromHTTPRequestBody( request )	
	do obj.%CopyToArray(.aobj)	
	set key=$order( aobj("") )
	while ( key '= "" ) {  //'
		set value = aobj(key)
		do ssr.SearchFields.SetAt( value, key )
		set key=$order( aobj(key) )
	}
	$$$THROWONERROR(sc,..SendRequestSync(..SearchSubjectTarget, ssr, .ssresponse ) )
	return ..handleResponse( ssresponse )
}

method AddMetaDocTypes(ByRef settings)
		as EnsLib.HTTP.GenericMessage  [ internal ]
{
	set dt = ..DocumentTypes
	$$$TRACE("dt="_dt)
	set settings("x-healthshare-docTypes")=""
	if ( $extract(dt,1,$length("##class(")) '= "##class(" ) {   //'
		set settings("x-healthshare-docTypes")=dt
	} else {
		set className = $piece($piece(dt,"##class(",2),")",1)
		set method = $piece($piece(dt,".",2),"(",1)
		set dtt = $method(className,method)
		set settings("x-healthshare-docTypes")=dtt
	}
	//return ..CreateResponse("200 OK",.settings,"")
}
method HandleMetaSearchSubject(request as EnsLib.HTTP.GenericMessage)
		as EnsLib.HTTP.GenericMessage  [ internal ]
{
	set searchOp = ..SearchSubjectTarget 
	set stmt = ##class(%SQL.Statement).%New()
	set sc=stmt.%Prepare( "select ID from Ens_Config.Item where Name = ? ")
	set result = stmt.%Execute( ..SearchSubjectTarget )
	set i=result.%Next(.sc)
	set searchSubjectItem= ##class(Ens.Config.Item).%OpenId( result.%Get("ID") )
	set gotFields = searchSubjectItem.GetSetting("SearchFields",.searchFields)
	if ( 'gotFields ) { //'
		throw ##class(%Exception.General).%New("NoSearchFields",,"No SearchFields defined for operation")
	}
	set gotResultsFields = searchSubjectItem.GetSetting("ResultDisplayFields",.resultDisplayFields)

	/*
	set clsDef = ##class(%Dictionary.ClassDefinition).%OpenId(searchSubjectItem.ClassName)
	set fields = "?"
	for i=1:1:clsDef.Parameters.Count() {
		set param = clsDef.Parameters.GetAt(i)
		if ( param.Name = "SearchFields" ) {
			set fields = param.Default
		}
	}
	*/

	set settings("x-healthshare-searchfields")=searchFields
	set settings("x-healthshare-resultdisplayfields")=resultDisplayFields
	do ..AddMetaDocTypes(.settings)
	return ..CreateResponse("200 OK",.settings,"")
}


method handleResponse(object as %RegisteredObject) 
		as EnsLib.HTTP.GenericMessage [ internal ]
{

	set json=..jsonFromObject( object )
	set status = "200 OK" 
	if ( object.%Extends("%ListOfObjects") )
	{
		for i=1:1:object.Count() {
			/*
			set oo = object.GetAt(i)
			
			if (object.GetAt(i).Status '= "OK" )  //'
			{
				set status="500 Internal Server Error"
			}
			*/
		}
	} else {
		if ( object.Status '= "OK" ) {  //'
			set status="500 Internal Server Error"
		}
	}
	set headers("content-type")="application/json"
	set headers("content-length")=$length(json)
	return ..CreateResponse(status,.headers,json)
}
method HandleSubmitDocument(request as EnsLib.HTTP.GenericMessage)
		as EnsLib.HTTP.GenericMessage
{
	set sdr = ##class(HSPanasonic.ScanPoint.SubmitDocumentRequest).CreateFromJSONStream(request.Stream)
	set responses = ##class(%ListOfObjects).%New() 
	for i=1:1:$length(..SubmitDocumentTarget,",") {
		set target = $piece(..SubmitDocumentTarget,",",i)
		$$$THROWONERROR(sc,..SendRequestSync(target, sdr, .ssresponse ) )
		$$$TRACE("Sent to " _ target _ " response = " _ ssresponse)
		if ( $isobject(ssresponse) ) {
			do responses.Insert(ssresponse)
		}
	}
	//return ..handleResponse( ssresponse )
	return ..handleResponse( responses )
}

}
