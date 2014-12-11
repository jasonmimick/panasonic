Class HSPanasonic.ScanPoint.SubmitDocumentRequestToSDA Extends Ens.DataTransformDTL [ DependsOn = (HSPanasonic.ScanPoint.SubmitDocumentRequest, EnsLib.EDI.XML.Document) ]
{

Parameter IGNOREMISSINGSOURCE = 1;

Parameter REPORTERRORS = 1;

XData DTL [ XMLNamespace = "http://www.intersystems.com/dtl" ]
{
<transform sourceClass='HSPanasonic.ScanPoint.SubmitDocumentRequest' targetClass='EnsLib.EDI.XML.Document' targetDocType='HS.SDA3.Container:Container' create='new' language='objectscript' >
<assign value='source.Subject.GetAt("LastName")' property='target.{Patient.Name.FamilyName}' action='set' />
<assign value='source.Subject.GetAt("FirstName")' property='target.{Patient.Name.GivenName}' action='set' />
<code>
<![CDATA[ set stream=##class(%GlobalBinaryStream).%New()
 do source.Body.Rewind()
 while ( 'source.Body.AtEnd ) { do stream.Write( source.Body.Read() ) }
 do stream.Write("HELLO FOO BAR")
 do source.Body.Rewind() 
 do stream.Rewind()]]></code>
<assign value='source.Name' property='target.{Documents(1).DocumentName}' action='set' />
<assign value='stream.Read()' property='target.{Documents(1).Stream}' action='set' />
</transform>
}

}

