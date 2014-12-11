using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace HSPanasonic.ScanPoint
{
    public class SubmitDocumentRequest
    {
        public DateTime Timestamp;
        public IDictionary<string,string> Subject;
        public string User;
        public string Name;
        public string Type;
        public long Size;
        public byte[] Body;
    }
}
