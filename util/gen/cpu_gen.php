<?php
	require_once('tables/cpu_table.php');

	function get_common_mask($set) {
		$mask = 0xFFFFFFFF;
		foreach ($set as $i) $mask &= $i[2];
		return $mask;
	}
	
	function comp_unsigned($a, $b) {
		$a = sprintf('%08X', $a);
		$b = sprintf('%08X', $b);
		return strcmp($a, $b);
	}
	
	function bit_delim($v) {
		$l = $r = 0;
		while (!(($v >> $r) & 1)) $r++;
		while (!(($v << $l) & 0x80000000)) $l++;
		return array(32 - $l, $r);
	}
	
	function process_switch($set, $level = 0) {
		global $impl;
	
		$mask = get_common_mask($set);
		
		//if ($mask == 0) $mask = 0xFFFFFFFF;
		
		$nset = array();
		foreach ($set as $i) {
			list($_name, $_data, $_mask) = $i;
			$v = $_data & $mask;
			$nset[$v][] = array(strtoupper($_name), $_data, $_mask & ~$mask);
		}
		//if ($level >= 4) return;
		
		$t = "\t";
		$t = "    ";
		
		$lpad = str_repeat($t, $level);

		list($left, $right) = bit_delim($mask);

		printf("{$lpad}switch (OP & 0x%08X) { default: UNK_OP(); continue;\n", $mask);
		//printf("%d, %d\n", $left, $right);
		
		uksort($nset, 'comp_unsigned');

		$maxlen = 0; foreach ($nset as $cvalue => $cset) if (sizeof($cset) == 1) $maxlen = max($maxlen, strlen($cset[0][0]));
		//$maxlen = 11;
		
		foreach ($nset as $cvalue => $cset) {
			//$cvalue >>= $right;
		
			if (sizeof($cset) == 1) {
				$i = $cset[0];
				$cname = $i[0];
				printf("{$lpad}{$t}case /* %-{$maxlen}s */ 0x%08X: ", $cname, $cvalue);
				$im = &$impl[strtoupper($cname)];
				if (isset($im)) {
					echo $im;
				} else{
					//printf("UNI_OP();");
					printf('UNI_OP("' . $cname . '");');
				}
				printf(" continue;\n");
			} else {
				printf("{$lpad}{$t}case /* %-{$maxlen}s */ 0x%08X:\n", '', $cvalue);
				process_switch($cset, $level + 2);
				printf("{$lpad}{$t}continue;\n");
			}
		}
		printf("{$lpad}}\n");
		//print_r(array_keys($nset[0]));
	}
	
	function process_impl($file) {
		global $impl;
		$in = '';
		foreach (file($file) as $l) {
			list($l) = explode('//', $l); $l = trim($l);
			if (substr($l, 0, 1) == '@') {
				$in = strtoupper(trim(substr($l, 1)));
				if (isset($impl[$in])) {
					printf("static assert(%s != 0);\n", '"Redefined ' . $in . '"');
				}
				continue;
			}
			if (!isset($impl[$in])) $impl[$in] = '';
			$impl[$in] .= " $l";
		}
	}
	
	function process_impl_dir() {
		global $impl; $impl = array();
		
		foreach (scandir($path = 'impl') as $f) {
			$rf = "{$path}/{$f}";
			if (substr($f, 0, 1) == '.') continue;
			process_impl($rf);
		}
		
		foreach ($impl as $k => &$text) {
			$text = trim($text);
			
			$pcc = preg_match('/(jump|branch|branchl)\\(([^)]+)\\)/Umsi', $text);
			$text = preg_replace('/jump\\(([^;]+)\\);/Umsi', 'PC = nPC; nPC = $1;', $text);
			$text = preg_replace('/branch\\(([^;]+)\\);/Umsi', 'PC = nPC; nPC += ($1) ? (IMM << 2) : 4;', $text);
			$text = preg_replace('/branchl\\(([^;]+)\\);/Umsi', 'if ($1) { PC = nPC; nPC += (IMM << 2); } else { PC = nPC + 4; nPC = PC + 4; }', $text);
			
			$text = preg_replace('/callstack_push\\(([^;]*)\\);/Umsi', 'if (callstack_length < callstack.length - 2) callstack[callstack_length++] = ($1);', $text);
			$text = preg_replace('/callstack_pop\\(([^;]*)\\);/Umsi', 'if (callstack_length > 0) callstack_length--;', $text);
			//callstack_length > 0) callstack_length--;
			//callstack[callstack_length++] = nPC;
			
			//PC = nPC; nPC += ((cast(int)RS) == cast(int)RT) ? (IMM << 2) : 4;
			
			if (!strlen($text)) {
				unset($impl[$k]);
				continue;
			}
			
			$text = 'debug(used_i) { if (("' . $k . '" in used_i_table) is null) used_i_table["' . $k . '"] = 0; used_i_table["' . $k . '"]++; }' . $text;
			
			//$text = 'printf("' . $k . '\r"); ' . $text;
			if (!$pcc) $text = 'PC = nPC; nPC += 4; ' . $text;
			//if (!$pcc) $text .= ' PC = nPC; nPC += 4;';
		}
	}

	echo 'Building cpu switch table...';
	ob_start();
	echo "#line 2 \"cpu_switch\"\n";
	process_impl_dir();
	process_switch($i_set);
	file_put_contents('cpu_switch.d', ob_get_clean());
	
	echo "Ok\n";
	
	//printf("%032b\n", get_common_mask($i_set));
	//print_r($i_set);
?>