{ stdenv, fetchurl, makeWrapper
, qtbase, makeQtWrapper, qtquickcontrols, qtscript, qtdeclarative, qmakeHook
, withDocumentation ? false
}:

with stdenv.lib;

let
  baseVersion = "4.3";
  revision = "0";
in

stdenv.mkDerivation rec {
  name = "qtcreator-${version}";
  version = "${baseVersion}.${revision}";

  src = fetchurl {
    url = "http://download.qt-project.org/official_releases/qtcreator/${baseVersion}/${version}/qt-creator-opensource-src-${version}.tar.xz";
    sha256 = "1n3ihky72p6q69n6c8s5hacq8rxdqmmr6msg89w5amwd17sam7p9";
  };

  buildInputs = [ qtbase qtscript qtquickcontrols qtdeclarative ];

  nativeBuildInputs = [ qmakeHook makeQtWrapper makeWrapper ];

  doCheck = true;

  enableParallelBuilding = true;

  buildFlags = optional withDocumentation "docs";

  installFlags = [ "INSTALL_ROOT=$(out)" ] ++ optional withDocumentation "install_docs";

  preBuild = optional withDocumentation ''
    ln -s ${qtbase}/$qtDocPrefix $NIX_QT5_TMP/share
  '';

  postInstall = ''
    substituteInPlace $out/share/applications/org.qt-project.qtcreator.desktop \
      --replace "Exec=qtcreator" "Exec=$out/bin/qtcreator"
    wrapQtProgram $out/bin/qtcreator
  '';

  meta = {
    description = "Cross-platform IDE tailored to the needs of Qt developers";
    longDescription = ''
      Qt Creator is a cross-platform IDE (integrated development environment)
      tailored to the needs of Qt developers. It includes features such as an
      advanced code editor, a visual debugger and a GUI designer.
    '';
    homepage = "https://wiki.qt.io/Category:Tools::QtCreator";
    license = "LGPL";
    maintainers = [ maintainers.akaWolf ];
    platforms = platforms.all;
  };
}
