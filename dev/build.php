<?php

require(dirname(__FILE__) . '/setup.php');

/*
dmd\windows\bin\dmd -Jresources -Idmd\import -c pspemu\exe\Pspemu.d
*/

class SourceD {
	public $fileName;
	public $fileContents;

	public function __construct($fileName) {
		$this->fileName     = $fileName;
		$this->fileContents = file_get_contents($fileName);
	}

	public function getImports() {
		preg_match_all('@import\\s+([^;]*);@Umsu', $this->fileContents, $matches);
		$modules = array();
		foreach ($matches[1] as $match) {
			foreach (explode(',', $match) as $module) {
				$module = trim($module);
				if (strlen($module)) $modules[] = $module;
			}
		}
		return $modules;
	}

	public function getModule() {
		if (!preg_match('@module\\s+([^;]*);@Umsi', $this->fileContents, $matches)) throw(new Exception("Can't find the module name."));
		return $matches[1];
	}
}

class Builder {
	public $dmd;
	public $rcc;
	public $modules = array();
	
	public function explore($module, $level = 0) {
		//printf("Module: %s\n", $module);
		$source = new SourceD(sprintf('%s.d', str_replace('.', '/', $module)));
		$this->modules[$module] = $source;
		foreach ($source->getImports() as $importedModule) {
			if (substr($importedModule, 0, 7) != 'pspemu.') continue;
			if (!isset($this->modules[$importedModule])) {
				$this->explore($importedModule);
			}
		}
		return $source;
	}

	public function getModules() {
		$modules = array_keys($this->modules);
		sort($modules);
		return $modules;
	}

	public function build() {
		$exe = 'pspemu.exe';
		$objects_folder = dirname(__FILE__) . '/objects';

		@mkdir($objects_folder, 0777, true);

		$compileFiles = array();
		$linkFiles = array();

		foreach ($this->getModules() as $module) {
			$basePath = str_replace('.', '/', $module);
			$object = sprintf('%s/%s.obj', $objects_folder, str_replace('.', '_', $module));
			$source = sprintf('%s.d', $basePath);
			if (filemtime($source) != @filemtime($object)) {
				$compileFiles[] = array($object, $source, $module);
			}
			$linkFiles[] = $object;
		}
		
		$flags = "-Jresources -Idev\dmd2\import -noboundscheck -g -O -release";
		
		// @TODO: Optimize: compile at files with one all
		foreach ($compileFiles as $row) {
			list($object, $source, $module) = $row;

			@unlink($object);
			$cmd = "{$this->dmd} {$flags} -of{$object} -c {$source}";
			printf("Compiling...%s\n", $cmd);
			$retval = 0;
			passthru($cmd, $retval);
			if ($retval != 0) {
				@unlink($exe);
				exit;
			}

			if (filesize($object)) {
				touch($object, filemtime($source));
			} else {
				unlink($object);
			}
		}

		$maxTime = array();
		foreach ($linkFiles as $file) $maxTime[] = filemtime($file);
		$maxTime = max($maxTime);
		
		// Build EXE.
		if (@filemtime($exe) != $maxTime) {
			$linkFilesStr = implode(' ', $linkFiles);
			@unlink($exe);
			
			echo `{$this->rcc} -32 resources\\psp.rc -oresources\\psp.res`;

			$cmd = "{$this->dmd} dfl.lib {$flags} -of\"{$exe}\" resources/psp.res {$linkFilesStr}";
			//printf("Linking...%s\n", $cmd);
			$retval = 0;
			passthru($cmd, $retval);
			if ($retval != 0) {
				@unlink($exe);
				exit;
			}

			if (filesize($exe)) {
				touch($exe, $maxTime);
			} else {
				unlink($exe);
			}
			
			@unlink("pspemu.map");
			@unlink("pspemu.obj");
		}
	}

	public function __construct() {
		$this->dmd = dirname(__FILE__) . '\\dmd2\\windows\\bin\\dmd.exe';
		$this->rcc = dirname(__FILE__) . '\\rcc\\rcc.exe';
	}
}

$builder = new Builder;
$builder->explore('pspemu.exe.Pspemu');
foreach (scandir('pspemu/hle/kd') as $file) {
	if ($file[0] == '.') continue;
	list($moduleBase) = explode('.', $file);
	//echo "$file\n";
	$builder->explore('pspemu.hle.kd.' . $moduleBase);
}
$builder->build();

/*
$exe = new SourceD('pspemu/exe/Pspemu.d');
//echo $exe->getModule();
print_r($exe->getImports());
*/