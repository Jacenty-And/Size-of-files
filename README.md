# Size-of-files
Computer Architecture, assembly function that returns the size of all files in a given directory 
---
Write a function in 32-bit assembler adapted to be called from the C language level that returns a value expressing the total size of all files contained in a given directory. The prototype of the function is as follows:  
```
double size_of_files(int handle, wchar_t* parent_path); 
```
The *handle* parameter passed was previously obtained by calling the *FindFirstFile* function (see further examples and description), and the second parameter is a UTF-16 character string with the name of the directory to be searched. To obtain the file size, the *FindNextFile* function must be called, which fills the *WIN32_FIND_DATA* structure with metadata about the file. In this structure, the *dwFileAttributes* field with offset 0 allows you to specify whether the file is a regular file or a directory (bit 4 when set indicates a directory). The fields with offsets +28 and +32 (*nFileSizeHigh*, *nFileSizeLow*) express the size of the file (in bytes), as a 64-bit number. The returned result of the *size_of_files* function is to express the size in MB as a 64-bit floating point number.  
<sub>Note: we assume that the full path to any file will not exceed 1024 bytes.</sub>  

Example of a call to a created function in C:  
```
int handle = FindFirstFile(L"C:\\some\\folder\\*", &FindFileData); 
printf("Total: %lf\n", size_of_files(handle, "C:\\some\\folder"));
```

---

Function description:  
```
int FindFirstFile {
  [in]  wchar_t*         FileName,
  [out] WIN32_FIND_DATA* FindFileData
};
```
The function returns a handle (expressed as a 32-bit number) for further searches for files that belong to the *FileName* directory (first parameter). The *FindFileData* structure contains metadata describing the directory itself.  
  
```
BOOL FindNextFile {
  [in]  int              FindFileHandle,
  [out] WIN32_FIND_DATA* FindFileData
};
```
The function returns *true* if the next file in the directory with the given *FindFileHandle* was found, or *false* if no more files were found. The *FindFileData* structure contains metadata describing the next file found.
```
typedef struct _WIN32_FIND DATA {
  DWORD   dwFileAttributes;       //file attributes
  QWORD   ftCreationTime;         //file creation time
  QWORD   ftLastAccessTime:       //last time the file was accessed
  QWORD   ftLastWriteTime;        //time of last writing to file
  DWORD   nFileSizeHigh;          //size fields
  DWORD   nFileSizeLow;      
  DWORD   dwReserved0;            //reserved fields
  DWORD   dwReserved1;
  wchar_t cFileName [260];        //filename
  wchar_t cAlternateFileName[14]; //short filename
}
```
