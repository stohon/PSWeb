using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.IO;
using System.Linq;
using System.Management.Automation;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;

namespace PowerShellWebConsole
{
    // RESPONSE TYPES
    public class OutError                { public string Category; public string Message; }
    public class OutDataObject           { public string Name; public dynamic Data; }
	public class OutDataProperties       { public string Name; public string Value; public string ValueType; }
	public class OutResponse             { public List<OutError> Errors = new List<OutError>(); public List<OutDataObject> DataObjects = new List<OutDataObject>(); }
    public class File_OutResponse        { public string Source; }
    public class Folder_OutResponse { public string Name; public List<string> Scripts = new List<string>(); }

    public partial class Service_aspx : System.Web.UI.Page
    {
        public string PowerShellRootFolder { get { return Server.MapPath("~") + @"\powershell\"; }}

        protected void Page_Load(object sender, EventArgs e) {
            string serviceName = Request.QueryString["name"];
            switch (serviceName) {
                case "getFile":
                    GetFile();
                break;
                case "getFiles":
                    GetFiles();
                break;
                case "runFile":
                    RunFile();
                break;
            }
        }

        public bool DoIHaveRights() {
            return true;
        }

        public void RunFile() {
            string psParams = @"param($postData,$outputFormat);";
            OutResponse outResp = new OutResponse();

            if (!DoIHaveRights()) { 
                outResp.Errors.Add(new OutError() { Category="Access Denied", Message="You do not have rights to run this script." }); 
            }
            else {
                using (PowerShell PowerShellInstance = PowerShell.Create())
                {
                    string categoryFolder = Request.QueryString["category"];
                    string scriptName = Request.QueryString["script"];
                    
                    PowerShellInstance.AddScript(psParams + File.ReadAllText(Server.MapPath("~") + @"\powershell\" + categoryFolder + @"\" + scriptName));
                    PowerShellInstance.AddParameter("outputFormat", "json");
                    PowerShellInstance.AddParameter("postData", Request.QueryString["postJSON"].ToString());

                    try 
                    {
                        Collection<PSObject> PSOutput = PowerShellInstance.Invoke();

                        if (PowerShellInstance.Streams.Error.Count > 0)
                        {
                            foreach(System.Management.Automation.ErrorRecord error in PowerShellInstance.Streams.Error) 
                            {
                                if (error.CategoryInfo.ToString().Split(',')[0] != "NotSpecified: (:) []") {
                                    outResp.Errors.Add(new OutError() { Category = error.CategoryInfo.ToString(), Message = error.ToString() } );
                                }	
                            }
                        }

                        foreach (PSObject outputItem in PSOutput)
                        {
                            if (outputItem != null && outputItem.ToString() == "OutputToWeb") {
                                outResp.DataObjects.Add(new OutDataObject() {
                                    Name = outputItem.Properties["Name"].Value.ToString(),
                                    Data = JValue.Parse (outputItem.Properties["Value"] == null ? "" : outputItem.Properties["Value"].Value.ToString())
                                });
                            }
                        }
                    }
                    catch (System.Exception exp) 
                    {
                        outResp.Errors.Add(new OutError() { Category = exp.Source, Message = exp.Message } );
                    }
                }  
            } 
            
            Response.Write(JsonConvert.SerializeObject(outResp,Newtonsoft.Json.Formatting.None));
        }

        public void GetFile() {
            File_OutResponse resp = new File_OutResponse();
            
            if (!DoIHaveRights()) { 
                resp.Source = "Your account does not have the rights to view these files. Please contact the administrator."; 
            } 
            else { 
                try {
                    string categoryFolder = Request.QueryString["category"];
                    string scriptName = Request.QueryString["script"];

                    resp.Source = File.ReadAllText(this.PowerShellRootFolder + categoryFolder + @"\" + scriptName);
                } 
                catch (System.Exception exp) {
                    resp.Source = "Error: could not load script on server. " + exp.Message;
                }
            }

            Response.Write(JsonConvert.SerializeObject(resp,Newtonsoft.Json.Formatting.None));
        }

        public void GetFiles() {
            List<Folder_OutResponse> folders = new List<Folder_OutResponse>();

            if (!DoIHaveRights()) { 
                folders.Add(new Folder_OutResponse() { Name="Access Denied" }); 
            }
            else {
                foreach(string dirPath in Directory.GetDirectories(this.PowerShellRootFolder)) {
                    Folder_OutResponse newFolder = new Folder_OutResponse() { Name=dirPath.Replace(this.PowerShellRootFolder,"") };
                    foreach(string fileName in Directory.GetFiles(dirPath)) {
                        newFolder.Scripts.Add(fileName.Replace(this.PowerShellRootFolder + newFolder.Name + @"\",""));
                    }
                    folders.Add(newFolder);
                }
            }
            
            Response.Write(JsonConvert.SerializeObject(folders,Newtonsoft.Json.Formatting.None));
        }
    }
}