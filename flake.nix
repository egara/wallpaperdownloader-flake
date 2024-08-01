{
  description = "WallpaperDownloader. A Java application packaged with Nix flakes";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
  let 
    pkgs = nixpkgs.legacyPackages.x86_64-linux;
  in
  {  
    packages.x86_64-linux = {      
#      default = pkgs.stdenv.mkDerivation {
      default = pkgs.maven.buildMavenPackage {
        
        pname = "wallpaperdownloader";
        version = "4.4.2";

        src = ./.;

        mvnHash = "sha256-z2jrl5oTkVzYzcBIPZzpdrXQ4L0Gn6aGvLX02YK6bBs=";

        #buildInputs = [ pkgs.maven pkgs.jdk ];
        buildInputs = [ pkgs.jdk ];

        #buildPhase = ''
        #  mvn clean package -DskipTests
        #'';

        installPhase = ''
          mkdir -p $out/lib
          cp target/$pname.jar $out/lib/$pname.jar
        '';

        #__noChroot = true;

        meta = with pkgs.lib; {
          description = "My Java Application";
          license = licenses.mit;
          maintainers = [ "maintainers.yourGitHubHandle" ];
        };
      };
    };
  };
}
