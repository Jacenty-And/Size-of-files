# Rozmiar-plików
Architektura Komputerów, funkcja zwracająca rozmiar wszystkich plików w danym folderze
---
Napisz w 32-bitowym asemblerze funkcje przystosowaną do wywołania z poziomu języka C, która zwróci wartość wyrażającą łączny rozmiar wszystkich plików znajdujących się w zadanym katalogu. Prototyp funkcji jest następujący:
```
double size_of_files(int handle, wchar_t* parent_path); 
```
Przekazany parametr *handle* został wcześniej pozyskany w wyniku wywołania funkcji *FindFirstFile* (patrz dalsze przykłady i opis), zaś drugi parametr to łańcuch znaków UTF-16 z nazwą katalogu do przeszukania. W celu uzyskania rozmiaru pliku należy wywoływać funkcję *FindNextFile*, która wypełnia strukturę *WIN32_FIND_DATA* metadanymi o pliku. W tej strukturze pole *dwFileAttributes* o offsecie 0 umożliwia określenie czy plik jest plikiem zwykłym czy katalogiem (ustawiony bit 4 wskazuje na katalog). Pola o offsetach +28 i +32 (*nFileSizeHigh*, *nFileSizeLow*) wyrażają rozmiar pliku (w bajtach), w formie 64-bitowej liczby. Zwracany wynik funkcji *size_of_files* ma wyrażać rozmiar w MB jako 64-bitową liczbę zmiennoprzecinkową.  
<sub>Uwaga: zakładamy, że pełna ścieżka do dowolnego pliku nie przekroczy 1024 bajtów.</sub>  

Przykładowe wywołanie tworzonej funkcji w języku C:
```
int handle = FindFirstFile(L"C:\\some\\folder\\*", &FindFileData); 
printf("Total: %lf\n", size_of_files(handle, "C:\\some\\folder"));
```

---

Opis funkcji:
```
int FindFirstFile {
  [in]  wchar_t*         FileName,
  [out] WIN32_FIND_DATA* FindFileData
};
```
Funkcja zwraca uchwyt (wyrażony jako liczba 32-bitowa) dla dalszych poszukiwań plików, które przynależą do katalogu *FileName* (pierwszy parametr). Struktura *FindFileData* zawiera metadane opisujące sam katalog.  
  
```
BOOL FindNextFile {
  [in]  int              FindFileHandle,
  [out] WIN32_FIND_DATA* FindFileData
};
```
Funkcja zwraca wartość *true* jeśli odnaleziono kolejny plik w katalogu o danym uchwycie *FindFileHandle* lub *false* jeśli nie znaleziono więcej plików. Struktura *FindFileData* zawiera metadane opisujące kolejny, odnaleziony plik.
```
typedef struct _WIN32_FIND DATA {
  DWORD   dwFileAttributes;       //atrybuty pliku
  QWORD   ftCreationTime;         //czas utworzenia pliku
  QWORD   ftLastAccessTime:       //czas ostatniego dostępu do pliku
  QWORD   ftLastWriteTime;        //czas ostatniego zapisu do pliku
  DWORD   nFileSizeHigh;          //pola rozmiaru
  DWORD   nFileSizeLow;      
  DWORD   dwReserved0;            // pola zarezerwowane
  DWORD   dwReserved1;
  wchar_t cFileName [260];        // nazwa pliku
  wchar_t cAlternateFileName[14]; // krótka nazwa pliku
}
```