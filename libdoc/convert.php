<?php
	$xml = new SimpleXMLElement(file_get_contents('psplibdoc.xml'));
	$list = $xml->xpath('/PSPLIBDOC/PRXFILES/PRXFILE/LIBRARIES/LIBRARY');
	foreach ($list as $xml_e) {
		$name = (string)$xml_e->NAME;
		echo "$name\n";
		foreach ($xml_e->FUNCTIONS->children() as $xml_f) {
			list($nid, $name) = array($xml_f->NID, $xml_f->NAME);
			echo "  $nid, $name\n";
		}
	}
?>