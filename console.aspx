<!DOCTYPE html>
<html>
<head>
    <link rel="stylesheet" href="./includes/css/xcode.css">
    <script src="./includes/js/highlight.pack.js"></script>
    <link rel="stylesheet" href="./includes/css/main.css">
    <script src="./includes/js/axios.min.js"></script>
    <script src="./includes/js/vue.js"></script> 
    <script src="./includes/js/main.js"></script>
</head>
<body onload="page.load()" onresize="page.vue.bodyResize();" ondragover="event.preventDefault();">
    <div id="app">
        <div class="toolbar" draggable="false">
            <div class="htext lf p8"><b>POWERSHELL CONSOLE</b></div>
            <div class="htext rf p6">
                <select id="ddlScripts" v-model="fileIndex" class="sel300">
                    <option v-for="(s, i) in _psscripts" v-bind:value="i">{{s}}</option>
                </select>
            </div>
            <div class="htext rf p8">File:</div>
            <div class="htext rf p6">
                <select id="ddlCategory" v-model="folderIndex" class="sel300">
                    <option v-for="(c, i) in _folders" v-bind:value="i">{{c.Name}}</option>
                </select>
            </div>
            <div class="htext rf p8">Folder:</div>
        </div>
        <div class="display"><div id="script"></div></div>
        <div class="toolbar" draggable="true" ondragstart="page.vue.dragStart(event)" ondragend="page.vue.dragEnd(event)">
            <div class="htext lf p8"><b>RESULTS</b></div>
            <div class="htext lf p8"><b v-if="isExecuting" class="lblExe">EXECUTING SCRIPT ...</b></div>
            <div class="htext rf p6">
                <select id="ddlView" v-model="viewIndex" class="sel200">
                    <option v-for="(v, i) in _views" v-bind:value="i">{{v}}</option>
                </select>
            </div>
            <div class="htext rf p8">View:</div>
            <div v-if="isExecutable" class="htext rf p8">
                <b id="btnExe" onclick="page.vue.executeScript()"><span class="innerRun"><span class="playButton">4</span>Run Script</span></b>
            </div>
        </div>
        <div id="results" v-bind:class="_resultsClass">
            <div v-if="viewIndex == 0">
                <div v-for="(e, i) in psresults.Errors" class="errorRow">
                    {{e.Category}}<br/>{{e.Message}}
                </div>
                <div v-for="(d, i) in psresults.DataObjects" class="dataRow">
                    <div style="padding-bottom:4px;"><span style='color:yellow;'>variable:</span> <b>{{d.Name}}</b></div>
                    <pre class="psPretty">{{d.OutString}}</pre>
                </div>
            </div>
            <div v-if="viewIndex == 1">
                <div v-for="(e, i) in psresults.Errors" class="errorRow">
                    {{e.Category}}<br/>{{e.Message}}
                </div>
                <div v-for="(d, i) in psresults.DataObjects" class="dataRow">
                    <div style="padding-bottom:4px;"><span style='color:yellow;'>variable:</span> <b>{{d.Name}}</b></div>
                    <pre class="psPretty" v-html="d.OutString"></pre>
                </div>
            </div>
            <div id="jsonResults" v-if="viewIndex == 2"><pre class="jsonPretty">{{psresults}}</pre></div>
            <div id="restResults" v-if="viewIndex == 3">
                <br/><b>The previous script was run using the following api call:</b><br/><br/>
                <a target="_blank" v-bind:href="RESTUrl" style="color:darkkhaki;">{{RESTUrl}}</a><br/><br/>
                <b>The parameter payload is encoding in base64 using window.btoa() in javascript. The parameter json for this request is:</b><br/><br/>
                <span style="color:darkkhaki;">{{psparams}}</span><br/><br/>
                <b>To create this request from your own page, encode the parameters query string variable like:</b><br/><br/>
                <span style="color:darkkhaki">{rest url}?{query string}&jsonParams64 = window.btoa(jsonString);</span>
            </div>
        </div>
    </div>
</body>
</html>