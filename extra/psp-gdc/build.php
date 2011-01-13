<?php

// psp-gcc -I. -Ic:/pspsdk/psp/sdk/include -O2 -Wall -I"../.." -D_PSP_FW_VERSION=150 -c -o module.o module.c
// psp-gdc -I. -Ic:/pspsdk/psp/sdk/include -O2 -Wall -I"../.." -D_PSP_FW_VERSION=150 -c -o ortho.o ortho.d
// psp-gcc -I. -Ic:/pspsdk/psp/sdk/include -O2 -Wall -I"../.." -D_PSP_FW_VERSION=150 -L.. -L. -Lc:/pspsdk/psp/sdk/lib   module.o ortho.o ../../pspsdk/pspctrl.d ../../pspsdk/utils/callback.d ../../pspsdk/utils/vram.d -lgphobos -lpspgum -lpspgu -lm -lpspdebug -lpspdisplay -lpspge -lpspctrl -lpspsdk -lc -lpspnet -lpspnet_inet -lpspnet_apctl -lpspnet_resolver -lpsputility -lpspuser -lpspkernel -o OrthoInD.elf

/*
psp-fixup-imports OrthoInD.elf
psp-strip OrthoInD.elf -o OrthoInD_strip.elf
pack-pbp EBOOT.PBP PARAM.SFO NULL
*/

class SourcesProcessor {
	protected $pspsdk_path;
	protected $dpspsdk_path;
	protected $importFiles = array();
	protected $currentImports = array();
	protected $currentContents;
	
	protected $importFolders = array();
	
	protected $filesToProcess = array();
	protected $filesProcessed = array();

	protected $BUILD_INFO = array(
		'LIBS' => array(
			'gphobos',
			'm',
			'pspgum',
			'pspgu',
			'm',
			'pspdebug',
			'pspdisplay',
			'pspge',
			'pspctrl',
			'pspsdk',
			'c',
			'pspnet',
			'pspnet_inet',
			'pspnet_apctl',
			'pspnet_resolver',
			'psputility',
			'pspuser',
			'pspkernel',
		),
	);
	
	public function __construct() {
		$this->pspsdk_path = trim(`psp-config --pspsdk-path 2> NUL`);
		$this->dpspsdk_path = __DIR__ . '/import';
		if (empty($this->pspsdk_path)) {
			if (is_file('c:/pspsdk/bin/psp-config.exe')) {
				$this->pspsdk_path = trim(`c:/pspsdk/bin/psp-config.exe --pspsdk-path 2> NUL`);
			}
		}
	}
	
	public function addImportFolder($filePath) {
		$this->importFolders[] = $filePath;
	}
	
	public function addFileToProcess($fileName) {
		$fileName = realpath($fileName);
		if (!isset($this->filesProcessed[$fileName])) {
			$this->filesToProcess[$fileName] = true;
			$this->filesProcessed[$fileName] = true;
		}
	}
	
	public function addModuleToProcess($moduleName) {
		$moduleRelativePath = str_replace('.', '/', $moduleName) . '.d';
		foreach (array_merge($this->importFolders, array($this->dpspsdk_path)) as $checkBasePath) {
			$moduleCandidatePath = "{$checkBasePath}/{$moduleRelativePath}";
			if (is_file($moduleCandidatePath)) {
				$this->addFileToProcess($moduleCandidatePath);
				//echo "{$moduleCandidatePath}\n";
			}
		}
	}

	public function processFile($fileName) {
		//echo "{$fileName}\n";
		$this->importFiles[] = $fileName;
		$this->currentContents = file_get_contents($fileName);
		{
			$this->extractModuleImports();
			$this->extractBuildInfo();
		}
		$this->currentContents = NULL;
		foreach ($this->currentImports as $moduleName) $this->addModuleToProcess($moduleName);
		$this->currentImports = array();
	}
	
	public function processAllFiles() {
		while (!empty($this->filesToProcess)) {
			foreach ($this->filesToProcess as $fileName => $v) {
				unset($this->filesToProcess[$fileName]);
				break;
			}
			$this->processFile($fileName);
		}
	}
	
	protected function extractModuleImports() {
		$imports = array();
		if (preg_match_all('@import\\s+(.*);@Umsi', $this->currentContents, $matches)) {
			foreach ($matches[1] as $match) {
				$import_list = $match;
				$import_list = preg_replace('@//[^\\r\\n]*[\\r\\n]@Umsi', '', $import_list);
				$import_list = preg_replace('@/\\*(.*)\\*/@Umsi', '', $import_list);
				//echo $import_list;

				$imports = array_merge($imports, array_map('trim', explode(',', $import_list)));
			}
			$imports = array_unique($imports);
		}
		$this->currentImports = $imports;
	}
	
