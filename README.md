# Yharnam

Steps :

- GetCurrentDirectory
- FindFirstFile, FindNextFile
- For each files :
	- Check exe with SHGetFileInfo
	- Use MapViewOfFile (Add necessary size for our section)
	- Get info from PE headers
	- Inject new section ".ya" in PE headers
	- Overwritte entrypoint
	- Move bytes code to our section

Code64

```
ml64.exe code64.asm /link /subsystem:windows /defaultlib:"C:\Program Files (x86)\Windows Kits\8.1\Lib\winv6.3\um\x64\kernel32.lib" /entry:main
```