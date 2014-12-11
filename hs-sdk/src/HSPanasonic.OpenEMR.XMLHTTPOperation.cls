/// Given a url, fetch the xml document at that url and return an EnsLib.EDI.XML.Document
/// bound to some vdoc XML schema - like the inbound File Service but "on demand"
Class HSPanasonic.OpenEMR.XMLHTTPOperation Extends Ens.BusinessOperation
{

Parameter ADAPTER = "EnsLib.HTTP.OutboundAdapter";

Property Adapter As EnsLib.HTTP.OutboundAdapter;

Parameter INVOCATION = "Queue";

/// Category to apply to incoming XML document root node names to produce a complete DocType specification.<p/>
/// Combines with the document type name to produce a DocType assignment.
/// This setting may also contain multiple comma-separated type names followed by = and then a
/// DocTypeCategory or full DocType value to apply to documents declared as that type.<br>
/// A trailing asterisk (*) at the end of a given partial type Name will match any types with that beginning part.<p/>
/// An example: DocSchemaCategory='Qv3NL,QURX_IN990001NL=QURX_IN990001NL'; <br>
/// Note that a DocType assignment is be needed for Transformation, Validation or SearchTableClass indexing.
Property DocSchemaCategory As %String(MAXLEN = 1000);

Parameter SETTINGS = "DocSchemaCategory:Basic:selector?context={Ens.ContextSearch/SchemaCategories?host=EnsLib.EDI.XML.Service.Standard}";

ClassMethod fetchToken(ip as %String) As %String
{
	//set loginURL="http://166.78.61.206/welvuoemr/openemr/api/login.php?username=admin&password=poiu7890"
	set loginURL="http://"_ip_"/openemr/api/login.php?username=admin&password=pass"
	set req=##class(%Net.HttpRequest).%New()
	do ##class(%Net.URLParser).Parse(loginURL,.url)
	set req.Server=url("host")
	set req.Port=80 //url("port")
	
	$$$TRACE("url(""path"")="_url("path"))
	set sc=req.Get(url("path")_"?username=admin&password=poiu7890")
	set xresp=req.HttpResponse.Data.Read()
	$$$TRACE(xresp)
	set token=$p($p(xresp,"<token>",2),"</token>",1)
	$$$TRACE("token="_token)
	return token
}

ClassMethod loginProviderAndGetToken(user, pass,ip) As %String
{
	//set loginURL="http://166.78.61.206/welvuoemr/openemr/api/login.php?username=admin&password=poiu7890"
	set loginURL="http://"_ip_"/openemr/api/login.php?username=admin&password=pass"
	set req=##class(%Net.HttpRequest).%New()
	do ##class(%Net.URLParser).Parse(loginURL,.url)
	set req.Server=url("host")
	set req.Port=80 //url("port")
	$$$TRACE("url(""path"")="_url("path"))
	$$$TRACE(url("path")_"?username="_user_"&password="_pass)
	set sc=req.Get(url("path")_"?username="_user_"&password="_pass)
	set xresp=req.HttpResponse.Data.Read()
	$$$TRACE(xresp)
	set token=$p($p(xresp,"<token>",2),"</token>",1)
	$$$TRACE("token="_token)
	return token
}

Method OnMessage(request As Ens.StringRequest, Output response As EnsLib.EDI.XML.Document) As %Status
{
	#dim error as %Exception.AbstractException

	set sc=$$$OK
	try {
		
		$$$TRACE("url="_request.StringValue)
		set token=..fetchToken()
		set tokenURL=request.StringValue_"&token="_token
		$$$TRACE("tokenURL="_tokenURL)
		do ##class(%Net.URLParser).Parse(tokenURL,.url)
		set ..Adapter.HTTPPort=$select($g(url("port"))'="":url("port"),1:80)
		set ..Adapter.HTTPServer=url("host")
		set sc=..Adapter.GetURL(url("path")_"?"_url("query")_"&token="_token,.httpResponse)
		$$$TRACE(sc)
		set stream=httpResponse.Data
		$$$TRACE("Got response size="_stream.Size)
		do stream.Rewind()
		set response=##class(EnsLib.EDI.XML.Document).ImportFromLibraryStream(stream,.sc)
		if $$$ISERR(sc) throw sc
		$$$TRACE("DocSchemaCategory="_..DocSchemaCategory)
		set response.DocType=..DocSchemaCategory
		
	} catch error {
		do error.Log()
		$$$TRACE(error.DisplayString())
	}
	Quit sc
}

XData MessageMap
{
<MapItems>
	<MapItem MessageType="Ens.StringRequest"> 
		<Method>OnMessage</Method>
	</MapItem>
</MapItems>
}

}

