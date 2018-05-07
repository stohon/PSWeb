
add-type -Language CSharpVersion3 -TypeDefinition @"
    public class CPUAndMemoryDetail { public string ServerName { get; set; } 
                                      public string FreePhysicalMemory     { get; set; } 
                                      public string TotalVisibleMemorySize { get; set; } 
                                      public string LoadPercentage         { get; set; } }
"@

add-type -Language CSharpVersion3 -TypeDefinition @"
    public class DriveDetail { public string ServerName { get; set; } 
                               public string DriveID    { get; set; } 
                               public string TotalSize  { get; set; } 
                               public string FreeSpace  { get; set; } }
"@

add-type -Language CSharpVersion3 -TypeDefinition @"
    public class IISDetail { public string ServerName  { get; set; } 
                             public string AppPoolName { get; set; } 
                             public string Status      { get; set; } }
"@

add-type -Language CSharpVersion3 -TypeDefinition @"
    public class CertDetail { public string ServerName   { get; set; }
                              public string FriendlyName { get; set; } 
                              public string NotBefore    { get; set; } 
                              public string NotAfter     { get; set; } }
"@

add-type -Language CSharpVersion3 -TypeDefinition @"
    public class IISWorkItem { public string ServerName  { get; set; }
                               public string HostName    { get; set; } 
                               public string TimeElapsed { get; set; } 
                               public string URL         { get; set; } }
"@