.TEST.init.t_mocks:((`.lib.cfg.moduleLocations;());(`.lib.p.getenv;{"a/path:/b/path:c/pa/th:d"});(`.lib.cfg.envVar;`someName));
.TEST.init.ok:{[]
  .lib.init[];
  .qtb.assert.matches[`$(":a/path";":/b/path";":c/pa/th";":d");.lib.cfg.moduleLocations];
  .qtb.assert.callog `funcname`args!(`.lib.p.getenv;`someName);
  };


.TEST.import.t_mocks:(
  (`.lib.moduleLoaded;{0b});
  (`.lib.cfg.moduleLocations;`:a`:bb`:cc/dd);
  (`.lib.cfg.initFile;`inifile);
  (`.q.key;{$[x ~ `:cc/dd/mymodule/inifile;`:cc/dd/inifile;()]});
  (`.lib.STATE.modules;([moduleName:`$()] srcPath:`$(); state:`$(); files:()));
  (`.q.system;{.qtb.assert.matches[`loading;.lib.STATE.modules[`mymodule;`state]];});
  (`.lib.p.println;::));

.TEST.import.success:{[]
  .lib.import `mymodule;
  .qtb.assert.matches[1!enlist `moduleName`srcPath`state`files!(`mymodule;`:cc/dd;`loaded;());.lib.STATE.modules];
  exp_log:([]
    funcname:`.lib.moduleLoaded`.q.key`.q.key`.q.key`.q.system;
    args:(`mymodule;`:a/mymodule/inifile;`:bb/mymodule/inifile;`:cc/dd/mymodule/inifile;"l cc/dd/mymodule/inifile"));
  .qtb.assert.callog exp_log;
  };

.TEST.import.failure:{[]
  .qtb.mock[`.q.system;{'"nice try!"}];
  .qtb.assert.throws[(.lib.import;(),`mymodule);"Failed to load module mymodule: nice try!"];
  exp_log:([]
    funcname:`.lib.moduleLoaded`.q.key`.q.key`.q.key`.q.system`.lib.p.println;
    args:(`mymodule;`:a/mymodule/inifile;`:bb/mymodule/inifile;`:cc/dd/mymodule/inifile;"l cc/dd/mymodule/inifile";"Failed to load module mymodule: nice try!"));
  .qtb.assert.callog exp_log;
  .qtb.assert.matches[([moduleName:`$()] srcPath:`$(); state:`$(); files:());.lib.STATE.modules];
  };

.TEST.import.notfound:{[] .qtb.assert.throws[(.lib.import;(),`somemod);"module not found: somemod"]; };

.TEST.import.no_reload:{[]
  .qtb.mock[`.lib.moduleLoaded;{1b}];
  .lib.import`mymodule;
  .qtb.assert.callog `funcname`args!`.lib.moduleLoaded`mymodule;
  };

.TEST.reload.t_mocks:(
  (`.lib.moduleLoaded;{1b});
  (`.lib.STATE.modules;1!enlist `moduleName`srcPath`state`files!(`mymodule;`:here;`loaded;()));
  (`.lib.p.loadModule;{(x;y);});
  (`.lib.cfg.initFile;`inifile));
    
.TEST.reload.success:{[]
  .lib.reload`mymodule;
  .qtb.assert.matches[1!enlist `moduleName`srcPath`state`files!(`mymodule;`:here;`reloading;());.lib.STATE.modules];
  exp_log:([]
    funcname:`.lib.moduleLoaded`.lib.p.loadModule;
    args:(`mymodule;(`mymodule;`:here/mymodule/inifile)));
  .qtb.assert.callog exp_log;
  };

.TEST.reload.failure:{[]
  .qtb.mock[`.lib.p.loadModule;{[x;y] '"nope"}];
  .qtb.assert.throws[(.lib.reload;(),`mymodule);"Failed to load module mymodule: nope"];
  .qtb.assert.matches[1!enlist `moduleName`srcPath`state`files!(`mymodule;`:here;`loaded;());.lib.STATE.modules];
  exp_log:([]
    funcname:`.lib.moduleLoaded`.lib.p.loadModule;
    args:(`mymodule;(`mymodule;`:here/mymodule/inifile)));
  .qtb.assert.callog exp_log;  
  };

.TEST.loadFile.t_mocks:(
  (`.lib.moduleLoaded;{1b});
  (`.lib.STATE.modules;1!enlist `moduleName`srcPath`state`files!(`mymodule;`:here;`loaded;()));
  (`.q.system;(::)));
  
.TEST.loadFile.success:{[]
  .lib.loadFile[`mymodule;`afile.q];
  .qtb.assert.matches[1!enlist `moduleName`srcPath`state`files!(`mymodule;`:here;`loaded;(),`afile.q);.lib.STATE.modules];
  exp_log:([] funcname:`.lib.moduleLoaded`.q.system; args:(`mymodule;"l here/mymodule/afile.q"));
  .qtb.assert.callog exp_log;
  };

.TEST.loadFile.alreadyLoaded:{[]
  .qtb.override[`.lib.STATE.modules;1!enlist `moduleName`srcPath`state`files!(`mymodule;`:here;`loaded;(),`afile.q)];
  .lib.loadFile[`mymodule;`afile.q];
  .qtb.assert.matches[1!enlist `moduleName`srcPath`state`files!(`mymodule;`:here;`loaded;(),`afile.q);.lib.STATE.modules];
  .qtb.assert.callog `funcname`args!(`.lib.moduleLoaded;`mymodule);
  };

.TEST.loadFile.notfound:{[]
  .qtb.mock[`.q.system;{x;'"not here!"}];
  .qtb.assert.throws[(.lib.loadFile;(),`mymodule;(),`afile.q);"not here!"];
  exp_log:([] funcname:`.lib.moduleLoaded`.q.system; args:(`mymodule;"l here/mymodule/afile.q"));
  .qtb.assert.callog exp_log;  
  };


.TEST.mapPluginFunction.t_mocks:(
  (`.lib.moduleLoaded;{1b});
  (`.lib.STATE.modules;1!enlist `moduleName`srcPath`state`files!(`mymodule;`:here;`loaded;()));
  (`.lib.p.load_so;{[a;b;c]}));

.TEST.mapPluginFunction.success:{[]
  .lib.mapPluginFunction[`mymodule;`sharedlib;`afunc;2];
  .lib.mapPluginFunction[`mymodule;`sharedlib;`bfunc;1];
  .qtb.assert.matches[1!enlist `moduleName`srcPath`state`files!(`mymodule;`:here;`loaded;(),`sharedlib);.lib.STATE.modules];
  exp_log:([]
    funcname:`.lib.moduleLoaded`.lib.p.load_so`.lib.moduleLoaded`.lib.p.load_so;
    args:(`mymodule;(`:here/mymodule/sharedlib;`afunc;2);`mymodule;(`:here/mymodule/sharedlib;`bfunc;1)));
  .qtb.assert.callog exp_log;
  };


