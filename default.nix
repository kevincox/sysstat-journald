with import <nixpkgs> {};

stdenv.mkDerivation {
	name = "sysstat-journald";
	
	meta = {
		description = "Dumps systemd information into the journal.";
		homepage = https://github.com/kevincox/sysstat-journald;
	};
	
	src = builtins.filterSource (name: type:
		(lib.hasPrefix (toString ./sysstat-journald.sh) name)
	) ./.;
	
	buildInputs = [ makeWrapper ];
	
	installPhase = ''
		install -Dm755 'sysstat-journald.sh' "$out/bin/sysstat-journald"
		wrapProgram $out/bin/sysstat-journald \
			--set PATH "${lib.makeBinPath [
				coreutils
				gawk
				sysstat
				utillinux
			]}:${sysstat}/lib/sa/"
	'';
}
