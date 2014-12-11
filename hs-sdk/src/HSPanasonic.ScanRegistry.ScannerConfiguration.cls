/// This is the Credentials page of the ZEN Ensemble application.
Class HSPanasonic.ScanRegistry.ScannerConfiguration Extends EnsPortal.Template.standardPage [ System = 4 ]
{

/// Displayed name of this page.
Parameter PAGENAME = "ScannerConfiguration";

/// User needs READ permissions on the %Ens_Credentials resource to view this page.
Parameter RESOURCE = "%Ens_Credentials:READ";

/// User needs WRITE permissions on the %Ens_Credentials resource to make changes on this page.
Parameter EDITRESOURCE = "%Ens_Credentials:WRITE";

/// ID of credentials to display.
Property scannerId As %String(ZENURL = "ID");

/// Whether or not the URL supplied a valid credentials ID value
Property idExists As %ZEN.Datatype.boolean;

/// Whether or not the page should warn upon reload
Property skipWarning As %ZEN.Datatype.boolean;

/// This Style block contains page-specific CSS style definitions.
XData Style
{
<style type="text/css">

.zenLabel {
	color: #404040;
	font-size: 10pt;
}

.tnbrTable {
	border: 1px solid #808080;
	background: #D0D0D0;
	background-image: none;
}

.ribbonTitle {
	background: #D0F0D0;
}

#tableGroup {
	overflow: hidden;
	border-right: 1px solid #F0F0F0;
	border-left: 1px solid #F0F0F0;
	border-bottom: 1px solid #F0F0F0;
}

#descriptionPanel {
	width: 200px;
	background: white;
	font-size: 11pt;
	color: #404040;
	padding: 8px;
	overflow: auto;
}

#detailGroup {
	width: 350px;
	background: #E0E0D0;
	overflow: auto;
	border-right: 1px solid #F0F0F0;
	border-bottom: 1px solid #F0F0F0;
}

#tableGroup {
	overflow: auto;
}

/* style for table pane */
table.tpTable {
	background: white;
}

table.tpTable th {
	color: #404040;
	font-weight: bold;
	text-align: left;
	padding: 2px;
	overflow: hidden;
	background: #D0D0D0;
	background-image: none;
}

table.tpTable th.tpHdrSelected {
	color: #404040;
	font-weight: bold;
	text-align: left;
	padding: 2px;
	overflow: hidden;
	background: #D0D0F0;
	background-image: none;
}

</style>
}

/// This XML block defines the contents of the main pane.
XData contentPane [ XMLNamespace = "http://www.intersystems.com/zen" ]
{
<pane id="pane" hidden="true">
<hgroup cellVAlign="top">
<html id="descriptionPanel" OnDrawContent="DrawDescription" />
<vgroup id="tableGroup">
<tablePane id="table" 
cellSpacing="2"
useSnapshot="true"
maxRows="10000"
pageSize="10000"
queryClass="HSPanasonic.ScanRegistry.Scanner"
queryName="List"
showZebra="true"
valueColumn="ID"
onselectrow="zenPage.rowSelected(zenThis);"
onunselectrow="zenPage.rowSelected(zenThis);"
>
<column colName="ID" header="ID"/>
<column colName="Credential" header="Credential" />
<column colName="EndPoint" header="EndPoint"/>
<column colName="Active" header="Active"/>
<column colName="ApiKey" header="API Key" />
</tablePane>
</vgroup>
<vgroup id="detailGroup">
<form id="scannerForm" cellStyle="padding:3px;">
<hidden name="ID" id="txtID"/>
<hgroup label="Credential"  hint="Name of the Credential associated with this item">
<selector name="Credential" id="selCredential" context="Ens.ContextSearch/Credentials" size="30" onkeyup="zenPage.setModified(true);" onchange="zenPage.setModified(true);"/>
</hgroup>
<!--
<text label="Credential" name="Credential" id="txtCredential" size="35" hint="The ID of the Ensemble Credential to use for this scanner" onkeyup="zenPage.setModified(true);"/>
-->
<text label="EndPoint" name="EndPoint" id="txtEndPoint" size="45" hint="URL of EndPoint this scanner should connect to" onkeyup="zenPage.setModified(true);"/>
<text label="API Key" name="ApiKey" id="txtApiKey" size="45" hint="API key for this scanner" onkeyup="zenPage.setModified(true);"/>
<spacer height="5"/>
<hgroup>
<button controlClass="commandButton" id="btnNew" caption="New" onclick="zenPage.doNew();"/>
<spacer width="5" />
<button controlClass="commandButton" id="btnSave" caption="Save" onclick="zenPage.save();"/>
<spacer width="5" />
<button controlClass="commandButtonRemove" id="btnRemove" caption="Remove" onclick="zenPage.deleteItem();" />
</hgroup>
</form>
</vgroup>
</hgroup>
</pane>
}

