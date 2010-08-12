<?php

if (count($argv) < 3) {
	die("convert_value_mask_to_string.php <value> <mask>");
}

function normalizeValue($hexstr) {
	if (strpos($hexstr, '0x') === 0) $hexstr = substr($hexstr, 2);
	return hexdec($hexstr);
}

$value = normalizeValue($argv[1]);
$mask  = normalizeValue($argv[2]);
$str = str_repeat('@', 32);
printf("%08X %08X\n", $value, $mask);
for ($n = 31; $n >= 0; $n--) {
	if ($mask & 1) {
		$str[$n] = ($value & 1) ? '1' : '0';
	} else {
		$str[$n] = '-';
	}
	$value >>= 1;
	$mask  >>= 1;
}
echo "$str\n";