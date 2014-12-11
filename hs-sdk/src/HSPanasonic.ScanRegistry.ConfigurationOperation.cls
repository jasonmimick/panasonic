class HSPanasonic.ScanRegistry.ConfigurationOperation extends Ens.BusinessOperation
{

ClassMethod CreateResponse(ResponseCode as %String,
						   ByRef Headers = "",
						   Content As %String = "") as EnsLib.HTTP.GenericMessage [ internal ]
{
  set stream = ##class(%GlobalCharacterStream).%New()
  set stream.Attributes("ResponseCode")=ResponseCode
  if ( $data(Headers) ) {
    set header=$order(Headers(""))
    while ( header'="" ) {
      set stream.Attributes(header)=Headers(header) 
      set header=$order(Headers(header))
    }
  }
  if ( ""'=Content ) {
    do stream.Write(Content)
  }
  return ##class(EnsLib.HTTP.GenericMessage).%New(stream,,stream)

}
ClassMethod MethodNotAllowed() as EnsLib.HTTP.GenericMessage [ internal ]
{
  set stream = ##class(%GlobalCharacterStream).%New()
  //set stream.Attributes("ResponseCode")="405 Method Not Allowed"
  set stream.Attributes("ResponseCode")="405 Method Not Allowed"
  set stream.Attributes("Allow")="POST" 
  return ##class(EnsLib.HTTP.GenericMessage).%New(stream,,stream)

}
Parameter ValidateApiUrl As %String = "/validateApi";
Parameter HeaderUser As %String ="x-healthshare-username";
Parameter HeaderPassword As %String ="x-healthshare-password";
Parameter HeaderApiKey As %String ="x-healthshare-apikey";

Method HandleValidateApiRequest(request as EnsLib.HTTP.GenericMessage)
			as EnsLib.HTTP.GenericMessage
{
	set sql="select ID from HSPanasonic_ScanRegistry.Scanner where ApiKey = ?"
	set statement = ##class(%SQL.Statement).%New()
	$$$THROWONERROR(sc,statement.%Prepare(sql))
	set apikey = request.HTTPHeaders.GetAt( ..#HeaderApiKey )
	$$$TRACE("HandleValidateApiRequest apikey="_apikey)
	set result=statement.%Execute( apikey )
    set row=result.%Next(.sc)
    if ( result.%ROWCOUNT '= 1 || $$$ISERR(sc) || ('result) ) {
      return ..CreateResponse("403 Forbidden")
    }
	return ..CreateResponse("200 OK")
}

Method OnMessage(request as EnsLib.HTTP.GenericMessage,
					response as EnsLib.HTTP.GenericMessage) as %Status
{
  //set response=..CreateResponse("200 OK",,"Hello World!")
  //quit $$$OK
  try {
  set method=request.HTTPHeaders.GetAt("HttpRequest")
  set url = request.HTTPHeaders.GetAt("URL")
  $$$TRACE("method="_method_" url="_url)
  if ( (url=..#ValidateApiUrl) && (method="GET") ) {
		set response=..HandleValidateApiRequest(request)
		return $$$OK
  }
  if ( method'="POST" ) {
	set response=..MethodNotAllowed()
	return $$$OK
  }
  // read the user/pass out of headers
  set username=request.HTTPHeaders.GetAt(..#HeaderUser)
  set password=request.HTTPHeaders.GetAt(..#HeaderPassword)
  $$$TRACE("username="_username_" password="_password)
  if ( ""=username || ""=password ) {
    set response=..CreateResponse("403 Forbidden")
    return $$$OK
  }
  set sql="select ID from Ens_Config.Credentials where Username = ? and Password = ?"
  set statement=##class(%SQL.Statement).%New()
  $$$THROWONERROR(sc,statement.%Prepare(sql))
  set result = statement.%Execute(username,password)
  set row=result.%Next(.sc)
  if ( result.%ROWCOUNT '= 1 || $$$ISERR(sc) || ('result) ) {
    set response=..CreateResponse("403 Forbidden",,"%ROWCOUNT="_result.%ROWCOUNT)
    return $$$OK
  }
  set credential = ##class(Ens.Config.Credentials).%OpenId( result.%GetData(1) )
  // run sql against Scanners by Credential
  set sql="select ID from HSPanasonic_ScanRegistry.Scanner where Credential = ?"
  set statement=##class(%SQL.Statement).%New()
  $$$THROWONERROR(sc,statement.%Prepare(sql))
  set result = statement.%Execute(credential.SystemName)
  set row=result.%Next(.sc)
  if ( result.%ROWCOUNT '= 1 || $$$ISERR(sc) || ('result) ) {
    set response=..CreateResponse("404 Not Found",,"%ROWCOUNT="_result.%ROWCOUNT)
    return $$$OK
  } 
  set config=##class(HSPanasonic.ScanRegistry.Scanner).%OpenId( result.%GetData(1) )
  set stream = ##class(%GlobalCharacterStream).%New()
  if ( 'config.Active ) {
    set response=..CreateResponse("404 Not Found",,"Resource not active.")
  } else {
    set headers("x-healthshare-apikey")=config.ApiKey
    set headers("x-healthshare-endpoint")=config.EndPoint
    set response=..CreateResponse("200 OK",.headers)
  }
  return $$$OK
  } catch error {
    set msg=error.DisplayString()
    set response=..CreateResponse("500 Internal Server Error",,msg)
    return $$$OK
  } 
}

}
