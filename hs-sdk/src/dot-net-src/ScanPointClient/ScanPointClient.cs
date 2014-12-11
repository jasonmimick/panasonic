using System.Net;
using System.Linq;
using System.Collections.Generic;
using System.IO;
using System.Configuration;
using System;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;

namespace HSPanasonic.ScanPoint
{

	public class ScanPointClient
	{

		public static void Main(string[] args) 
		{
            try
            {
                string mySetting = System.Configuration.ConfigurationManager.AppSettings["foo"];
                System.Console.WriteLine("mySetting=" + mySetting);
                var spc = new ScanPointClient("http://192.168.1.130:20187", "ScanPointTest1", "password");
                spc.MetaSubjectSearch();

                var query = new Dictionary<string, string>();
                query.Add("LastName", "Zimmerman");
                var results = spc.SubjectSearch(query);
                results.ToList().ForEach(r => dumpDict(r));

                var submitDocRequest = new SubmitDocumentRequest();
                submitDocRequest.Subject = results.First();
                submitDocRequest.Name = "Foo";
                submitDocRequest.Type = "txt";
                var fake_document = "Hello World!\nFoo that bar!\n";
                submitDocRequest.Body = new byte[fake_document.Length];
                var encoding = new System.Text.UTF8Encoding();
                var doc_bytes = encoding.GetBytes(fake_document);
                submitDocRequest.Body = doc_bytes;
                submitDocRequest.Size = doc_bytes.Length;
                submitDocRequest.Timestamp = DateTime.Now;
                var response = spc.SubmitDocument(submitDocRequest);

            }
            catch (Exception e)
            {
                System.Console.WriteLine(e.Message);
            }
            System.Console.ReadLine();
		}

		public const string HEADER_APIKEY = "x-healthshare-apikey";
        public const string HEADER_ENDPOINT = "x-healthshare-endpoint";
		public const string HEADER_USERNAME = "x-healthshare-username";
		public const string HEADER_PASSWORD = "x-healthshare-password";
        public const string HEADER_SEARCHFIELDS = "x-healthshare-searchfields";
        public const string HEADER_RESULTDISPLAYFIELDS = "x-healthshare-resultdisplayfields";
        public const string HEADER_DOCUMENTTYPES = "x-healthshare-docTypes";
		public const string URL_META_SUBJECT_SEARCH = "/meta/subjectSearch";
		public const string URL_SUBJECT_SEARCH = "/subjectSearch";
		public const string URL_SUBMIT_DOCUMENT = "/submitDocument";

		public ScanPointClient(string registryUrl, string username, string password,bool validateSSLCert = false) 
		{
			this.Endpoint = "";
			this.RegistryUrl = registryUrl;
			this.username = username;
			this.password = password;
			this.apikey = null;
            this.ValidateSSLCert = validateSSLCert;
			register();
		}

		private string username = null;
		private string password = null;
		private bool initialized = false;
		private string apikey;

		public string RegistryUrl { get; private set; } 
		public string Endpoint { get; private set; }
        public string SearchFields { get; private set; }
        public string ResultDisplayFields { get; private set; }
        public string DocumentTypes { get; private set; }
        public bool ValidateSSLCert { get; private set; }

        public static string SSLError { get; private set; }
		private void addApiKey(IDictionary<string,string> headers)
		{
			if ( headers.ContainsKey( HEADER_APIKEY ) ) 
			{
				headers.Remove( HEADER_APIKEY ) ;
			}
			headers.Add( HEADER_APIKEY , this.apikey );
		}
		private void addUserPass(IDictionary<string,string> headers)
		{
			if ( headers.ContainsKey( HEADER_USERNAME ) ) 
			{
				headers.Remove( HEADER_USERNAME ) ;
			}
			headers.Add( HEADER_USERNAME, this.username );	
			if ( headers.ContainsKey( HEADER_PASSWORD ) ) 
			{
				headers.Remove( HEADER_PASSWORD ) ;
			}
			headers.Add( HEADER_PASSWORD, this.password );
		}

		private bool register() 
		{
			var headers = new Dictionary<string,string>();
			headers.Add("content-length","0");
			addUserPass(headers);
			var response = SendHTTP(this.RegistryUrl,"POST",headers); 	
			dumpDict(response);
            if (!response.ContainsKey(HEADER_APIKEY))
            {
                throw new Exception("Unable to reigster");
                // TODO - we need to log the details of the error
                // or do we, they should just loginto healthshare and check
            }
            if (!response.ContainsKey(HEADER_ENDPOINT))
            {
                throw new Exception("Unable to reigster");
                // TODO - we need to log the details of the error
                // or do we, they should just loginto healthshare and check
            }

            this.apikey = response[HEADER_APIKEY];
            this.Endpoint = response[HEADER_ENDPOINT];
            this.MetaSubjectSearch();
            this.initialized = true;
			return true;
		}

