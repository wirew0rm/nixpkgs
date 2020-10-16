{ stdenv
, mkDerivation
, fetchFromGitHub
, libsodium
}:

mkDerivation {
  pname = "gr-nacl";
  version = "2017-04-10";
  src = fetchFromGitHub {
    owner = "stwunsch";
    repo = "gr-nacl";
    rev = "15276bb0fcabf5fe4de4e58df3d579b5be0e9765";
    sha256 = "018np0qlk61l7mlv3xxx5cj1rax8f1vqrsrch3higsl25yydbv7v";
  };
  disabled = ["3.8"];

  buildInputs = [
    libsodium
  ];

  meta = with stdenv.lib; {
    description = "Gnuradio block for encryption";
    homepage = "https://github.com/stwunsch/gr-nacl";
    license = licenses.gpl3Plus;
    platforms = platforms.linux ++ platforms.darwin;
    maintainers = with maintainers; [ mog ];
  };
}
