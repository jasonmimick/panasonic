Class HSPanasonic.ScanPoint.SubmitDocumentRequest Extends Ens.Request
{

Property Timestamp As %TimeStamp;

Property Subject As %ArrayOfDataTypes;
//Property Subject As %Collection.ArrayOfDT;

Property User As %String(MAXLEN = 1000);

Property Name As %String(MAXLEN = 1000);

Property Type As %String(MAXLEN = 1000);

Property Size As %Integer;

Property Body As %Stream.GlobalBinary;

ClassMethod CreateFromJSONStream(stream As %Stream.Object) As HSPanasonic.ScanPoint.SubmitDocumentRequest
{
	do stream.Rewind()
	set j=""
	while ( 'stream.AtEnd ) { set j=j_stream.Read() }
	//set cls=..%ClassName(1)
	set cls="%ZEN.proxyObject"
	set sc=##class(%ZEN.Auxiliary.jsonProvider).%ConvertJSONToObject(j,cls,.proxy,1)
	set sdr=..%New()
	set sdr.Type=proxy.Type
	set sdr.User = proxy.User
	set sdr.Body = ##class(%Stream.GlobalBinary).%New()
	do sdr.Body.Write( proxy.Body )
	set sdr.Name = proxy.Name
	set sdr.Subject = ##class(%ArrayOfDataTypes).%New()
	do proxy.Subject.%CopyToArray(.subject)
	set key=$order(subject(""))
	while ( key'="" ) {
		do sdr.Subject.SetAt(subject(key),key)
		set key=$order(subject( key ))
	}
	// TODO VALIDATE sdr!!
	do stream.Rewind()		// be kind, always rewind :)
	return sdr
}

}

