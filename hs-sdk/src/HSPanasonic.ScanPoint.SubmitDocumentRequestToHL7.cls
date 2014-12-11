Class HSPanasonic.ScanPoint.SubmitDocumentRequestToHL7 Extends Ens.DataTransformDTL [ DependsOn = (HSPanasonic.ScanPoint.SubmitDocumentRequest, EnsLib.HL7.Message) ]
{

XData DTL [ XMLNamespace = "http://www.intersystems.com/dtl" ]
{
<transform sourceClass='HSPanasonic.ScanPoint.SubmitDocumentRequest' targetClass='EnsLib.HL7.Message' targetDocType='2.5.1:ORU_R01' create='new' language='objectscript' >
<assign value='"ORU"' property='target.{MSH:MessageType.MessageCode}' action='set' />
<assign value='"R01"' property='target.{MSH:MessageType.TriggerEvent}' action='set' />
<assign value='..CurrentDateTime()' property='target.{MSH:DateTimeOfMessage}' action='set' />
<assign value='..BLOBToBase64RFC2045MIMELines(source.Body)' property='b64' action='set' />
<assign value='1' property='target.{PIDgrpgrp(1).PIDgrp.PID:SetIDPID}' action='set' />
<foreach property='b64' key='li' >
<assign value='li' property='target.{PIDgrpgrp(1).ORCgrp(1).OBXgrp(li).OBX:SetIDOBX}' action='set' />
<assign value='b64.GetAt(li)' property='target.{PIDgrpgrp(1).ORCgrp(1).OBXgrp(li).OBX:ObservationValue(1)}' action='set' />
</foreach>
<assign value='source.Subject.GetAt("LastName")' property='target.{PIDgrpgrp(1).PIDgrp.PID:PatientName(1).FamilyName}' action='set' />
<assign value='source.Subject.GetAt("FirstName")' property='target.{PIDgrpgrp().PIDgrp.PID:PatientName().GivenName}' action='set' />
</transform>
}

Parameter IGNOREMISSINGSOURCE = 1;

Parameter REPORTERRORS = 1;

ClassMethod BLOBToBase64RFC2045MIMELines(stream As %Stream) As %ListOfDataTypes
{
	set b64 = ##class(%Library.ListOfDataTypes).%New()
	do stream.Rewind()
	set b64stream = ##class(%Stream.TmpCharacter).%New()
	while ( 'stream.AtEnd ) {
		set b = $system.Encryption.Base64Encode( stream.Read() )
		do b64stream.Write( b )
	}
	do b64stream.Rewind()
	set chunkSize = 76
	while ( 'b64stream.AtEnd ) {
		/* What is this +2, -2 stuff on chunkSize?
		   It removes the \r\n which is embedded in the Base64 encoding */
		set chunk = b64stream.Read( chunkSize + 2)
		set line = $extract( chunk, 1, (chunkSize - 2) )
		do b64.Insert( line )  	
	}
	return b64
}

}

