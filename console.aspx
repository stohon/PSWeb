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
        <div id="results">
            <div id="standardResults" v-if="viewIndex == 0">
                <div v-for="(e, i) in psresults.Errors" class="errorRow">
                    {{e.Category}}<br/>{{e.Message}}
                </div>
                <div v-for="(d, i) in psresults.DataObjects" class="dataRow">
                    <span style='color:yellow;'>var: </span>{{d.Name}}<br/>
                    {{ d.Data }}
                </div>
            </div>
            <div id="jsonResults" v-if="viewIndex == 1">{{psresults}}</div>
        </div>
    </div>
</body>
</html>