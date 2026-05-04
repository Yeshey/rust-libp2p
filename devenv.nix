{ pkgs, lib, config, ... }:

let
  webPkgs = with pkgs; [
    wasm-pack wasm-bindgen-cli
  ];

  nativePkgs = with pkgs;[
    pkg-config clang mold
    python3 # We'll use python's built-in http.server to serve the static frontend
  ];

  libclang = pkgs.llvmPackages_latest.libclang;

  sharedEnv = {
    LIBCLANG_PATH = lib.makeLibraryPath [ libclang.lib ];
    BINDGEN_EXTRA_CLANG_ARGS = builtins.concatStringsSep " "[
      ''-I"${libclang.lib}/lib/clang/${libclang.version}/include"''
      ''-I"${pkgs.glib.dev}/include/glib-2.0"''
      ''-I"${pkgs.glib.out}/lib/glib-2.0/include"''
    ];
  };

in {
  languages.rust = {
    enable  = true;
    channel = "stable";
    targets =[ "wasm32-unknown-unknown" ];
  };

  packages = webPkgs ++ nativePkgs;

  env = sharedEnv;
}