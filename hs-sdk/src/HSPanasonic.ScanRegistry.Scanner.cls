class HSPanasonic.ScanRegistry.Scanner extends %Persistent
{

/// Pointer to Ens credential
Property Credential As %String;

///
Property ApiKey As %String;

Property EndPoint As %String;

Property Active As %Boolean;

ClassMethod FindByCredential(credential as %String)
	as HSPanasonic.ScanRegistry.Scanner
{
	new $namespace
	set $namespace = "ScanRegistry"
	set cred=" "_$zconvert(credential,"U")
	
	set id=$order(^HSPanasonic.ScanReFE36.ScannerI("CredentialIndex",cred,""))
	set ^id($i(^id))=id
	if ( id = "" ) {
		throw ##class(%Exception.General).%New("Credential='"_credential_"' not found! cred='"_cred_"'")
	}
	return ..%OpenId(id)
}
Query List() as %SQLQuery
{
	select ID,Credential,ApiKey,EndPoint,Active from HSPanasonic_ScanRegistry.Scanner
}

Index CredentialIndex on Credential [ Data = Credential, Unique ];
Index ApiKeyIndex on ApiKey [ Data = ApiKey, Unique];
}