/// Draw the contents of the description panel.
Method DrawDescription(pSeed As %String) As %Status
{
	Write $$$Text("Scanner Configuration - here you map Ensemble credentials to API Keys and EndPoints for scanner to send documents into")
	Write "<br/>"
	Write "<br/>"

	Write $$$Text("The table shows all the scanners currently defined in the ScanRegistry.")
	Write $$$Text("You can use the form on the right to create, edit, or delete scanner configurations.")

	Quit $$$OK
}

/// Get the (localized) name of the page.
/// This should be implemented in a subclass.
Method %OnGetPageName() As %String
{
	Quit $$$Text("ScannerConfigurations")
}

/// Get the (localized) title string for the page.
/// This should be implemented in a subclass.
Method %OnGetTitle() As %String
{
	Quit $$$Text("ScannerConfigurations")
}

/// This callback, if implemented returns information used to display
/// the standard ribbon bar.<br/>
Method OnGetRibbonInfo(Output pDisplay As %Boolean, Output pViewIcons As %List, Output pSortOptions As %List, Output pSearchBox As %Boolean, Output pRibbonTitle As %String, Output pCommands As %List) As %Status
{
	Set pDisplay = 1
	Set pRibbonTitle = $$$Text("Scanner Configurations Viewer")
	Quit $$$OK
}

/// User selected a row in the table
ClientMethod rowSelected(table) [ Language = javascript ]
{
	// update details pane using ID value from table
	var idx = table.selectedIndex
	if (idx >= 0) {
		var id = table.getProperty('value');
		this.UpdateDetails(id);
	} else {
		this.resetForm(); // this deletes the src value from the <image> component on more than one browser

	}
}

/// UpdateDetails:
/// Update contents of details pane.
ClassMethod UpdateDetails(id) [ ZenMethod ]
{
	// try to open the object
	Set tObj = ##class(HSPanasonic.ScanRegistry.Scanner).%OpenId(id)
	If $IsObject(tObj) {
		&js<zen('txtID').setValue('#($ZCVT(id,"O","JS"))#');>
		//&js<zen('txtSystemName').setValue('#($ZCVT(id,"O","JS"))#');>
		&js<zen('selCredential').setValue('#($ZCVT(tObj.Credential,"O","JS"))#');>
		&js<zen('txtEndPoint').setValue('#($ZCVT(tObj.EndPoint,"O","JS"))#');>
		&js<zen('txtApiKey').setValue('#($ZCVT(tObj.ApiKey,"O","JS"))#');>
	}
	Else {
		&js<alert("Cannot open object!");>
	}
	Quit
}

/// Reset the form programmatically
ClientMethod resetForm() [ Language = javascript ]
{
	var form = zen('scannerForm');
	form.reset();
	var table = zen('table')
	table.selectRow(table.selectedIndex);
}

