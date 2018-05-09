. "$env:PSConsole\powershell\WebUtil.ps1"

# PARAMETERS CAN BE DEFINED AS NUMBERS, STRINGS OR AN ARRAY OF NUMBER AND STRINGS
write-in @"
{
    "numberIn": 0,
    "stringIn": "test",
    "narrayIn": [1,2,3,4,5],
    "sarrayIn": ["str1","str2","str3"]
}
"@

# THE PARAMETERS ARE PASSED INTO POWERSHELL USING VARIABLE: $postData
# NORMALLY THIS VARIABLE WOULD NOT BE USED. EACH PROPERTY AT THE ROOT LEVEL 
# OF THIS OBJECT IS AUTOMATICALLY TURNED INTO A POWERSHELL VARIABLE AT RUNTIME
write-out $postData "postData1"

# WRITE VARIABLES OUT TO THE WEB PAGE, NAMING THE OUTPUT VARIABLE IS OPTIONAL
write-out $numberIn "numberIn1"
write-out $stringIn "stringIn1"
write-out $narrayIn "narrayIn1"
write-out $sarrayIn "sarrayIn1"

write-out-json $numberIn "numberIn2 json only"
write-out-outstring $stringIn "stringIn2 outstring only"
write-out-json $narrayIn "narrayIn2 json only"
write-out-outstring $sarrayIn "sarrayIn2 outstring only"
