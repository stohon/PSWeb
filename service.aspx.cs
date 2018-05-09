using System;
using System.Configuration;
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
    public class OutError           { public string Category; public string Message; }
    public class OutDataObject      { public string Name; public dynamic Data; public string OutString; }
	public class OutDataProperties  { public string Name; public string Value; public string ValueType; }
	public class OutResponse        { public List<OutError> Errors = new List<OutError>(); public List<OutDataObject> DataObjects = new List<OutDataObject>(); }
    public class File_OutResponse   { public string Source; }
    public class Folder_OutResponse { public string Name; public List<string> Scripts = new List<string>(); }
    public class Save_OutResponse   { public string FolderName; public string FileName; public string Username; public string Parameters; public string Results; }

    public partial class Service_aspx : System.Web.UI.Page
    {
        // Gets the root path of where the scripts are located
        public string PowerShellConsoleRootFolder { get { return Server.MapPath("~"); } }
        public string PowerShellRootFolder { get { return PowerShellConsoleRootFolder + @"\powershell\"; }}
        public string AllowUsernameList { get { return ConfigurationManager.AppSettings["AllowUsernameList"]; } }
        public string LogFolder { 
            get { 
                    if (String.IsNullOrEmpty(ConfigurationManager.AppSettings["LogPath"])) {
                        return PowerShellConsoleRootFolder + @"\Logs\";
                    }
                    return ConfigurationManager.AppSettings["LogPath"] + @"\"; 
                }
        }
        public string Username { get { return User.Identity.Name; } }
        public string ReplaceAppRootEnvVarInPSScriptWithActual { get { return ConfigurationManager.AppSettings["ReplaceAppRootEnvVarInPSScriptWithActual"]; } }

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
            if (String.IsNullOrEmpty(AllowUsernameList)) { 
                return true; 
            } else {
                string[] accounts = AllowUsernameList.ToLower().Split(',');
                foreach (string account in accounts) { 
                    if (account.ToLower() == this.Username.ToLower()) return true;
                }
            }
            return false;
        }

        public void RunFile() {
            string psParams = @"param($postData,$outputFormat);";
            OutResponse outResp = new OutResponse();
            Save_OutResponse saveResult = new Save_OutResponse() { Username=this.Username };

            try 
            {
                if (!DoIHaveRights()) { 
                    outResp.Errors.Add(new OutError() { Category="Access Denied", Message="Your account does not have rights to run this script." }); 
                }
                else {
                    using (PowerShell PowerShellInstance = PowerShell.Create())
                    {
                        string folderName = Request.QueryString["category"];
                        string fileName = Request.QueryString["script"];

                        saveResult.FolderName = folderName;
                        saveResult.FileName = fileName;
                        
                        string fileText = File.ReadAllText(this.PowerShellRootFolder + folderName + @"\" + fileName);
                        if (!String.IsNullOrEmpty(ReplaceAppRootEnvVarInPSScriptWithActual)) {
                            fileText = fileText.Replace(ReplaceAppRootEnvVarInPSScriptWithActual, PowerShellConsoleRootFolder);
                        }
                        PowerShellInstance.AddScript(psParams + fileText);
                        PowerShellInstance.AddParameter("outputFormat", "json");
                        string jsonParams64 = Request.QueryString["jsonParams64"].ToString();
                        byte[] arrParams = System.Convert.FromBase64String(jsonParams64);
                        string jsonParams = System.Text.Encoding.UTF8.GetString(arrParams);
                        PowerShellInstance.AddParameter("postData", jsonParams);

                        saveResult.Parameters = jsonParams;

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
                                    Data = JValue.Parse (outputItem.Properties["Value"] == null ? "" : outputItem.Properties["Value"].Value.ToString()),
                                    OutString = outputItem.Properties["OutString"].Value.ToString()
                                });
                            }
                        }
                    }  
                } 
                
                // SAVE RESP OBJECT
                saveResult.Results = JsonConvert.SerializeObject(outResp,Newtonsoft.Json.Formatting.None);
                using (StreamWriter sw = File.CreateText(this.LogFolder + saveResult.FolderName.Replace(" ", "_") + " - " + 
                                                                          saveResult.FileName.Replace(" ", "_") + " - " + 
                                                                          DateTime.Now.ToString("yyyy.MM.dd.HH.mm.ss.ff") + ".log")) {
                    sw.WriteLine(JsonConvert.SerializeObject(saveResult,Newtonsoft.Json.Formatting.None));
                }
            }
            catch (System.Exception exp) 
            {
                outResp.Errors.Add(new OutError() { Category = exp.Source, Message = exp.Message } );
            }

            string responseJSON = JsonConvert.SerializeObject(outResp,Newtonsoft.Json.Formatting.None);
            Response.Write(responseJSON);
        }

        public void GetFile() {
            File_OutResponse resp = new File_OutResponse();
            
            if (!DoIHaveRights()) { 
                resp.Source = "Your account " + this.Username + " has been denied access. Please contact the administrator."; 
            } 
            else { 
                try {
                    string folderName = Request.QueryString["category"];
                    string fileName = Request.QueryString["script"];

                    resp.Source = File.ReadAllText(this.PowerShellRootFolder + folderName + @"\" + fileName);
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