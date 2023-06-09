#include <windows.h>
#include <stdio.h>
double size_of_files(int handle, wchar_t* parent_path);
int main()
{
	int handle;
	WIN32_FIND_DATA FindFileData;
	
	wchar_t* path = L"D:\\Steam\\*";
	handle = FindFirstFile(path, &FindFileData);
	do {
		printf("%ls\n", FindFileData.cFileName);
	} while (FindNextFile(handle, &FindFileData));

	handle = FindFirstFile(path, &FindFileData);
	wchar_t* parent_path = L"D:\\Steam";
	printf("Total: %lf MB\n", size_of_files(handle, parent_path));
	return 0;
}