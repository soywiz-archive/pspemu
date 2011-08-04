module pspemu.core.cpu.tables.Utils;

// Return n tabs.
string process_name(string s) {
	string r;
	foreach (c; s) {
		if (c == '.') {
			r ~= '_';
		} else {
			r ~= cast(char)((c >= 'a' && c <= 'z') ? (c + 'A' - 'a') : c);
		}
	}
	return r;
}

// Obtains a hex string from an integer.
string getString(uint v) {
	string r; uint c = v;
	const string chars = "0123456789ABCDEF";
	while (c != 0) { r = (cast(char)chars[c % 0x10]) ~ r; c /= 0x10; }
	while (r.length < 8) r = '0' ~ r;
	return "0x_" ~ r;
}
