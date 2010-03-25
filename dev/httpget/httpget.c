// tiny_impdef.exe winhttp -o lib\winhttp.def
// tcc -lwinhttp -run httpget.c
// tcc httpget.c -lwinhttp

//#include <Winhttp.h>
#include <windows.h>
#include <stdio.h>

typedef LPVOID HINTERNET;
typedef int INTERNET_SCHEME;
#define INTERNET_SCHEME_HTTP        (1)
#define INTERNET_SCHEME_HTTPS       (2)
typedef WORD INTERNET_PORT;

#define __in_ecount(v)
#define __in
#define __inout

typedef struct {
    DWORD   dwStructSize;       // size of this structure. Used in version check
    LPWSTR  lpszScheme;         // pointer to scheme name
    DWORD   dwSchemeLength;     // length of scheme name
    INTERNET_SCHEME nScheme;    // enumerated scheme type (if known)
    LPWSTR  lpszHostName;       // pointer to host name
    DWORD   dwHostNameLength;   // length of host name
    INTERNET_PORT nPort;        // converted port number
    LPWSTR  lpszUserName;       // pointer to user name
    DWORD   dwUserNameLength;   // length of user name
    LPWSTR  lpszPassword;       // pointer to password
    DWORD   dwPasswordLength;   // length of password
    LPWSTR  lpszUrlPath;        // pointer to URL-path
    DWORD   dwUrlPathLength;    // length of URL-path
    LPWSTR  lpszExtraInfo;      // pointer to extra information (e.g. ?foo or #foo)
    DWORD   dwExtraInfoLength;  // length of extra information
} URL_COMPONENTS, * LPURL_COMPONENTS;

HINTERNET WINAPI WinHttpOpen(IN LPCWSTR pwszUserAgent, IN DWORD dwAccessType, IN LPCWSTR pwszProxyName OPTIONAL, IN LPCWSTR pwszProxyBypass OPTIONAL, IN DWORD dwFlags);
HINTERNET WINAPI WinHttpConnect(IN HINTERNET hSession, IN LPCWSTR pswzServerName, IN INTERNET_PORT nServerPort, IN DWORD dwReserved);
HINTERNET WINAPI WinHttpOpenRequest(IN HINTERNET hConnect, IN LPCWSTR pwszVerb, IN LPCWSTR pwszObjectName, IN LPCWSTR pwszVersion, IN LPCWSTR pwszReferrer OPTIONAL, IN LPCWSTR FAR * ppwszAcceptTypes OPTIONAL, IN DWORD dwFlags);
BOOL WINAPI WinHttpSendRequest(IN HINTERNET hRequest, IN LPCWSTR pwszHeaders OPTIONAL, IN DWORD dwHeadersLength, IN LPVOID lpOptional OPTIONAL, IN DWORD dwOptionalLength, IN DWORD dwTotalLength, IN DWORD_PTR dwContext);
BOOL WINAPI WinHttpReceiveResponse(IN HINTERNET hRequest, IN LPVOID lpReserved);
BOOL WINAPI WinHttpQueryDataAvailable(IN HINTERNET hRequest, OUT LPDWORD lpdwNumberOfBytesAvailable OPTIONAL);
BOOL WINAPI WinHttpReadData(IN HINTERNET hRequest, IN LPVOID lpBuffer, IN DWORD dwNumberOfBytesToRead, OUT LPDWORD lpdwNumberOfBytesRead);
BOOL WINAPI WinHttpCloseHandle(IN HINTERNET hInternet);
BOOL WINAPI WinHttpCrackUrl(__in_ecount(dwUrlLength) LPCWSTR pwszUrl, __in DWORD dwUrlLength, __in DWORD dwFlags, __inout LPURL_COMPONENTS lpUrlComponents);

//int MultiByteToWideChar(uint CodePage, uint dwFlags, char* lpMultiByteStr, int cbMultiByte, wchar* lpWideCharStr, int cchWideChar);

