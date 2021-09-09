.lib.cfg.envVar:`KDB_MODULE_PATH;
.lib.cfg.initFile:`$"_init_.q";
.lib.cfg.moduleLocations:();

.lib.STATE.modules:([moduleName:`$()] srcPath:`$(); state:`$(); files:());

.lib.p.getenv:getenv;

.lib.init:{[] `.lib.cfg.moduleLocations set `$":",/: ":" vs .lib.p.getenv .lib.cfg.envVar; };

.lib.import:{[moduleName]
  if[.lib.moduleLoaded moduleName;:(::)];
  pathIndex:{first where not x ~\: ()} .q.key each modulePaths:` sv/: .lib.cfg.moduleLocations,\: (moduleName;.lib.cfg.initFile);
  if[null pathIndex;'"module not found: ",string moduleName];
  `.lib.STATE.modules upsert `moduleName`srcPath`files`state!(moduleName;.lib.cfg.moduleLocations pathIndex;();`loading);
  .[.lib.p.loadModule;(moduleName;modulePaths pathIndex);.lib.p.failedModuleLoad[moduleName;`;]];
  };

.lib.p.loadModule:{[mn;path]
  .q.system "l ",1 _ string path;
  .lib.STATE.modules[mn;`state]:`loaded;  
  };

.lib.p.println:{-1 x};

.lib.p.failedModuleLoad:{[mn;revertState;err]
  .lib.p.println errReport:"Failed to load module ",string[mn],": ",err;
  $[null revertState;delete from `.lib.STATE.modules where moduleName=mn;.lib.STATE.modules[mn;`state]:revertState];
  'errReport;
  };

.lib.moduleLoaded:{[moduleName] not null .lib.STATE.modules[moduleName;`srcPath] };

.lib.reload:{[moduleName]
  if[not .lib.moduleLoaded moduleName;'"module not loaded: ",string moduleName];
  .lib.STATE.modules[moduleName;`state]:`reloading;
  .[.lib.p.loadModule;(moduleName;` sv (.lib.STATE.modules[moduleName;`srcPath];moduleName;.lib.cfg.initFile));.lib.p.failedModuleLoad[moduleName;`loaded]];
  };

.lib.loadFile:{[moduleName;file]
  if[not .lib.moduleLoaded moduleName;'"module not loaded: ",string moduleName];
  if[file in .lib.STATE.modules[moduleName;`files];:(::)];
  .q.system "l ",1 _ string ` sv (.lib.STATE.modules[moduleName;`srcPath];moduleName;file);
  .lib.STATE.modules[moduleName;`files],:file;
  };

.lib.p.load_so:{[soPath;funcname;cfrank] soPath 2: (funcname;cfrank)};

.lib.mapPluginFunction:{[moduleName;soname;funcname;cfrank]
  if[not .lib.moduleLoaded moduleName;'"module not loaded: ",string moduleName];
  res:.lib.p.load_so[` sv (.lib.STATE.modules[moduleName;`srcPath];moduleName;soname);funcname;cfrank];
  .lib.STATE.modules[moduleName;`files]:distinct .lib.STATE.modules[moduleName;`files],soname;
  :res;
  };
  
.lib.init[];
