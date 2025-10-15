{pkgs}:
pkgs.stdenv.mkDerivation {
  name = "wpsoffice-fonts";
  version = "2.0";
  src = pkgs.fetchgit {
    url = "https://github.com/ferion11/ttf-wps-fonts";
    rev = "f4131f029934a76ea90336c8ee4929c5c78588f4";
    sha256 = "sha256-LB7/VHTB3tPOqXoq0kaCw7VmaE4ZRSbwDvzhxPMsz+k=";
  };

  buildInputs = [];

  buildPhase = "true";

  installPhase = ''
    mkdir -p $out/share/fonts/truetype
    cp $src/*.ttf $out/share/fonts/truetype/ || true
    cp $src/*.TTF $out/share/fonts/truetype/ || true
  '';

  meta = {
    description = "These are the symbol fonts required by wps-office. They are used to display math formulas. We have collected the fonts here to make things easier.";
    homepage = https://github.com/ferion11/ttf-wps-fonts;
    binaryDistribution = false;
    priority = 5;
  };
}
