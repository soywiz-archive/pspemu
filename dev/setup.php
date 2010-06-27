<?php

$base = dirname(__FILE__);

$packages = array(
	'dmd'    => new Package('http://pspemu.googlecode.com/files/dmd.2.047.zip'),
	'dfl'    => new Package('http://pspemu.googlecode.com/files/dfl-20100516.zip'),
	'ddbg'   => new Package('http://pspemu.googlecode.com/files/Ddbg-0.11.3-beta.zip'),
	'pspsdk' => new Package('http://pspemu.googlecode.com/files/pspsdk.7z'),
);

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

foreach ($packages as $package) $package->download();

if (!is_file("{$base}/dmd2/windows/bin/dmd.exe")) {
	$packages['dmd' ]->extract("{$base}");
}

if (!is_file("{$base}/dmd2/windows/bin/dfl.exe")) {
	$packages['dfl' ]->extract("{$base}/dmd2");
}

if (!is_file("{$base}/dmd2/windows/lib/dfl.lib")) {
	`{$base}\\dmd2\\windows\\bin\\dfl.exe -dfl-build`;
}

if (!is_file("{$base}/dmd2/windows/bin/ddbg.exe")) {
	$packages['ddbg']->extract("{$base}/dmd2/windows/bin");
}

if (!is_file("{$base}/pspsdk/bin/psp-gcc.exe")) {
	$packages['pspsdk']->extract("{$base}");
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

function extract7z($zip, $folder, $filter = '*') {
	@mkdir($folder, 0777, true);
	printf("Extracting '%s'...", $zip);
	$base = dirname(__FILE__);
	$cmd = "\"{$base}\\7z\\7z.exe\" x -y \"{$zip}\" -o\"{$folder}\" {$filter} -r";
	$result = `$cmd`;
	printf("Ok\n");
}

class Package {
	public $url;
	public $local;

	function __construct($url) {
		$this->url   = $url;
		$this->local = sprintf('%s/packages/%s', dirname(__FILE__), basename($url));
	}
	
	function download() {
		if (!is_file($this->local)) {
			printf("Downloading '%s'...", $this->url);
			@mkdir(dirname($this->local), 0777, true);
			file_put_contents($this->local, file_get_contents($this->url));
			printf("Ok\n");
		}
	}

	function extract($outputPath) {
		extract7z($this->local, $outputPath);
	}
}
