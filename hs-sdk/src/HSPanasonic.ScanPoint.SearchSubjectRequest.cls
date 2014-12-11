class HSPanasonic.ScanPoint.SearchSubjectRequest extends Ens.Request
{

property SearchFields as %ArrayOfDataTypes;

method %OnNew() As %Status 
{
	set ..SearchFields = ##class(%ArrayOfDataTypes).%New()
	return $$$OK
}

}
