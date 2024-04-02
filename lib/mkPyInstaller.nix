# mkPyInstaller.nix
#   use pyinstaller directly in nix
pkgs:
{ python ? pkgs.python311, main ? __main__.py, nativeBuildInputs ? [ ], ...
}@args:
let
  pyinstaller = import ../packages/pyinstaller.nix { inherit pkgs python; };
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
    install -Dm 755 dist/${name} $out/bin/${name}
  '';
  meta.mainProgram = "$out/bin/${name}";
})
