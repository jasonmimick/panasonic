HealthShare-Panasonic-SDK
-------------------------
Version 1.0  October 2014
jmimick@intersystems.com

  This note outlines a software development kit (SDK) which allows Panasonic 
KV-SS1100 enabled scanners to communicate with InterSystems' HealthShare.

  The SDK is comprised of the following:

  (1) A scanner "PlugIn" application which runs directly on the KV-SS1100.

  (2) A collection of HealthShare components which facilitate the collection, 
transformation, and downstream processing of scanned documents.

  Communication between scanners and HealthShare can be visualized as:

              --------------                  (~~~~~~~~~~~~~)                
              |            |     REST API     (             ) 
              | scanner(s) |   <---------->   ( HEALTHSHARE ) 
              |            |      HTTPS       (             )
              --------------                  (~~~~~~~~~~~~~)

  Each scanner will communicate with an instance of HealthShare deployed in 
the cloud using a standard HTTPS connection and a REST-style api.

  The scanners are essentially plug-and-play in the sense that they only need 
a URL and valid set of credentials in order to start sending documents 
electronically into HealthShare. The web-based administration tool for the 
KV-SS1100 is used to configure these settings.

  When the HealthShare (HS) user/password is entered into the administrative 
web tool, they are securely sent, using the URL provided, into HS where 
additional processing occurs to determine the available data pipelines for 
document processing. Based upon this logic HS then returns an "api-key" and a 
REST endpoint to the scanner which it can then use to send documents 
(technical details below). These data processing pipelines require 
configuration and customization within HS in order to properly send 
documents into downstream systems according to a given customers requirements.

  The remaining sections of this document describe the REST protocol between
scanners and HS, the components running within HealthShare itself, and setup 
and installtion procedures. Jump down to 'Getting Started' if you want to
skip the technical details.

Scanner/HS REST Protocol
------------------------

  There are a few overriding design principles of the protocol:

  (1) Only POSTs over an HTTPS connections are supported. Each request must 
contain a valid api-key in the HTTP headers, for example:

POST /subjectSearch HTTP/1.1
User-Agent: MyBrowser
Host: localhost
Accept: application/json
X-HealthShare-ApiKey: EE9C15F0-44DA-11E4-8C72-3835581ADC00 

  (2) Each endpoint requires a JSON document be sent in the body of the HTTP 
request. 

  (3) All date and time datatypes follow the ISO8601 format and should be UTC.

  (4) Each endpoint will return standard HTTP response codes; 200, 403, 500,
etc. Basic error messages are including the the response body, but 
operational staff should consult the HS message trace and event logs for
details.

REST API REFERENCE
------------------

Endpoint:            Subject Search 

  This endpoint is used by clients to query for a subject (usually a patient)
to be linked to a pending document scan. Requests to this endpoint are routed 
to an actual implementation which delegates the query to some data source,  
such as an external EMR, HIE PIX/PDQ, or SQL table.

Url:                 /subjectSearch
Method:              POST
Url Parameters:      None
Data Parameters:     JSON document with search fields

Example Request Body:

{ "FirstName" : "John",
  "LastName"  : "Smith",
  "AppointmentDate" : "2014-09-25T07:07:31Z"
}

Example Reponse Body:

{ "hostname" : "panasonic.healthshare.us",
  "sessionid" : 1234,
  "status" : "OK"
  "Results" : [ 
    { "FirstName" : "John",
      "LastName" : "Smith",
      "Address" : "123 Main Street",
      "SSN" : "123-12-1234"
    },
    { "FirstName" : "Johnathan",
      "LastName" : "Smithy",
      "Address" : "1912 Oak Lane Apt #9",
      "SSN" : "909-87-2381"
    }  
  ]
}

The 'sessionid' property in the response body correlates to the HS 'Session'
in the Message Viewer. Note that the exact contents of each item in the 
'Results' array is determined by the actual implementation. The plugin on the 
KV-SS1100 is build to dynamically display the contents of each item in the 
'Results' array. (The KV-SS1100 uses and internal REST endpoint 
/meta/subjectSearch to query the configured search operation for the search 
fields it supports and uses the results to dynamically build the search user
interface.)

Endpoint:            Submit a document 

  Sends a document along with subject into HS for further processing.

URL:                 /submitDocument
Method:              POST
Url Parameters:      None
Data Parameters:     JSON object with subject and scanned document

Example Request Body:
{ "Timestamp" : <iso date format>,
  "User"      : <identifier for who scanned>,
  "Subject" : <item returned from subjectSearch results>,
  "Name" : "Dr Jones's Notes on Timmy",
  "Type" : <pdf|xls|docx|txt|rtf...>,
  "Size" : <# of bytes encoded document body>,
  "Body" : <base 64 encoded body>
}

Example Response Body:

{ "hostname" : "panasonic.healthshare.us",
  "sessionid" : 1234,
  "status" : "OK"
}

HealthShare Components
----------------------

  Within HS the SDK is has a set of fixed services, processes, and 
operations which can be configured to point to other operations which
provide data. For example, when a request to the /subjectSearch service
gets sent into HS a standard service will accept the request but then
forward it on to some configured operation to actually perform the search.
There are a number of out-of-the-box implementations in the SDK.

  Any HS instance providing scanning services has a special central registry 
