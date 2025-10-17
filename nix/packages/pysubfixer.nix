{
  pkgs,
  python,
  srcDir,
  ...
}:
with python.pkgs;
# build:
buildPythonApplication {
  pname = "pysubfixer";
  version = "1.0";
  pyproject = true;
  buildInputs = [
    poetry-core
    pyside6
    pycall
    rich
  ];
  propagatedBuildInputs = [
    pyside6
    pycall
    rich
  ];
  src = srcDir + "pysubfixer";
}