int main(int argc, char* argv[]) {
	URL_COMPONENTS urlComp = {0};
	WCHAR temp[0x400 + 1]; temp[0] = 0;
	WCHAR url[0x400 + 1]; url[0] = 0;
	HINTERNET hSession, hConnect, hRequest;
	char buffer[0x8000];
	FILE *f;
	DWORD dwSize = 0, dwDownloaded = 0;

    urlComp.dwSchemeLength    = -1;
    urlComp.dwHostNameLength  = -1;
    urlComp.dwUrlPathLength   = -1;
    urlComp.dwExtraInfoLength = -1;
	urlComp.dwStructSize = sizeof(urlComp);

	if (argc < 3) {
		fwprintf(stderr, L"httpget.exe <url> <file>\n");
		return -1;
	}

	url[0] = 0; MultiByteToWideChar(CP_ACP, MB_COMPOSITE, argv[1], -1, url, sizeof(url) / sizeof(url[0]));
	if (!WinHttpCrackUrl(url, wcslen(url), 0, &urlComp)) {
		fwprintf(stderr, L"error parsing the url!\n");
		return -1;
	}

	if ((urlComp.nScheme != INTERNET_SCHEME_HTTP) && (urlComp.nScheme != INTERNET_SCHEME_HTTPS)) {
		fwprintf(stderr, L"Unknown scheme!\n");
		return -1;
	}
	
	// Use WinHttpOpen to obtain a session handle.
	if (!(hSession = WinHttpOpen(L"WinHTTP Example/1.0", 0, NULL, NULL, 0))) {
		fwprintf(stderr, L"Error with WinHttpOpen\n");
		return -1;
	}
	
	// Specify an HTTP server.
	wcsncpy(temp, urlComp.lpszHostName, urlComp.dwHostNameLength); temp[urlComp.dwHostNameLength] = 0;
	if (!(hConnect = WinHttpConnect(hSession, temp, 80, 0))) {
		fwprintf(stderr, L"Error with WinHttpConnect '%s'\n", temp);
		return -1;
	}

	// Create an HTTP request handle.
	wcsncpy(temp, urlComp.lpszUrlPath, urlComp.dwUrlPathLength + urlComp.dwExtraInfoLength); temp[urlComp.dwUrlPathLength + urlComp.dwExtraInfoLength] = 0;
	if (!(hRequest = WinHttpOpenRequest(hConnect, L"GET", temp, NULL, NULL, NULL, 0))) {
		fwprintf(stderr, L"Error with WinHttpOpenRequest '%s'\n", temp);
		return -1;
	}

	// Send a request.
	if (!WinHttpSendRequest(hRequest, NULL, 0, NULL, 0, 0, 0)) {
		fwprintf(stderr, L"Error with WinHttpSendRequest\n");
		return -1;
	}

	// End the request.
	if (!WinHttpReceiveResponse(hRequest, NULL)) {
		fwprintf(stderr, L"Error with WinHttpSendRequest\n");
		return -1;
	}

	if ((f = fopen(argv[2], "wb")) == NULL) {
		fprintf(stderr, "Error opening file '%s'\n", argv[2]);
		return -1;
	}
	// Keep checking for data until there is nothing left.
	do  {
		// Check for available data.
		if (!WinHttpQueryDataAvailable(hRequest, &dwSize)) {
			fwprintf(stderr, L"Error %u in WinHttpQueryDataAvailable.\n", GetLastError());
			return -1;
		}
		if (dwSize > sizeof(buffer)) dwSize = sizeof(buffer);

		if (!WinHttpReadData(hRequest, buffer, dwSize, &dwDownloaded)) {
			fwprintf(stderr, L"Error %u in WinHttpReadData.\n", GetLastError());
			return -1;
		}
		fwrite(buffer, 1, dwDownloaded, f);
	} while (dwSize > 0);

	// Close any open handles.
	fclose(f);
	WinHttpCloseHandle(hRequest);
	WinHttpCloseHandle(hConnect);
	WinHttpCloseHandle(hSession);
}