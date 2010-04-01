<?php
$field = false;

$fields = array();

foreach (file('Allegrex.isa') as $line) {
	$line = trim($line);
	if (!strlen($line)) continue;
	if (preg_match('@^field\b@', $line)) {
		$field = true;
	}
	
	if ($field) {
		if (preg_match_all('@(\\w+):(\\d+);@', $line, $matches, PREG_SET_ORDER)) {
			foreach ($matches as $match) {
				$fields[$match[1]] = (int)$match[2];
			}
		}
	}

	if (preg_match('@^group\b@', $line)) {
		echo "// $line\n";
		$field = false;
	}

	if (preg_match('@^op\s+(\\w+)\((.*)\)@', $line, $matches)) {
		//print_r($matches);
		$parts = explode(':', $matches[2]);
		$name = $matches[1];
		$mask = 0;
		$value = 0;
		//ADDIU(001001:rs:rt:imm16)
		
		//print_r($parts);
		
		foreach ($parts as $part) {
			if (isset($fields[$part])) {
				$size   = $fields[$part];
				$cvalue = 0;
				$cmask  = 0;
			} else {
				$size   = strlen($part);
				$cvalue = bindec($part);
				$cmask  = (1 << $size) - 1;
			}
			$mask  <<= $size;
			$value <<= $size;
			$value |= $cvalue;
			$mask  |= $cmask;
			//printf("%s:%08X:%08X : %d\n", $name, $value, $mask, $size);
		}
		printf("  InstructionInfo(\"%s\", 0x%08X, 0x%08X, \"%s\"),\n", $name, $value, $mask, $matches[2]);
		
		//if ($name == 'ADDIU') exit;
		//exit;
		//echo "  $line\n";
		//print_r($parts);
		//exit;
	}
}

exit;
print_r($fields);