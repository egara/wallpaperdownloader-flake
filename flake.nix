{
  description = "WallpaperDownloader. A Java based application packaged using a Nix flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
  let 
    pkgs = nixpkgs.legacyPackages.x86_64-linux;
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
      default = pkgs.maven.buildMavenPackage {
        
        pname = "wallpaperdownloader";
        version = "4.4.2";

        src = ./.;

        mvnHash = "sha256-z2jrl5oTkVzYzcBIPZzpdrXQ4L0Gn6aGvLX02YK6bBs=";

        buildInputs = [ pkgs.jdk ];


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
