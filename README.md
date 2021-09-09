# qldr - a simple module loader for kdb+

Q loader is a simple module loader for kdb; taking some ideas from Python's module system. It is designed to be loaded directly upon startup via `q.q` in `$QHOME`.

For the purposes of qldr, a module is a directory in the filesystem that contains a file named `_init_.q`. The name of the module is the name of the directory that contains the `_init_.q` file. A module is imported into the running q session by calling `` .lib.import`amodule;`` - i.e. passing the name of the module as a symbol. The import function will then search in all directories listed in the module path environment variable (by default this is `KDB_MODULE_PATH`). The paths listed in the environment variable are separated by colons.

When trying to load a module, qldr will check each directory in the module search path for a directory with the target modules' name (`` `amodule`` in the example) that also contains an `_init_.q` file. It will load the `_init_.q` file. Additional script files have to be explicitly loaded by `_init_.q`. If `_init_.q` loads without an exception being thrown, the targeted module is considered to have been loaded and qldr will update its internal tracking. Subsequent calls to `.lib.import` for the same module will do nothing as the module is already loaded. If desired, a reload can be forced via `.lib.reload`.

Contrary to Python qldr will not automatically wrap all objects from the module in the namespace of the module; the module code may use any namespace and must do so explicitly.

Aside from `.lib.import`, qldr also provides `.lib.loadFile`, which takes two arguments; the relevant module name as a symbol and a target file with a .q extension. The module referenced in the call to `.lib.loadFile` must have already been imported (or be in the process of being loaded) because the target file will be loaded relative to the module directory. The core idea of the module definition of qldr is that the `_init_.q` file simply loads one or more actual q source files and maybe performs some simple initializations. A module may therefore consist of many different script files, possibly organized into subdirectories and loaded from the code as necessary. This should make it relatively easy for code that has no knowledge of qldr to be integrated into a project that utilizes it.

In addition to .lib.loadFile, qldr also provides `.lib.mapPluginFunction`, which wraps kdb's `2:` operator (see [here](https://code.kx.com/q/ref/dynamic-load/)). It requires four arguments, the module name from which the `.so` file is to be loaded, the name of the `.so` file itself, the name of the c-function exported by the `.so` that should be mapped, and the number of arguments (q objects) it takes. Qldr will automatically prefix the name of the `.so` file with the absolute path from where the module has been loaded. In this manner the `.so` file of plugins can be held together with the q scripts that wrap it and rely on it. The loading and binding can all be performed in the `_init_.q` file.

## Reference

* `.lib.import[<name>]`: Imports the module _name_, which must be passed as a symbol.

* `.lib.reload[<name>]`: Re-imports the module identifid by the symbol _name_. The module must already be loaded. This function essentially executes the module's `_init_.q` script again.

* `.lib.moduleLoaded[<name>]`: Returns a boolean value indicating whether the relevant module has been loaded.

* `.lib.loadFile[<module name>;<filename.q>]`: Loads the script file _filename.q_ relative to the module's root path.

* `.lib.mapPluginFunction[<module name>;<soname>;<funcname>;<c function rank>]`: Maps a binary function embedded in the shared object <soname> (without the .so suffix) from the given module's root path into the running q session.

## License

The qldr.q script and all other files in this repository are licensed under the GNU Public License v3, which can be found on the [GNU website](https://www.gnu.org/copyleft/gpl.html).
