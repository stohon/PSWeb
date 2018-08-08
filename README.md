# PowerShellWebConsole

Run PowerShell scripts in a web browser. View the full script to run, modify parameter values only. Run locally on the server or in a browser without making any modifications to the script. View results in many different formats. 

See my blog at: http://stohon.com/2018/05/13/psweb-powershell-web-console/

<img src="http://stohon.com/wp-content/uploads/2018/05/PSConsole-768x432.png"></img>

Quick Setup: 
1. Ensure IIS is setup with windows authenitcation. This is not required, but strongly encouraged.  
2. Create an application within IIS. 
3. Copy all files into the root directory of the new IIS application.
4. Disable Anonymous Authentication and enable Windows Authentication on IIS application. Application will work without Windows authentication but will be open to all. 
5. Update UsernameList in web.config. If left blank the application will ignore this setting and rely on security settings in IIS for access. This setting is a comma delimited list of domain/username. Do not leave blank spaces.  
6. Create a new directory (PSWebShare) to store all the common files, logs, powershell scripts and additional configuration files. See the repo PSWebShare. Download the PSWebShare repo to this directory.
7. Once the directory is created and files downloaded, update the variable "PSConsoleShareLocation" in the web.config file with the directory path. This path can be a local path, c:\path or a share location \\machine\path. You can run PSWeb on mulitple servers and have all web servers point to the same location using a share location.
8. Create an environment variable to the new share path. This step is optional. Creating an environment variable allows you to write PowerShell includes within your scripts without hard coding the path to ps1 files. Command line: setx PSConsole "\\mysharelocation". 
9. Update web.config file variable: "PSConsoleShareName" with the name of the environment variable name if one is created. Running a PowerShell script from a command line or ISE the environment variable is interpreted correctly. However, running a script from this web application, environment variables are not interpreted correctly, the reference is instead replaced before execution with the actual path location set in the web.config. The application looks for $env:<EnvironmentVariable> within all scripts and replaces them with actual paths. 
10. Set LoggingEnabled to true or false. The log location is yourshare\logs.
11. Optional: you can create a virtual directory under the web application that points to the share location. This will allow you to reference log files or other output files from the application output window results.  

Enjoy.