	protected function buildModuleC() {
		return implode("\n", array(
			'#include <pspkernel.h>',
			'#include <pspdebug.h>',
			'#include <pspsuspend.h>',
			'',
			"PSP_MODULE_INFO({$this->BUILD_INFO['MODULE_NAME']}, 0, 1, 1);",
			"PSP_MAIN_THREAD_ATTR({$this->BUILD_INFO['PSP_MAIN_THREAD_ATTR']});",
			'void emitInt    (int   v) { asm("syscall 0x1010"); }',
			'void emitFloat  (float v) { asm("syscall 0x1011"); }',
			'void emitString (char *v) { asm("syscall 0x1012"); }',
			'void emitComment(char *v) { asm("syscall 0x1012"); }',
			'void emitMemoryBlock(void *address, unsigned int size) { asm("syscall 0x1013"); }',
			'void emitHex(void *address, unsigned int size) { asm("syscall 0x1014"); }',
		));
	}

	protected function extractBuildInfo() {
		if (preg_match('@version\\s*\\(BUILD_INFO\\)\\s*\\{(.*)\\}@Ums', $this->currentContents, $matches)) {
			if (preg_match_all('@pragma\\(\\s*(?<name>\\w+)\\s*,\\s*(?<value>.*)\\s*\\)\\s*;@Ums', $matches[1], $matches, PREG_SET_ORDER)) {
				foreach ($matches as $match) {
					if ($match['name'] == 'lib') {
						array_unshift($this->BUILD_INFO['LIBS'], trim($match['value']));
						//$this->BUILD_INFO['LIBS'][] = trim($match['value']);
					} else {
						$this->BUILD_INFO[$match['name']] = trim($match['value']);
					}
				}
			}
		}
	}
	
	public function build() {
		$this->processAllFiles();
		
		if (empty($this->importFiles)) {
			die("No files specified");
		}
		
		//@mkdir(__DIR__ . '/obj', 0777, true);
	
		$this->BUILD_INFO += array(
			'MODULE_NAME'          => '"PSP_D_APP"',
			'PSP_EBOOT_TITLE'      => '"PSP D Application"',
			'PSP_MAIN_THREAD_ATTR' => 'THREAD_ATTR_USER | THREAD_ATTR_VFPU',
			'PSP_FW_VERSION'       => 150,
		);
		
		//print_r($this);
		
		$base_flags = "-I. -I\"{$this->pspsdk_path}/include\" -O2 -Wall -I\"{$this->dpspsdk_path}\" -D_PSP_FW_VERSION={$this->BUILD_INFO['PSP_FW_VERSION']} -L.. -L. -L\"{$this->pspsdk_path}/lib\"";
		$psp_gcc = "{$this->pspsdk_path}/../../bin/psp-gcc";
		$psp_gdc = "{$this->pspsdk_path}/../../bin/psp-gdc";
		$mksfo = "{$this->pspsdk_path}/../../bin/mksfo";
		$pack_pbp = "{$this->pspsdk_path}/../../bin/pack-pbp";
		$psp_fixup_imports = "{$this->pspsdk_path}/../../bin/psp-fixup-imports";
		$output_elf = 'output.elf';
		
		@unlink($output_elf);
	
		//file_put_contents(__DIR__ . '/module.c', $this->buildModuleC());
		file_put_contents('module.c', $this->buildModuleC());
		echo `{$psp_gcc} {$base_flags} -c -o module.o module.c`;
		
		/*
		$fileList = implode(' ', array_map(function($fileName) {
			return '"' . $fileName . '"';
		}, $this->importFiles));
		$cmd = "{$psp_gdc} {$base_flags} -c -o dcode.o {$fileList}";
		echo `{$cmd}`;
		*/
		//print_r($this->importFiles);
		
		$objFiles = array('module.o');
		
		foreach ($this->importFiles as $fileName) {
			$objFile = basename($fileName) . '.o';
			$objFiles[] = $objFile;
			//echo "{$fileName}\n";
			echo `{$psp_gdc} {$base_flags} -c -o {$objFile} {$fileName}`;
		}
		
		$libsStr = implode(' ', array_map(function($libName) {
			return '-l' . $libName;
		}, $this->BUILD_INFO['LIBS']));
		
		$objFilesStr = implode(' ', $objFiles);
		echo `{$psp_gcc} {$base_flags} {$objFilesStr} {$libsStr} -o {$output_elf}`;

		// BUILD CLEANUP.
		unlink('module.c');
		foreach ($objFiles as $objFile) {
			unlink($objFile);
		}

		// FIX AND EXECUTE
		if (is_file($output_elf)) {
			`{$psp_fixup_imports} {$output_elf}`;
			
			`{$mksfo} {$this->BUILD_INFO['PSP_EBOOT_TITLE']} PARAM.SFO`;
			`{$pack_pbp} EBOOT.PBP PARAM.SFO NULL NULL NULL NULL NULL {$output_elf} NULL`;
			
			unlink('PARAM.SFO');
			unlink($output_elf);

			//`{$output_elf}`;
			system(__DIR__ . '/../../pspemu_normal.exe EBOOT.PBP');
		}
	}
}

$sp = new SourcesProcessor();
foreach (array_slice($argv, 1) as $arg) {
	$sp->addImportFolder(dirname(realpath($arg)));
}
foreach (array_slice($argv, 1) as $arg) {
	$sp->addFileToProcess($arg);
}
$sp->build();