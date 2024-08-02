{
  description = "WallpaperDownloader. A Java based application packaged using a Nix flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-24.05";
  };

  outputs = { self, nixpkgs }:
  let 
    pkgs = nixpkgs.legacyPackages.x86_64-linux;
    version = "4.4.2";
  in
  {  
    packages.x86_64-linux = {      
      #default = pkgs.stdenv.mkDerivation {
      # Instead of using pkgs.stdenv.mkDerivation to create a standard derivation
      # where all the stuff needed to run WallpaperDownloader is located, 
      # pkgs.maven.buildMavenPackage function will be used. This function
      # is very useful for Java applications developed using maven. It will
      # build the package directly using maven and it will allow to download
      # all the dependencies from Internet. mkDerivation was used before with
      #
      # buildInputs = [ pkgs.maven pkgs.jdk ];
      # buildPhase = ''
      #   mvn clean package -DskipTests
      # '';
      #
      # but the problem was that in order to build the package, no connection to
      # Internet is provided inside the building chroot used and maven will fail.
      # This is not a limitation when buildMavenPackage function is used.
      # mvnHash is needed to be provided and is calculated with all the maven
      # dependencies downloaded within the local maven repository.
      # In order to obtain this hash it is only necessary to comment the line
      # and execute nix build. This command will fail and it will provide the correct
      # hash to use.
      # Sources: 
      # https://ryantm.github.io/nixpkgs/languages-frameworks/maven/
      # https://ryantm.github.io/nixpkgs/languages-frameworks/java/#sec-language-java
      default = pkgs.maven.buildMavenPackage {
        
        pname = "wallpaperdownloader";
        inherit version;

        src = pkgs.fetchurl {
          url = "https://bitbucket.org/eloy_garcia_pca/wallpaperdownloader/get/v${version}.tar.gz";
          hash = "sha256-ArzG8UlhsHH/St0xsa2YbFfr2qqxt8n067mRPABM2gI=";
        };

        # Comment above and uncomment this if it is necessary to do some
        # tests and the source code of WallpaperDownloader is here ./
        # src = ./.;

        mvnHash = "sha256-qj/NTVeprYl/d2xt2qKG1bP7FZvm0kz/GveapJzuX8s=";

        buildInputs = [ 
          pkgs.jdk 
        ];

        # makeWrapper is a Nix tool specific developed to create scripts
        # (wrappers) to execute Java applications (and maybe anothe kind
        # of applications)
        nativeBuildInputs = [ pkgs.makeWrapper ];

        installPhase = ''
          # Preparing final structure
          mkdir -p $out/bin $out/share/java/$pname

          # Copying the complete jar
          install -Dm644 target/$pname.jar $out/share/java/$pname

          # Installing .desktop file and icon
          install -Dm444 ${self}/packaging/$pname.desktop -t $out/share/applications
          install -Dm444 ${self}/packaging/$pname.svg -t $out/share/icons/hicolor/scalable/apps

          makeWrapper ${pkgs.jre}/bin/java $out/bin/$pname \
          --add-flags "-Xmx256m -Xms128m -jar $out/share/java/$pname/$pname.jar"
        '';

        meta = with pkgs.lib; {
          description = "WallpaperDownloader. Download, manage and change automatically your favorite wallpapers from the Internet";
          license = licenses.mit;
          maintainers = [ "maintainers.yourGitHubHandle" ];
        };
      };
    };
  };
}