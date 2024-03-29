# pyinstaller into nix:
pkgs:
{ python ? pkgs.python311, main ? __main__.py, nativeBuildInputs ? [ ], ...
}@args:
let
  # use the correct binutils
  binutils = if pkgs.stdenv.isDarwin then darwin-binutils else binutils;
  # the hooks
  pyinstaller-hooks-contrib = python.pkgs.buildPythonPackage rec {
    version = "2024.3";
    pname = "pyinstaller-hooks-contrib";
    src = python.pkgs.fetchPypi {
      inherit pname version;
      sha256 = "sha256-0YZXwpJnxjVjqWuPx422uprkCvZwKssvjIcd8Sx1tgs=";
    };
    propagatedBuildInputs = (with python.pkgs; [ packaging pip ]);
  };

  # implementation
  pyinstaller = python.pkgs.buildPythonPackage rec {
    version = "6.5.0";
    pname = "pyinstaller";
    src = python.pkgs.fetchPypi {
      inherit pname version;
      sha256 = "sha256-seVRE8WkDLcEHJCKV/IS8+vT5ETbskXKL5HYanbavsU=";
    };
    propagatedBuildInputs = [ pyinstaller-hooks-contrib binutils ]
      ++ (with python.pkgs; [
        packaging
        pip
        altgraph
        setuptools
        pyqt5
        pyqt5-stubs
        qtpy
        matplotlib
      ]) ++ (with pkgs; [ glibc zlib ]); # TODO make sure darwin works

    dontUseSetuptoolsCheck = true;
    # for lib.getExe
    meta = {
      mainProgram = "$out/bin/${pname}";
      description = "pyinstaller is a builder for python packages";
    };
  };
  # remove things stdenv does not care about
  derivationArgs = builtins.removeAttrs args [ "python" "main" ];
  # package stuff :
in pkgs.stdenvNoCC.mkDerivation (derivationArgs // {
  nativeBuildInputs = with pkgs;
    [ glibc tree ensureNewerSourcesForZipFilesHook ] ++ [ python pyinstaller ]
    ++ (derivationArgs.nativeBuildInputs);
  buildPhase = ''
    ${lib.getExe pyinstaller} ${main} -F --clean -n ${name}
  '';
  installPhase = ''
    install -Dm 755 dist/keypin $out/bin/${name}
  '';
  meta.mainProgram = "$out/bin/${name}";
})
