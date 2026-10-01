{
  description = "Etna, the iOS wallet for NOX Shield";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    rust-overlay.url = "github:oxalica/rust-overlay";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { nixpkgs, rust-overlay, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ (import rust-overlay) ];
        };

        rust = pkgs.rust-bin.stable."1.91.1".default.override {
          targets = [ "aarch64-apple-ios" "aarch64-apple-ios-sim" ];
        };
      in
      {
        # Nix supplies the Rust toolchain, XcodeGen and the linters. It does not
        # supply Xcode: Apple does not permit redistribution, so the iOS app
        # itself is built by the Xcode on the machine, and the version that was
        # used goes in the build record. docs/03-reproduce.md says what that means
        # for reproducibility and what is pinned regardless.
        devShells.default = pkgs.mkShell {
          packages = [
            rust
            pkgs.xcodegen
            pkgs.swiftlint
          ];

          shellHook = ''
            echo "Etna iOS shell. scripts/build-core.sh builds the core,"
            echo "then: xcodegen generate && open NoxShield.xcodeproj"
          '';
        };
      });
}