		private void MetaSubjectSearch()
		{
            var headers = new Dictionary<string, string>();
            headers.Add("content-length", "0");
            addApiKey(headers);
            var response = SendHTTP(this.Endpoint+URL_META_SUBJECT_SEARCH, "POST", headers);
            dumpDict(response);
            this.SearchFields = response[HEADER_SEARCHFIELDS];
            this.ResultDisplayFields = response[HEADER_RESULTDISPLAYFIELDS];
            this.DocumentTypes = response[HEADER_DOCUMENTTYPES];
        }


        public IEnumerable<Dictionary<string, string>> SubjectSearch(IDictionary<string, string> searchFields)
		{
            if (!this.initialized)
            {
                throw new Exception("Client not initalized");
            }
            var results = new List<Dictionary<string, string>>();
            var headers = new Dictionary<string, string>();
            var query = JsonConvert.SerializeObject(searchFields);
            addApiKey(headers);
            var response = SendHTTP(this.Endpoint + URL_SUBJECT_SEARCH, "POST", headers, query);
            //dumpDict(response);
            var body = JsonConvert.DeserializeObject<JObject>(response["body"]);
            var _results = body.GetValue("Results");
            foreach (var row in _results)
            {
                var result = new Dictionary<string, string>();
                foreach (var property in row.Values<JProperty>())
                {
                    if (property.Name.StartsWith("_"))
                    {
                        continue;
                    }
                    result.Add(property.Name, property.Value.ToString());
                    
                }
                results.Add(result);
            }
            return results;

		}

        
		public IDictionary<string,string> SubmitDocument(SubmitDocumentRequest request)
		{
            var result = new Dictionary<string, string>();
            var json = JsonConvert.SerializeObject(request);
            if (!this.initialized)
            {
                throw new Exception("Client not initalized");
            }
            var results = new List<Dictionary<string, string>>();
            var headers = new Dictionary<string, string>();
            addApiKey(headers);
            var response = SendHTTP(this.Endpoint + URL_SUBMIT_DOCUMENT, "POST", headers, json);
            dumpDict(response);
            var body = (JObject)JsonConvert.DeserializeObject<JArray>(response["body"])[0];

            foreach (var key in (new List<string>() { "Status", "SessionID" }))
            {
                result.Add(key, body.GetValue(key).ToString());
            }
                //foreach( var property in body) 
            //{
            //    result.Add(property.Name
            return result;
		}
		

        private static void dumpDict(IDictionary<string, string> dictionary)
        {
            foreach (var key in dictionary.Keys)
            {
                System.Console.WriteLine(key + "=" + dictionary[key]);
            }
        }
        private IDictionary<string, string> SendHTTP(string url, string method, IDictionary<string, string> headers)
        {
            return SendHTTP(url, method, headers, string.Empty);
        }
        public bool CheckSSLCert(object sender, System.Security.Cryptography.X509Certificates.X509Certificate certification,
                    System.Security.Cryptography.X509Certificates.X509Chain chain,
                    System.Net.Security.SslPolicyErrors sslPolicyErrors)
        {
            // Log this --
            if ( this.ValidateSSLCert && (!sslPolicyErrors.Equals(System.Net.Security.SslPolicyErrors.None) ))
            {
                SSLError = sslPolicyErrors.ToString();
                return false;
            }
            return true;
        }
        private IDictionary<string,string> SendHTTP(string url,string method,IDictionary<string,string> headers,string body)
		{
            ServicePointManager.ServerCertificateValidationCallback = new System.Net.Security.RemoteCertificateValidationCallback(CheckSSLCert);
		
            var request = (HttpWebRequest)WebRequest.Create(url);
            request.KeepAlive = true;
			request.Method = method;
			if ( headers.ContainsKey("content-length") ) 
			{
				request.ContentLength = System.Convert.ToInt32( headers["content-length"] );
				headers.Remove("content-length");
			}
			if ( headers.ContainsKey("content-type") ) 
			{
				request.ContentType = headers["content-type"];
				headers.Remove("content-type");
			}
			foreach(string key in headers.Keys ) 
			{
				request.Headers.Add( key, headers[key] );
			}
            if (body != string.Empty)
            {
                var encoding = new System.Text.UTF8Encoding();
                var data = encoding.GetBytes(body);
                request.ContentLength = data.Length;
                request.ContentType = "application/json";

                request.GetRequestStream().Write(data, 0, data.Length);

            }
			System.Console.WriteLine( request.ToString() );
            var result = new Dictionary<string, string>();

         
                using (WebResponse response = request.GetResponse())
                {
                    foreach (var key in response.Headers.Keys)
                    {
                        var value = response.Headers[key.ToString()];
                        result.Add(key.ToString(), value);
                    }
                    using (StreamReader rd = new StreamReader(response.GetResponseStream()))
                    {
                        result.Add("body", rd.ReadToEnd());
                    }
                }
           
            
			return result;
		} 
	}


}
