<?php
	$base = '..\src\core\hle\kernel';
	$overwrite = true;

	$xml = new SimpleXMLElement(file_get_contents('psplibdoc.xml'));
	
	foreach ($xml->xpath('/PSPLIBDOC/PRXFILES/PRXFILE') as $prxfile) {
		$prxFile = (string)$prxfile->PRX;
		$prxName = (string)$prxfile->PRXNAME;
		
		@mkdir($path = $base . '/' . dirname($prxFile), 0777, true);

		$dFile = substr($prxFile, 0, strrpos($prxFile, '.')) . '.d';
		$dFFile = "{$base}/{$dFile}";
		
		echo "$prxFile...";
		
		if (!$overwrite && file_exists($dFFile)) {
			echo "Already exists\n";
			continue;
		}
		
		$f = fopen($dFFile, 'wb');
		
		fprintf($f, "module %s; // %s\n", $prxName, $prxFile);
		
		fprintf($f, "\n");
		
		$libraries = array();
		
		//echo "$prxFile $prxName\n";
		foreach ($prxfile->xpath('LIBRARIES/LIBRARY') as $library) {
			$libName  = (string)$library->NAME;
			$libFlags = (string)$library->FLAGS;
			
			fprintf($f, "class %s { // 0x%08X\n", $libName, $libFlags);
			
			$functions = array();
			
			foreach ($library->xpath('FUNCTIONS/FUNCTION') as $function) {
				$funcNID  = (string)$function->NID;
				$funcName = (string)$function->NAME;
				fprintf($f, "\tstatic void %s() { // %s\n", $funcName, $funcNID);
				fprintf($f, "\t\tthrow(new UnimplementedFunctionException(%s, \"%s\"));\n", $funcNID, $funcName);
				//fprintf($f, "\t\tthrow(new UnimplementedFunctionException());\n");
				fprintf($f, "\t}\n", $funcName);
				fprintf($f, "\t\n");
				$functions[$funcNID] = $funcName;
				//echo "$funcNID\n";
			}
			
			fprintf($f, "\tstatic this() {\n");
			fprintf($f, "\t\tsceExportLibrary(\"%s\");\n", $libName);
			fprintf($f, "\t\t\n");
			foreach ($functions as $k => $v) {
				fprintf($f, "\t\tsceExportFunction(%s, &%s);\n", $k, $v);
			}
			fprintf($f, "\t}\n");
			
			fprintf($f, "}\n");

			fprintf($f, "\n");
			
			$libraries[] = $libName;
		}
		
		fprintf($f, "static this() {\n");
		fprintf($f, "\tsceExportModule(\"%s\");\n", $prxName);
		fprintf($f, "}\n");
		
		fclose($f);
		echo "Ok\n";
	}
?>