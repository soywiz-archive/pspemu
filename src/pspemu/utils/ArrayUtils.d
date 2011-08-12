module pspemu.utils.ArrayUtils;

/*
void removeNullsInplace(T)(ref T[] itemList) {
	T[] itemList2;
	foreach (item; itemList) {
		if (item !is null) {
			itemList2 ~= item;
		}
	}
	delete itemList;
	itemList = itemList2;
}
*/
void removeNullsInplace(T)(ref T[] itemList) {
	int moveOffset = 0;
	for (int n = 0; n < itemList.length; n++) {
		if (itemList[n] is null) {
			moveOffset--;			
		} else if (moveOffset) {
			itemList[n + moveOffset] = itemList[n];
		}
	}
	itemList.length += moveOffset; 
}