/// User clicked Delete button.
ClientMethod deleteItem() [ Language = javascript ]
{
	if (!this.checkEdit()) { return; }
	var idx = zen('table').selectedIndex;
	var id = (idx >= 0) ? zen('table').getProperty('value') : '';
	if (id!='') {
		if (confirm($$$Text('Are you sure you want to delete this item?'))) {
			var msg = this.DeleteID(id);
			if (''!=msg) {
				alert(msg);
			}
			//zen('table').executeQuery(); // causes page to hang several seconds
			zenPage.skipWarning = true;
			self.document.location = self.document.location; // this works instead
		}
	} else {
		alert($$$Text('Please select a Scanner Configurtion row to delete'));
	}
}

/// Delete the given id.
ClassMethod DeleteID(id) As %String [ ZenMethod ]
{
	Set tMsg = ""
	Set tSC = ##class(HSPanasonic.ScanRegistry.Scanner).%DeleteId(id)
	If $$$ISERR(tSC) {
		Set tMsg = $System.Status.GetErrorText(tSC)
	}
	Quit tMsg
}

/// Save the contents of the form.
ClientMethod save() [ Language = javascript ]
{
	if (!this.checkEdit()) { return; }
	var id = zen('txtID').getValue();
	var name = zen('selCredential').getValue();

	if (name == '') {
		alert($$$Text("Please provide an Credential for this item."));
		return;
	}

	// TODO - Validate the credential is a real one!
	/*
	if ((id!='')&&(id!=name)) {
		if (!confirm($$$Text("Do you wish to rename this item? This will not rename references to this item."))) {
			return;
		}
	}
	*/
	var form = zen('scannerForm');
	var data = form.getValuesAsObject();
	var msg = this.SaveItem(data);
	if (msg != '') {
		alert(msg);
	}
	else {
		//zen('table').executeQuery(); // causes page to hang several seconds
		zenPage.skipWarning = true;
		self.document.location = self.document.location; // this works instead
		zenPage.resetFieldState();
	}
}

/// Reset the fields that control whether or not to warn the user about leaving the page
ClientMethod resetFieldState() [ Language = javascript ]
{
	zenPage.setModified(false);
	zenPage.skipWarning = false;
}

