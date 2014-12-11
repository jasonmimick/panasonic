class HSPanasonic.Setup extends %SYSTEM.Help
{

parameter VERSION as %String = "0.0.3";

classmethod OnPage() As %Status
{
	&html<
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>HSPanasonic Configuration Utility</title>

    <!-- Bootstrap -->
<link href="//maxcdn.bootstrapcdn.com/bootstrap/3.2.0/css/bootstrap.min.css" rel="stylesheet">

    <!-- HTML5 Shim and Respond.js IE8 support of HTML5 elements and media queries -->
    <!-- WARNING: Respond.js doesn't work if you view the page via file:// -->
    <!--[if lt IE 9]>
      <script src="https://oss.maxcdn.com/html5shiv/3.7.2/html5shiv.min.js"></script>
      <script src="https://oss.maxcdn.com/respond/1.4.2/respond.min.js"></script>
    <![endif]-->
  </head>
  <body role="document">
	 <!-- Fixed navbar -->
    <div class="navbar navbar-inverse navbar-fixed-top" role="navigation">
      <div class="container">
        <div class="navbar-header">
          <button type="button" class="navbar-toggle collapsed" data-toggle="collapse" data-target=".navbar-collapse">
            <span class="sr-only">Toggle navigation</span>
            <span class="icon-bar"></span>
            <span class="icon-bar"></span>
            <span class="icon-bar"></span>
          </button>
          <a class="navbar-brand" href="#">Bootstrap theme</a>
        </div>
        <div class="navbar-collapse collapse">
          <ul class="nav navbar-nav">
            <li class="active"><a href="#">Home</a></li>
            <li><a href="#about">About</a></li>
            <li><a href="#contact">Contact</a></li>
            <li class="dropdown">
              <a href="#" class="dropdown-toggle" data-toggle="dropdown">Dropdown <span class="caret"></span></a>
              <ul class="dropdown-menu" role="menu">
                <li><a href="#">Action</a></li>
                <li><a href="#">Another action</a></li>
                <li><a href="#">Something else here</a></li>
                <li class="divider"></li>
                <li class="dropdown-header">Nav header</li>
                <li><a href="#">Separated link</a></li>
                <li><a href="#">One more separated link</a></li>
              </ul>
            </li>
          </ul>
        </div><!--/.nav-collapse -->
      </div>
    </div>

    <div class="container theme-showcase" role="main">

      <!-- Main jumbotron for a primary marketing message or call to action -->
      <div class="jumbotron">
    <h3>Scanning Configuration Utility</h3>
	>
	
	set status = $get(^HSPanasonic.Setup("InstallStatus"))
	set ok=0
	if ( $listvalid( status ) ) {
		set ok=($list(status,1)="OK")
		if ( 'ok  ) { //'
			do ..showInstallError()
		} else {
			do ..showInstallStatus()
		}
	} else { 		// nothing installed
		do ..freshInstall()
	}
	&html<
   	</div>
	>
	do ..showConfiguration()
	&html<
	</div>
 <!-- jQuery (necessary for Bootstrap's JavaScript plugins) ' -->
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.1/jquery.min.js"></script>
    <!-- Include all compiled plugins (below), or include individual files as needed -->
<script src="//maxcdn.bootstrapcdn.com/bootstrap/3.2.0/js/bootstrap.min.js"></script>

	>
		//'
		set points = ^["ScanRegistry"]HSPanasonic.Setup.Defaults("Namespaces")
		set ports = ^["ScanRegistry"]HSPanasonic.Setup.Defaults("Ports")
		for i=1:1:$listlength(points) {
			set point=$list(points,i)
			&html<
				<script type="text/javascript">
				$(function(){
					$( '#("#btnEditSP"_point)#' ).click(function(e){
						alert( ' #( "#btnEditSP"_point)# ' );
					});
				});
				</script>
			>
		}
	&html<
  </body>
</html>
	>
	return $$$OK
	//'
}
classmethod showInstallError() [ internal ]
{
	set status = $get(^HSPanasonic.Setup("InstallStatus"))
	&html<
	Status: 
	<span class="label label-danger"> #( $list(status,1) )# </span>
	#( $ZDT( $list(status,2) ) )#
	>
}
classmethod showInstallStatus() [ internal ]
{
	set status = $get(^HSPanasonic.Setup("InstallStatus"))
	&html<
	Status: 
	<span class="label label-success"> #( $list(status,1) )# </span><br/>
	Timestamp: #( $ZDT( $list(status,2) ) )#
	>
}
classmethod showConfiguration() [ internal ]
{
	&html<
<div class="page-header">
        <h1>ScanPoints</h1>
      </div>
      <div class="row">
        <div xclass="col-md-6">
          <table class="table">
            <thead>
              <tr>
                <th>Name</th>
                <th>EndPoint</th>
                <th>Api Key</th>
                <th>Status</th>
                <th></th>
              </tr>
            </thead>
            <tbody>
		>
		//'	
		set points = ^["ScanRegistry"]HSPanasonic.Setup.Defaults("Namespaces")
		set ports = ^["ScanRegistry"]HSPanasonic.Setup.Defaults("Ports")
		for i=1:1:$listlength(points) {
			set point=$list(points,i)
			set scannerConfig = ##class(HSPanasonic.ScanRegistry.Scanner).FindByCredential(point)
			&html<
              <tr>
                <td>#($list(points,i))#</td>
                <td>#( scannerConfig.EndPoint )#</td>
				<td> #( scannerConfig.ApiKey )# </td>
                <td>
				<span class="label label-success"> OK </span>
				</td>
                <td>
 				<button id="#("btnEditSP"_point)#"
						type="button" class="btn btn-sm btn-primary"
				data-toggle="modal" data-target="#newScanPoint">
				Edit	
				</button>

				</td> </tr>
			>
		}
		&html<
              <tr>
                <td></td>
                <td></td>
                <td></td>
                <td></td>
                <td>
 				<button type="button" class="btn btn-sm btn-primary"
				data-toggle="modal" data-target="#newScanPoint">
				Add New +
				</button>
				</td>
              </tr>
		</tbody>
          </table>
        </div>
		<!-- Modal -->
<div class="modal fade" id="newScanPoint" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
  <div class="modal-dialog">
    <div class="modal-content">
      <div class="modal-header">
        <button type="button" class="close" data-dismiss="modal"><span aria-hidden="true">&times;</span><span class="sr-only">Cancel</span></button>
        <h4 class="modal-title" id="myModalLabel">ScanPoint</h4>
      </div>
      <div class="modal-body">
        <form class="form-horizontal" role="form">
  <div class="form-group">
    <label for="inputNewScanPointName" class="col-sm-2 control-label">
	Name
	</label>
    <div class="col-sm-10">
      <input type="text" class="form-control" id="inputNewScanPointName" 
			 placeholder="New ScanPoint Name">
    </div>
  </div>
  <div class="form-group">
    <label for="inputNewScanPointPassword" class="col-sm-2 control-label">
		Password</label>
    <div class="col-sm-10">
      <input type="password" class="form-control" 
			id="inputNewScanPointPassword" placeholder="Password">
    </div>
  </div>  
  <div class="form-group">
    <label for="inputNewScanPointApiKey" class="col-sm-2 control-label">
		ApiKey</label>
    <div class="col-sm-10">
      <input type="text" class="form-control" 
			id="inputNewScanPointApiKey" placeholder="#($system.Util.CreateGUID())#">
    </div>
  </div>  <div class="form-group">
    <label for="inputNewScanPointPort" class="col-sm-2 control-label">
		Port #</label>
    <div class="col-sm-10">
      <input type="text" class="form-control" 
			id="inputNewScanPointPort" placeholder="Port #">
    </div>
  </div>  
  <div class="form-group">
    <label for="inputNewScanPointBindAddr" class="col-sm-2 control-label">
		Bind Address</label>
    <div class="col-sm-10">
      <input type="text" class="form-control" 
			id="inputNewScanPointBindAddr" placeholder="Host/IP to bind">
    </div>
  </div>
</form>
      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-default" data-dismiss="modal">Cancel</button>
        <button type="button" class="btn btn-primary">Save changes</button>
      </div>
    </div>
  </div>
</div>
	>
}
classmethod freshInstall() [ internal ]
{
}

/// Installs a standard demo system
/// With 3 scan points and a registry
classmethod InstallDemo()
{
	set nl=$c(13,10)
	set b =   "_  _ ____ ____ _    ___ _  _ ____ _  _ ____ ____ ____   "_nl 
	set b = b_"|__| |___ |__| |     |  |__| [__  |__| |__| |__/ |___   "_nl
    set b = b_"|  | |___ |  | |___  |  |  | ___] |  | |  | |  \ |___   "_nl
	set b = b_"___  ____ _  _ ____ ____ ____ _  _ _ ____  ____ ___  _  _"_nl
	set b = b_"|__] |__| |\ | |__| [__  |  | |\ | | |     [__  |  \ |_/ "_nl
	set b = b_"|    |  | | \| |  | ___] |__| | \| | |___  ___] |__/ | \_"_nl

	Use 0::"^%XDTM"
	write /ab,b,/aa
	write "Version: ", ..#VERSION,!
	write "Installation Utility",!
	write "Current Settings:",!
	merge ^||HSPanasonic.Setup.Defaults.Backup = ^HSPanasonic.Setup.Defaults
   	kill ^HSPanasonic.Setup.Defaults
	set ns=$listbuild("ScanPoint1","ScanPoint2","ScanPoint3")
	set ^HSPanasonic.Setup.Defaults("Namespaces")=ns
	set ^HSPanasonic.Setup.Defaults("Ports")=$lb(8765,8766,8767)
	set pwds=$listbuild("password","password","password")
	set ^HSPanasonic.Setup.Defaults("Password")=pwds
	set ip=$system.INetInfo.HostNameToAddr($system.INetInfo.LocalHostName())
	set ^HSPanasonic.Setup.Defaults("Hostname")=ip

namespaceConfig
	write "ScanPoint Namespaces: "
	write $listtostring(^HSPanasonic.Setup.Defaults("Namespaces"))
	set value = 1
	set s=##class(%Prompt).GetYesNo("Accept?",.value)
	if ( value '= 1 ) {  //'
		write !,"Enter ScanPoint namespaces: "
		read spns
		break
		set ^HSPanasonic.Setup.Defaults("Namespaces")=$listfromstring(spns,",")
		goto namespaceConfig
	}
portConfig
	write !,"ScanPoint Ports: "
	write $listtostring(^HSPanasonic.Setup.Defaults("Ports"))
	set value = 1
	set s=##class(%Prompt).GetYesNo("Accept?",.value)
	if ( value '= 1 ) {  //'
		write !,"Enter ScanPoint ports: "
		read spns
		set ^HSPanasonic.Setup.Defaults("Ports")=$listfromstring(spns,",")
		goto portConfig
	}
hostnameConfig
	write !,"Hostname to bind: "
	write ^HSPanasonic.Setup.Defaults("Hostname")
	set value = 1
	set s=##class(%Prompt).GetYesNo("Accept?",.value)
	if ( value '= 1 ) {  //'
		write !,"Enter Hostname: "
		read spns
		set ^HSPanasonic.Setup.Defaults("Hostname")=spns
		goto hostnameConfig
	}	
	zw ^HSPanasonic.Setup.Defaults
	write "This tool will setup a ScanRegistry and ScanPoints using the " 
	write "settings above.",!
	set continue = "N"
	read "Do you wish to continue <No|Yes>?",continue,!
	if ( continue '= "Yes" ) {  //'
		merge ^HSPanasonic.Setup.Defaults = ^||HSPanasonic.Setup.Defaults.Backup
		quit
	} 
	do ..Install()
	write !,"Installation Complete.",!
	read "Do you wish to test the demo installation <N|Yes>?",continue
	if ( continue '= "Yes" ) {  //'
		write !,"Adios"
		quit
	}
	do ..TestInstallDemo()
	quit
	
} 

classmethod Install()
{
	try {
		new $namespace
		set $namespace="HSLIB"
		if ( '$data( ^HSPanasonic.Setup.Defaults ) ) {  //'
			// need to query and setup points to install	
		}
		do ..InstallSchemas()
		do ..InstallRegistry()
		do ..InstallScanPoints()
		set ^HSPanasonic.Setup("InstallStatus")=$lb("OK",$ZTS)
	} catch error {
		set ^HSPanasonic.Setup("InstallStatus")=$lb(error.DisplayString(),$ZTS)
		write error.DisplayString()
		
	}
}

/// Halt and Catch Fire - completely wipes out everything HSPanasonic 
/// deletes the ScanRegistry and ScanPoints
/// USE WITH CAUTION!
classmethod HCF() 
{
	Use 0::"^%XDTM"
	write /am,"Warning! This will completely wipe the HSPanasonic SDK from your system!",/aa,!
	read "Do you wish to continue <N|Yes>?",continue
	if ( continue '= "Yes" ) {  //'
		write !,"Cancelled"
		quit
	} 
	write !
	write "OK - you we're warned.",!
	do ..UnInstall()
	do $system.OBJ.DeletePackage("HSPanasonic")
}

/// Uninstalls the HSPanasonic registry and scan points
classmethod UnInstall()
{
	try {
		set $namespace="HSLIB"
		do ..UnInstallScanPoints()
		do ..UnInstallRegistry()
		do ..UnInstallSchemas()
	} catch error {
		set ^HSPanasonic.Setup("UninstallStatus")=$lb(error.DisplayString(),$zts)
		write error.DisplayString(),!
	}
}

classmethod InstallSchemas() [ internal ]
{
	set schema = ##class(%File).TempFilename("xml")
	do ##class(HS.SDA3.Container).ExportXMLSchemaAPI( schema )
	set ^HSPanasonic.Setup("HS.SDA3.Container-schema")=schema
}

classmethod getSDASchemaFile() As %String 
{
	return ^["HSLIB"]HSPanasonic.Setup("HS.SDA3.Container-schema")
}

classmethod UnInstallSchemas() [ internal ]
{
}

classmethod UnInstallRegistry() [ internal ]
{
	write "Uninstalling ScanRegistry"
	do ..UnInstallNS("ScanRegistry")
}

classmethod UnInstallScanPoints() [ internal ]
{
	for i=1:1:$listlength(^HSPanasonic.Setup.Defaults("Namespaces")) {
		set ns=$list(^HSPanasonic.Setup.Defaults("Namespaces"),i)
		write "Uninstalling ",ns,!
		try {
        do ..UnInstallNS(ns)
		} catch error { 
			write "Error uninstalling ",ns," Please run UnInstall again.",!
			write error.DisplayString(),!
		}
	}
}

classmethod UnInstallNS(ns as %String) [ internal ]
{
	do ..dbg("UnInstallNS("""_ns_""")")
	if ( '##class(%SYS.Namespace).Exists(ns) ) {  //'
		do ..dbg(ns _ " does not exist!")
		return
	}
	set currNS=$namespace
	set $namespace = ns
	do ##class(Ens.Director).StopProduction(30,1)
	Set $namespace="%SYS"
    $$$THROWONERROR(tSC,##class(%EnsembleMgr).DisableNamespace(ns,1))
    $$$THROWONERROR(tSC,##class(%EnsembleMgr).deleteNamespace(ns,1,1))
    set tDBResource="%DB_"_ns
	set $namespace=currNS
    do ##class(HS.Util.Installer).DeleteResource(tDBResource)
}

classmethod validateSetupConfig() [ internal ]
{
	  set defaults=$listbuild("ScanPointTest1","ScanPointTest2","ScanPointTest3")
	  set defaultPorts = $lb(8765,8766,8767)
	  if ( '$data(^HSPanasonic.Setup.Defaults) ) {   //'
	    set ^HSPanasonic.Setup.Defaults("Namespaces")=defaults
	    set ^HSPanasonic.Setup.Defaults("Ports")=defaultPorts
		set ip=$system.INetInfo.HostNameToAddr($system.INetInfo.LocalHostName())
	    set ^HSPanasonic.Setup.Defaults("Hostname")=ip
	  } else {
		set namespaces=^HSPanasonic.Setup.Defaults("Namespaces")
		set ports=^HSPanasonic.Setup.Defaults("Ports")
		set msg=##class(%ListOfDataTypes).%New()
		if ( '$listvalid(namespaces) ) {  //'
			do msg.Insert("$list expected in ^HSPanasonic.Setup.Defaults(""Namespaces"")")
		}
		if ( '$listvalid(ports) ) {   //'
		  do msg.Insert("$list expected in ^HSPanasonic.Setup.Default(""Ports"")")
		}
		if ( $listlength(namespaces)'=$listlength(ports) ) {  //'
		  do msg.Insert("Number of namespaces does not match number of ports. Check ^HSPanasonic.Setup.Defaults")
		}
		if ( msg.Count() > 0 ) {
			throw ##class(%Exception.General).%New("Invalid Setup",,msg)
		}
	  }	
	  write "Using configuration:",!
	  zw ^HSPanasonic.Setup.Defaults
}

classmethod AddHSPPackageMap(ns) [ internal ]
{
  new $namespace
  set $namespace="%SYS"
  set pkg="HSPanasonic"
  set properties("Database")="HSLIB"
  $$$THROWONERROR(sc,##class(Config.MapPackages).Create(ns,pkg,.properties))
}
classmethod InstallRegistry() [ internal ] 
{
	try {
	
	  do ..validateSetupConfig()
	  $$$THROWONERROR(sc,##class(HS.Util.Installer.Foundation).Install("ScanRegistry"))
	  do ..AddHSPPackageMap("ScanRegistry")
	  new $namespace
      set $namespace="ScanRegistry"
	  merge ^HSPanasonic.Setup.Defaults = ^["HSLIB"]HSPanasonic.Setup.Defaults
	  do ..CreateScannerConfigs()
	  set production="HSPanasonic.ScanRegistry.Production"
      do ##class(Ens.Config.Production).LoadFromClass(production)
	  $$$THROWONERROR(sc,##class(Ens.Director).StartProduction(production))
	} catch error {
		write error.DisplayString()
		throw error
	}
}

classmethod InstallScanPoints() [ internal ] 
{
	set currNS=$namespace
	for i=1:1:$ll(^HSPanasonic.Setup.Defaults("Namespaces")) {
		set ns=$list(^HSPanasonic.Setup.Defaults("Namespaces"),i)
	
		write "Mapping ^EnsEDI.XML.Schema(""HS.SDA3.Container"")...",!	
		merge ^EnsEDI.XML.Schema("HS.SDA3.Container")=^["HSLIB"]EnsEDI.XML.Schema("HS.SDA3.Container")
		set port=$list(^HSPanasonic.Setup.Defaults("Ports"),i)
	  $$$THROWONERROR(sc,##class(HS.Util.Installer.Foundation).Install(ns))
	  do ..AddHSPPackageMap(ns)
	  set $namespace=ns	
	  set production="HSPanasonic.ScanPoint.Production"
	  // todo - need to update Port on the EndpointService!
	  // need to update the ScanRegistryURL on the EndpointOperation
      do ##class(Ens.Config.Production).LoadFromClass(production)
	  set prod=##class(Ens.Config.Production).%OpenId(production)
	  set item=prod.FindItemByConfigName("EndpointService")
	  set setting=item.Settings.GetAt(2)
	  set setting.Value=port
	  $$$THROWONERROR(sc,prod.%Save())
	  $$$THROWONERROR(sc,##class(Ens.Director).StartProduction(production))
	  set $namespace=currNS
	}
}
classmethod CreateScannerConfigs() [ Internal ]
{
	set sampleCreds = ^["HSLIB"]HSPanasonic.Setup.Defaults("Namespaces") 
	new $namespace
    set $namespace = "ScanRegistry"
	// remove any sample creds already there
    set list = ##class(Ens.Config.CredentialsList).OpenAll()
	for i=1:1:list.CredentialsItems.Count() {
		set item=list.CredentialsItems.GetAt(i)
		if ( $listfind(sampleCreds,item.SystemName) ) {
			$$$THROWONERROR(sc,item.%Delete())
		}
	}
	for i=1:1:$listlength(sampleCreds) {
		set scred=$list(sampleCreds,i)
		set cred = ##class(Ens.Config.Credentials).%New()
		set cred.SystemName=scred
		set cred.Username=scred
		set cred.Password="password"
		$$$THROWONERROR(sc,cred.%Save())

		set scanner=##class(HSPanasonic.ScanRegistry.Scanner).%New()
		set scanner.Credential=scred
		set port=$list(^["HSLIB"]HSPanasonic.Setup.Defaults("Ports"),i)
		set scanner.EndPoint=..CreateEndPointURL(scred,port)
		set scanner.ApiKey=$system.Util.CreateGUID()
		set scanner.Active = 1
		$$$THROWONERROR(sc,scanner.%Save())
	}
}


classmethod CreateEndPointURL(ns as %String,port) as %String [ internal ]
{
	// http://<hostname>:<port>
	set host=$get(^|"HSLIB"|HSPanasonic.Setup.Defaults("Hostname"))
	if ( host = "" ) {
		set host = $system.INetInfo.HostNameToAddr( $system.INetInfo.LocalHostName() )
	}
	return "http://"_host_":"_port
}

classmethod dbg(msg)
{
	write msg,!
}


classmethod BuildKit(path as %String = {$system.Util.ManagerDirectory()})
{
	try {
	 new $namespace
	 set $namespace = "HSLIB"
	 set kit = "HSPanasonic.SDK_" _ ..#VERSION _ ".xml"
	 set fullkit = path _ kit
	 do ..dbg("BuiltKit started:" _ fullkit ) 
	 $$$THROWONERROR(sc,$system.OBJ.ExportPackage("HSPanasonic",fullkit))	
	 write !,"Kit complete @",$ZDT($ZTS),!
	 write fullkit,!
	} catch error {
	 write "Error: ",error.DisplayString(),!
	}
}

/// Tests that a demo installation works properly.
/// For each ScanPoint do a test /subjectSearch 
/// and /submitDocument
classmethod TestInstallDemo() 
{
	try {
		do ..testDemoInstallx()
	} catch error {
		write error.DisplayString()
	}
}

classmethod testDemoInstallx() [ internal ]
{
	new $namespace
	set $namespace = "ScanRegistry"
	set points = ^["ScanRegistry"]HSPanasonic.Setup.Defaults("Namespaces")
    set ports = ^["ScanRegistry"]HSPanasonic.Setup.Defaults("Ports")
	write "HSPanasonic Demo Install Testing Utility",!
	for i=1:1:$listlength(points) {
		set point=$list(points,i)
		set cfg = 
			##class(HSPanasonic.ScanRegistry.Scanner).FindByCredential(point)
	
		// fetch an api-key
		set cred = ##class(Ens.Config.Credentials).%OpenId(point)
		write !,"Testing " _ point,!	
		set headers("x-healthshare-username")=cred.Username
		set headers("x-healthshare-password")=cred.Password
		set response = ..POST("http://localhost:20187/",.headers)
		//do response.OutputHeaders()
		if ( response.StatusCode '= 200 ) { //'
			write "Error fetching apikey for " _ point
			do response.OutputToDevice()
			continue
		} else {
			write "EndPoint and ApiKey from ScanRegistry was SUCCESSFUL",!
		} 
		set endpoint = response.GetHeader("X-HEALTHSHARE-ENDPOINT")
		set apikey = response.GetHeader("X-HEALTHSHARE-APIKEY")

		set search = "{ ""LastName"" : ""Smith"" }"
		kill headers
		set headers("x-healthshare-apikey")=apikey
		set response = ..POST(endpoint _ "/subjectSearch",.headers,search)
		if ( response.StatusCode '= 200 ) { //'
			write "Error calling /subjectSearch for " _ point,!
			do response.OutputToDevice()
			continue
		} 
		write "/subjectSearch for " _ point _ " was SUCCESSFUL",!
		set sdr = ##class(%ZEN.proxyObject).%New()
		set sdr.Name = "TestDocument."_$random(100000)+1_"."_point
		set sdr.Type = "txt"
		set sdr.Subject = ##class(%ZEN.proxyObject).%New()
		set sdr.Subject.LastName = "Smith"
		set sdr.Subject.FirstName = "John"
		set sdr.Subject.SSN = "123-23-1234"
		set fakeDoc = ""
		for j=1:1:25 { 	// 25 lines in a fake document
			set line = "Hello World! Line #"_j_$c(13,10)
			set fakeDoc = fakeDoc _ line
		}	
		set sdr.Body = $system.Encryption.Base64Encode( fakeDoc ) 
		set sdr.Size = $length( sdr.Body )
		$$$THROWONERROR(sc,##class(Ens.Util.JSON).ObjectToJSONStream(sdr,.body))
		set response = ..POST(endpoint _ "/submitDocument",
							 .headers, .body)
		if ( response.StatusCode '= 200 ) { //'
			write "Error calling /submitDocument for " _ point,!
			do response.OutputToDevice()
			continue
		}	
		write "/submitDocument for " _ point _ " was SUCCESSFUL",!
	}
}

classmethod POST(url,byref headers,body="") as %Net.HttpResponse [ internal ]
{
	set req=##class(%Net.HttpRequest).%New()
	do ##class(%Net.URLParser).Parse(url,.parsedUrl)
	set req.Server = parsedUrl("host")
	set req.Port = parsedUrl("port")
	set headerKey = $order(headers(""))
	while ( headerKey '= "" ) { //'
		do req.SetHeader( headerKey, headers(headerKey) )
		set headerKey = $order(headers(headerKey))
	}
	if ( $isobject(body)  && body.%Extends("%Stream.Object") ) {
		do body.Rewind()
		while ( 'body.AtEnd ) { //'
			do req.EntityBody.Write( body.Read() ) 
		}
		do req.EntityBody.Rewind()
		set req.ContentType = "application/json"
	}
	if ( ('$isobject(body)) && (body '= "") ) {   //'
		do req.EntityBody.Write( body ) 
		set req.ContentType = "application/json"
	}
	$$$THROWONERROR(sc,req.Post( parsedUrl("path") ))
	return req.HttpResponse
	
}

}