running to provide the initial configuration service for the scanners. This 
registry runs in it's own namespace called "ScanRegistry". Here the 
HSPanasonic.ScanRegistry.Production is responsible for providing scanners 
their api-keys and REST endpoints. The keys and endpoints are controlled by a 
database table HSPanasonic_ScanRegistry.Scanner which associates a 
user/password (Ensemble Credential) with a key and endpoint. The endpoints 
point to other namespaces on the HS instance (or on other HS instances) which 
are configured to ingest documents from scanners - these are called 
"Scan Points". An administrative user interface in the management portal is 
available to maintain this configuration.

Administrative Scanner Configuration URL (relative):
/csp/healthshare/scanregistry/HSPanasonic.ScanRegistry.ScannerConfiguration.zen

  Each scan point runs the HSPanasonic.ScanPoint.Production which contains
an HTTP Service, called EndpointService, accepting the REST calls as outlined
above from scanners. The EndpointService is just a standard 
EnsLib.HTTP.GenericService.These productions must be customized based upon the 
routing and transformation needs of the particular customer. 

  The REST api described above is surfaced in HS by the 
HSPanasonic.ScanPoint.EndpointOperation which processes the HTTP requests 
sent to the EndpointService. The EndpointOperation is then configured 
through settings to call /searchSubject and /submitDocument implementations. 
(The decoupling here is to provide an extensibility point - possibly other 
wire-protocols could be supported with new services which translate requests 
into EnsLib.HTTP.GenericMessage's.)

  HSPanasonic.ScanPoint.EndpointOperation has 3 configuration items

  ScanRegistryURL
  SearchSubjectTarget
  SubmitDocumentTarget

  The ScanRegistryURL points to the HTTP service running in the ScanRegistry
namespace. By default this is https://localhost:20187, but could point to some 
other host running the registry.

  The SearchSubjectTarget should be a process or operation which can respond
synchronously to an HSPanasonic.ScanPoint.SearchSubjectRequest 
and which returns an HSPanasonic.ScanPoint.SearchSubjectResponse. 

The SDK contains:

   HSPanasonic.ScanPoint.SearchSubjectPDQOperation   <TODO>
      Does an IHE PDQ lookup to find subjects

   HSPanasonic.ScanPoint.SearchSubjectSampleOperation
      Does a search on the Sample.Person table in HS

   HSPanasonic.ScanPoint.SearchSubjectSQLOperation   <TODO>
      Executes arbitrary SQL to implement the search

   HSPanasonic.OpenEMR.SearchSubjectOperation
      Invokes a the searchpatient.php API on an instance of OpenEMR
      (requires the OpenEMR-API to be installed: 
       https://github.com/oemr501c3/openemr-api)

  The SubmitDocumentTarget should be a process or operation which can accept
a HSPanasonic.ScanPoint.SubmitDocumentRequest and return a 
HSPanasonic.ScanPoint.SubmitDocumentResponse. The actual document processing 
can be synchronous or asynchronous, but the EndpointOperation does expect a
valid response.

  To facilitate the resuse of standard HS components the SDK contains a
data transformation which converts a SubmitDocumentRequest into an instance
of SDA. This transformation, HSPanasonic.ScanPoint.SubmitDocumentRequestToSDA, 
can be used in conjunction with other out-of-the-box transformations to 
convert the scanned document into HL7, CDA, or other formats for downstream 
processing.

  The SDK contains the following SubmitDocumentTarget implementations:

  ScanPoint.SubmitDocumentFileOperation
    Writes the document out to a file on disk

  ScanPoint.SubmitDocumentHL7Operation
    Embeds the document in an HL7 message

  ScanPoint.SubmitDocumentCCDAOperation  <TODO>
    Converts the document to a CCDA document

  HSPanasonic.OpenEMR.SendDocumentToOpenEMR
    Invokes a the addpatientdocument.php API on an instance of OpenEMR
    (requires the OpenEMR-API to be installed: 
     https://github.com/oemr501c3/openemr-api)

Getting Started
---------------

  Step 0 is to plan out and fully understand who is going to be scanning what 
from where and how those documents need to be routed. This planning could
become complex, so it's best to start simple.

  Both scanners and HS must be configured to get a system up and running. Start
by configuring your HS instance which you can fully test prior to connecting
actual KV-SS1100's.

HealthShare Setup
-----------------

  (1) Install an "HSAP" kit with version >= 2014.1
      HealthShare Modules:Core:12.02.2733 + Linkage Engine:12.01.2733

  (2) Fetch the SDK from:
      https://raw.githubusercontent.com/jasonmimick/HSPanasonicSDK/master/HSPanasonic.SDK_0.0.1.xml

  (3) Load this into HS in the HSLIB namespace:
      HSLIB>do $system.OBJ.Load("<path>/HSPanasonic.SDK_1.0.0.xml,"ck")

  (4) (Optional) Figure out how many ScanPoints you want. For each ScanPoint you'll 
      need a name and a port number for the EndPointService to run. Write these
      down, for example:
        WesternViewPractice, 8765
        MountainViewOrthopedics, 8778
        UptownClinics, 10112
	  --OR-- you can just install the provided "Demo" system which will install 3
      scan points: ScanPoint1:8765, ScanPoint2:8766 and, ScanPoint3:8767

  (6) Run the intallation tool from the HSLIB namespace:
      HSLIB>do ##class(HSPanasonic.Setup).InstallDemo()
      and follow the prompts. 

  (7) Run ##class(HSPanasonic.Setup).Help() to see additional installation and 
      uninstallation utilities. 


