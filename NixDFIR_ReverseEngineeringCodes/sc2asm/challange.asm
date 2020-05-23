; tiny.asm

BITS 32

;
; MZ header
;
; The only two fields that matter are e_magic and e_lfanew

mzhdr:
    dw "MZ"                       ; e_magic
    dw 0                          ; e_cblp UNUSED
    dw 0                          ; e_cp UNUSED
    dw 0                          ; e_crlc UNUSED
    dw 0                          ; e_cparhdr UNUSED
    dw 0                          ; e_minalloc UNUSED
    dw 0                          ; e_maxalloc UNUSED
    dw 0                          ; e_ss UNUSED
    dw 0                          ; e_sp UNUSED
    dw 0                          ; e_csum UNUSED
    dw 0                          ; e_ip UNUSED
    dw 0                          ; e_cs UNUSED
    dw 0                          ; e_lsarlc UNUSED
    dw 0                          ; e_ovno UNUSED
    times 4 dw 0                  ; e_res UNUSED
    dw 0                          ; e_oemid UNUSED
    dw 0                          ; e_oeminfo UNUSED
    times 10 dw 0                 ; e_res2 UNUSED
    dd pesig                      ; e_lfanew

;
; PE signature
;

pesig:
    dd "PE"

;
; PE header
;

pehdr:
    dw 0x014C                     ; Machine (Intel 386)
    dw 1                          ; NumberOfSections
    dd 0x4545BE5D                 ; TimeDateStamp UNUSED
    dd 0                          ; PointerToSymbolTable UNUSED
    dd 0                          ; NumberOfSymbols UNUSED
    dw opthdrsize                 ; SizeOfOptionalHeader
    dw 0x103                      ; Characteristics (no relocations, executable, 32 bit)

;
; PE optional header
;

filealign equ 1
sectalign equ 1

%define round(n, r) (((n+(r-1))/r)*r)

opthdr:
    dw 0x10B                      ; Magic (PE32)
    db 8                          ; MajorLinkerVersion UNUSED
    db 0                          ; MinorLinkerVersion UNUSED
    dd round(codesize, 1) ; SizeOfCode UNUSED
    dd 0                          ; SizeOfInitializedData UNUSED
    dd 0                          ; SizeOfUninitializedData UNUSED
    dd start                      ; AddressOfEntryPoint
    dd code                       ; BaseOfCode UNUSED
    dd round(filesize, 1) ; BaseOfData UNUSED
    dd 0x400000                   ; ImageBase
    dd 1                  ; SectionAlignment
    dd 1                  ; FileAlignment
    dw 4                          ; MajorOperatingSystemVersion UNUSED
    dw 0                          ; MinorOperatingSystemVersion UNUSED
    dw 0                          ; MajorImageVersion UNUSED
    dw 0                          ; MinorImageVersion UNUSED
    dw 4                          ; MajorSubsystemVersion
    dw 0                          ; MinorSubsystemVersion UNUSED
    dd 0                          ; Win32VersionValue UNUSED
    dd round(filesize, 1) ; SizeOfImage
    dd round(hdrsize, 1)  ; SizeOfHeaders
    dd 0                          ; CheckSum UNUSED
    dw 2                          ; Subsystem (Win32 GUI)
    dw 0x400                      ; DllCharacteristics UNUSED
    dd 0x100000                   ; SizeOfStackReserve UNUSED
    dd 0x1000                     ; SizeOfStackCommit
    dd 0x100000                   ; SizeOfHeapReserve
    dd 0x1000                     ; SizeOfHeapCommit UNUSED
    dd 0                          ; LoaderFlags UNUSED
    dd 16                         ; NumberOfRvaAndSizes UNUSED

;
; Data directories
;

    times 16 dd 0, 0

opthdrsize equ $ - opthdr

;
; PE code section
;

    db ".text", 0, 0, 0           ; Name
    dd codesize                   ; VirtualSize
    dd round(hdrsize, 1)  ; VirtualAddress
    dd round(codesize, 1) ; SizeOfRawData
    dd code                       ; PointerToRawData
    dd 0                          ; PointerToRelocations UNUSED
    dd 0                          ; PointerToLinenumbers UNUSED
    dw 0                          ; NumberOfRelocations UNUSED
    dw 0                          ; NumberOfLinenumbers UNUSED
    dd 0x60000020                 ; Characteristics (code, execute, read) UNUSED

hdrsize equ $ - $$

;
; PE code section data
;

align filealign, db 0

code:

; Entry point

start:

; .text ; the challenge is in here:

db 0x31, 0xF6, 0x56, 0x64, 0x8B, 0x76, 0x30, 0x8B, 0x76, 0x0C, 0x8B, 0x76, 0x1C, 0x8B, 0x6E, 0x08
db 0x8B, 0x36, 0x8B, 0x5D, 0x3C, 0x8B, 0x5C, 0x1D, 0x78, 0x01, 0xEB, 0x8B, 0x4B, 0x18, 0x67, 0xE3
db 0xEC, 0x8B, 0x7B, 0x20, 0x01, 0xEF, 0x8B, 0x7C, 0x8F, 0xFC, 0x01, 0xEF, 0x31, 0xC0, 0x99, 0x32
db 0x17, 0x66, 0xC1, 0xCA, 0x01, 0xAE, 0x75, 0xF7, 0x66, 0x81, 0xFA, 0x2A, 0xB6, 0x74, 0x09, 0x66
db 0x81, 0xFA, 0xAA, 0x1A, 0xE0, 0xDB, 0x75, 0xC5, 0x8B, 0x53, 0x24, 0x01, 0xEA, 0x0F, 0xB7, 0x14
db 0x4A, 0x8B, 0x7B, 0x1C, 0x01, 0xEF, 0x03, 0x2C, 0x97, 0x85, 0xF6, 0x74, 0x15, 0x68, 0x33, 0x32
db 0x20, 0x20, 0x68, 0x75, 0x73, 0x65, 0x72, 0x54, 0xFF, 0xD5, 0x95, 0x31, 0xF6, 0xE9, 0xA0, 0xFF
db 0xFF, 0xFF, 0x56, 0x68, 0x72, 0x6C, 0x64, 0x21, 0x68, 0x6F, 0x20, 0x77, 0x6F, 0x68, 0x48, 0x65
db 0x6C, 0x6C, 0x54, 0x87, 0x04, 0x24, 0x50, 0x50, 0x56, 0xFF, 0xD5, 0xCC

codesize equ $ - code

filesize equ $ - $$