/// Save the given item.
ClassMethod SaveItem(pItem As %ZEN.proxyObject) As %String [ ZenMethod ]
{
	Set tMsg = ""
	Set tSC = $$$OK
	Try {
		// test to see if we are replacing an old item, modifying an old item, or creating a new item
		//Set name = pItem.SystemName 
		Set id = pItem.ID
		If ((id'="")&&##class(HSPanasonic.ScanRegistry.Scanner).%ExistsId(id)) {
			// modify old item
			Set tClsDef = ##class(HSPanasonic.ScanRegistry.Scanner).%OpenId(id)
		}
		Else {
			// should be new!
			If (##class(HSPanasonic.ScanRegistry.Scanner).%ExistsId(id)) {
				Set tMsg = $$$Text("This id is already in use")
				Quit
			}
			Set tClsDef = ##class(HSPanasonic.ScanRegistry.Scanner).%New()
		}

		Set tClsDef.Credential = pItem.Credential
		Set tClsDef.EndPoint = pItem.EndPoint
		Set tClsDef.ApiKey = pItem.ApiKey
		
		Set tSC = tClsDef.%Save()

		// return new id value
		&js<zen('txtID').setValue('#($ZCVT(tClsDef.%Id(),"O","JS"))#')>

	}
	Catch(ex) {
		Set tSC = ex.AsStatus()
	}

	If $$$ISERR(tSC) {
		Set tMsg = $System.Status.GetErrorText(tSC)
	}
	Quit tMsg
}

ClientMethod doNew() [ Language = javascript ]
{
	if (zenPage.pageModified) {
		if (!confirm($$$Text('Changes have been made on this page.')+'\n'+
		             $$$Text('Do you wish to discard the changes and start creating a new credentials record?'))) {
			return;
		}
	}
	zen("txtID").setValue("");
	zen("selCredential").setValue("");
	zen("txtEndPoint").setValue("");
	zen("txtApiKey").setValue("");
}

/// This client event is fired when the page is resized.
ClientMethod onlayoutHandler(load) [ Language = javascript ]
{
	this.adjustSizes();
}

/// Adjust sizes of components on the page.
ClientMethod adjustSizes() [ Language = javascript ]
{
	try {
		if (this.inResizeLoop()) return;
		zen('pane').setHidden(false);

		var descDiv = zen('descriptionPanel').getEnclosingDiv();
		var tgDiv = zen('tableGroup').getEnclosingDiv();
		var tableDiv = zen('table').getEnclosingDiv();
		var detailDiv = zen('detailGroup').getEnclosingDiv();

		// find size of window
		var winHeight = zenGetWindowHeight();
		var winWidth = zenGetWindowWidth();

		var th = this.getTitleAreaHeight();
		var hgt = winHeight - th - 25;

		var tableHgt = hgt;
		var tableWid = winWidth - descDiv.offsetWidth - detailDiv.offsetWidth;

		descDiv.style.height = tableHgt + 'px';
		detailDiv.style.height = tableHgt + 'px';
		tgDiv.style.height = tableHgt + 'px';
		tgDiv.style.width = tableWid + 'px';
		tableDiv.style.width = tableWid + 'px';
	}
	catch(ex) {
		zenExceptionHandler(ex,arguments,'Error in adjustSizes');
	}
}



/// Decorate the page.
Method %OnAfterCreatePage() As %Status
{
	Set tSC = ##super()
	If $$$ISERR(tSC) Quit tSC
	
	Set %page.idExists = 0
	If %page.scannerId '= "" { // try to match the provided id to an existing credential
		If ##class(HSPanasonic.ScanRegistry.Scanner).%ExistsId(%page.scannerId) {
			Set %page.idExists = 1
			Set tObj = ##class(HSPanasonic.ScanRegistry.Scanner).%OpenId(%page.scannerId)
			Set ..%GetComponentById("txtID").value = %page.scannerId
			Set ..%GetComponentById("selCredential").value = %page.Credential
			Set ..%GetComponentById("txtEndPoint").value = tObj.EndPoint
			Set ..%GetComponentById("txtApiKey").value = tObj.ApiKey
			Kill tObj
		}
	}

	Quit tSC
}

/// This client event, if present, is fired when the page is loaded.
ClientMethod onloadHandler() [ Language = javascript ]
{
	this.invokeSuper('onloadHandler',[]);
	if (zenPage.idExists) { // a valid id value was supplied
		var tab = zen('table');
        var rowCount = parseInt(tab.rowCount); // table.rowCount can be a string value
		for (i = 0; i < rowCount; i++) { // highlight the row for the currently selected id
            var rowData = tab.getRenderedRowData(i);
            if (rowData && rowData.ID && (rowData.ID == zenPage.scannerId ))  {
                tab.setProperty('selectedIndex',i);
                return true;
            }		
        }
	}
	zenPage.skipWarning = false;
}

ClientMethod onunloadHandler() [ Language = javascript ]
{
	if ((!zenPage.skipWarning) && (this.pageModified)) {
		return $$$Text('Changes have been made on this page.')+'\n'+$$$Text('Do you wish to leave the page and discard the changes?');
	}
	return true;
}

/// Callback to return a list of resources required for a specific HyperEvent.
/// The user must have sufficient privileges on one of the resource/permission pairs
/// to be permitted to execute the hyperevent. An empty string implies the user already
/// has sufficient privileges for the ZenMethod specified in <var>pMethod</var>.
ClassMethod GetHyperEventResources(pMethod As %String = "") As %String
{
	Quit $case(pMethod, 
						"DeleteID": ..#EDITRESOURCE,
						"SaveItem": ..#EDITRESOURCE,
							: "")
}

}

