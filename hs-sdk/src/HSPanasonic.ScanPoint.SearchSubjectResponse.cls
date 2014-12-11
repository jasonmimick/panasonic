class HSPanasonic.ScanPoint.SearchSubjectResponse extends Ens.Response
{
Property Hostname as %String;
Property SessionID as %String;
Property Status as %String(MAXLEN=10000);
Property Results as list of %ArrayOfDataTypes;

Method %OnNew() as %Status
{
	//set ..Results = ##class(%Collection.ListOfObj).%New()
	quit $$$OK
}

}
