# PowerShellWebConsole

Run PowerShell scripts in a web browser. View the full script to be run, modify parameter values only. Run locally on the server or in a browser without making any modifications to the script. 

View the results in the web console or via RESTful api and JSON.

Quick Setup: 
1. Ensure IIS is setup with windows authenitcation. 
2. Create an application under your root website port 80 called PS. 
3. Copy all files into the PS directory.
4. Create an environment variable called PSConsole, from command line: setx PSConsole "--path of PS directory--". Environment variable PSConsole will be used in PowerShell scripts to reference include files. If running a script locally PowerShell will interpret the variable correctly. However, running the script through the web app the variable is not interpreted correctly in PowerShell. Instead the web application replaces all occurrences of the variable with the working path of the web app before executing. The web.config file contains a reference to the environment variable name should you have a need to change it. 
5. Set the log path in web.config or create a \logs directory under PS folder (default location is \logs under app directory if web.config has no path set). Depending on your environment you may have to change the application pool identity to have the neccessary rights to write logs to your local drive.
6. Disable Anonymous Authentication and enable Windows Authentication on PS application. Application will work without Windows authentication, but will be open to all. 
7. Update UsernameList in web.config. If blank then application will ignore this setting and rely on security settings in IIS for access.  
8. View at http://localhost/PS

Visit my blog at http://www.stohon.com

Enjoy.