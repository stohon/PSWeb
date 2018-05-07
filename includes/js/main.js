var page = {
    load: function () {
        this.vue = new Vue({
            el: '#app',
            data: { 
                psscript: "",        psparams: "",      isExecuting: false,     psresults: "", 
                foldersFiles: null,  folderIndex: 0,    fileIndex: 0,           viewIndex: 0,
                lastMouseY: 0,       resultsOffset: 50, preloadpsscript: "",    isExecutable: false },
            watch: { 
                psscript: function() { this.afterLoadScript(); }, 
                folderIndex: function() { this.setDefaultFileIndex(); this.loadScript(); },
                fileIndex: function()   { this.loadScript(); },
                foldersFiles: function() { this.setDefaultFolderIndex(); } },
            computed: { 
                _ok()            { return (this.foldersFiles == null) },
                _views()         { return ["Standard", "JSON"]; },
                _folders()       { return (this._ok) ? [] : this.foldersFiles; },
                _psscripts ()    { return (this._ok) ? [] : this._folders[this.folderIndex].Scripts; },
                _curFolderName() { return (this._ok) ? "" : this._folders[this.folderIndex].Name; },
                _curFileName()   { return (this._ok) ? "" : this._psscripts[this.fileIndex]; },
                _queryStr  ()    { return '&category=' + this._curFolderName + '&script=' + this._curFileName; }
            },
            methods: {
                initForm() { 
                    this.bodyResize(); 
                    axios.get('./service.aspx?name=getFiles').then(r => this.foldersFiles = r.data); 
                    this.loadScript(); 
                },
                setDefaultFolderIndex() {
                    for (ind = 0; ind < this.foldersFiles.length; ind++) {
                        if (this.foldersFiles[ind].Name == "PowerShell Console")
                            this.folderIndex = ind;
                    }
                },
                setDefaultFileIndex() {
                    var fileIndex = this.foldersFiles[this.folderIndex].Scripts.indexOf("Home.html");
                    this.fileIndex = (fileIndex < 0) ? 0 : fileIndex;
                },
                getWinHeight()          { return ((window.innerHeight - 105 ) / 2);    },
                getElement(name)        { return document.getElementById(name); },
                setHeight(name, offset) { this.getElement(name).style.height = (this.getWinHeight() + offset) + "px"; },
                setWidth(name, offset)  { this.getElement(name).style.width  = (window.innerWidth + offset) + "px"; },
                loadScript() {
                    axios.get('./service.aspx?name=getFile' + this._queryStr).then(r => this.psscript = r.data.Source );
                    if (this._curFileName.indexOf(".ps1") > 0) this.isExecutable = true; else this.isExecutable = false;
                },
                afterLoadScript () {
                    var scriptText = this.psscript;
                    if (this.psscript.indexOf('write-in @"') > 0) {
                        this.psparams = this.psscript.substring(this.psscript.indexOf('write-in @"') + 11, 
                                                                this.psscript.indexOf('"@'));
                        scriptText = this.psscript.replace('' + this.psparams + '',this.createParameterList());
                    }
                    
                    document.getElementById("script").innerHTML = "<pre class=''><code>" + scriptText + "</code></pre>";
                    
                    if (this._curFileName.indexOf(".ps1") > 0) {
                        hljs.initHighlighting.called = false; 
                        hljs.initHighlighting();
                    }
                },
                createParameterList () {
                    try {
                        var paramObj = JSON.parse(this.psparams);
                        var paramStr = '\r{';
                        for (prop in paramObj) {
                            var val = JSON.stringify(paramObj[prop]);
                            paramStr += "<div class='paramLine'>$" + prop + ": " + 
                                        "<span class='param' contentEditable='true' paramName='" + prop + "'>" + val + 
                                        "</span></div>";
                        }
                        return paramStr + '}\r';
                    } catch(err) {
                        return "<b>Error building parameter list.\r" + err + "\r" + this.psparams + 
                                "end error message.</b>";
                    }
                },
                executeScript() {
                    parameterSpans = document.getElementsByClassName("param");
                    var postJSON = "{";
                    var paramDelimitor = "";
                    for (i = 0; i < parameterSpans.length; i++) {
                        postJSON += paramDelimitor + '"' + parameterSpans[i].getAttribute("paramName") + '":' + 
                                    parameterSpans[i].innerText;
                        paramDelimitor = ",";
                    }
                    postJSON += "}";

                    this.isExecuting = true;
                    axios.post('./service.aspx?name=runFile' + this._queryStr + "&postJSON=" + postJSON)
                         .then(r => this.psresults = r.data)
                         .then(() => { page.vue.isExecuting = false; });
                },
                bodyResize() {
                     this.setHeight("script",-this.resultsOffset); this.setHeight("results",this.resultsOffset); this.setWidth("results",-20);
                },
                dragStart(event) { this.lastMouseY = event.clientY; },
                dragEnd(event) {
                    this.resultsOffset = this.resultsOffset + (this.lastMouseY - event.clientY);
                    this.bodyResize();
                }
            },
            created() { this.initForm(); }
        });
    }
}