extendbuffer	equ 512
bootbuffer	equ 1024

.model small
.stack 200h


;ЩЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЛ
;К				Data Segment				     К
;ШЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭМ

_DATA		segment	public

;------------ Buffers ------------

MBRloader       label
DB 033h,0C0h,08Eh,0D0h,0BCh,000h,07Ch,0FBh,050h,007h,050h,01Fh,0FCh,0BEh,01Bh,07Ch
DB 0BFh,01Bh,006h,050h,057h,0B9h,0E5h,001h,0F3h,0A4h,0CBh,0BEh,0BEh,007h,0B1h,004h
DB 038h,02Ch,07Ch,009h,075h,015h,083h,0C6h,010h,0E2h,0F5h,0CDh,018h,08Bh,014h,08Bh
DB 0EEh,083h,0C6h,010h,049h,074h,016h,038h,02Ch,074h,0F6h,0BEh,010h,007h,04Eh,0ACh
DB 03Ch,000h,074h,0FAh,0BBh,007h,000h,0B4h,00Eh,0CDh,010h,0EBh,0F2h,089h,046h,025h
DB 096h,08Ah,046h,004h,0B4h,006h,03Ch,00Eh,074h,011h,0B4h,00Bh,03Ch,00Ch,074h,005h
DB 03Ah,0C4h,075h,02Bh,040h,0C6h,046h,025h,006h,075h,024h,0BBh,0AAh,055h,050h,0B4h
DB 041h,0CDh,013h,058h,072h,016h,081h,0FBh,055h,0AAh,075h,010h,0F6h,0C1h,001h,074h
DB 00Bh,08Ah,0E0h,088h,056h,024h,0C7h,006h,0A1h,006h,0EBh,01Eh,088h,066h,004h,0BFh
DB 00Ah,000h,0B8h,001h,002h,08Bh,0DCh,033h,0C9h,083h,0FFh,005h,07Fh,003h,08Bh,04Eh
DB 025h,003h,04Eh,002h,0CDh,013h,072h,029h,0BEh,046h,007h,081h,03Eh,0FEh,07Dh,055h
DB 0AAh,074h,05Ah,083h,0EFh,005h,07Fh,0DAh,085h,0F6h,075h,083h,0BEh,027h,007h,0EBh
DB 08Ah,098h,091h,052h,099h,003h,046h,008h,013h,056h,00Ah,0E8h,012h,000h,05Ah,0EBh
DB 0D5h,04Fh,074h,0E4h,033h,0C0h,0CDh,013h,0EBh,0B8h,000h,000h,000h,000h,000h,000h
DB 056h,033h,0F6h,056h,056h,052h,050h,006h,053h,051h,0BEh,010h,000h,056h,08Bh,0F4h
DB 050h,052h,0B8h,000h,042h,08Ah,056h,024h,0CDh,013h,05Ah,058h,08Dh,064h,010h,072h
DB 00Ah,040h,075h,001h,042h,080h,0C7h,002h,0E2h,0F7h,0F8h,05Eh,0C3h,0EBh,074h,049h
DB 06Eh,076h,061h,06Ch,069h,064h,020h,070h,061h,072h,074h,069h,074h,069h,06Fh,06Eh
DB 020h,074h,061h,062h,06Ch,065h,000h,045h,072h,072h,06Fh,072h,020h,06Ch,06Fh,061h
DB 064h,069h,06Eh,067h,020h,06Fh,070h,065h,072h,061h,074h,069h,06Eh,067h,020h,073h
DB 079h,073h,074h,065h,06Dh,000h,04Dh,069h,073h,073h,069h,06Eh,067h,020h,06Fh,070h
DB 065h,072h,061h,074h,069h,06Eh,067h,020h,073h,079h,073h,074h,065h,06Dh,000h,000h
DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
DB 000h,000h,000h,08Bh,0FCh,01Eh,057h,08Bh,0F5h,0CBh

include fat16.inc
include fat32.inc

commandbuffer	db	128 dup (0)
commandptr	dw	0

ascnum		db	8 dup (30h),'$'

;---------------------- Titles and questions ----------------------

usage           db      'AEFDISK open source v1.0. 1997-2015 Nagy Daniel',0dh,0ah
		db	'https://github.com/nagydjol/aefdisk',0dh,0ah
                db      'Usage: aefdisk [harddisk number] [switches] <command1> [command2] ...',0dh,0ah
		db	'Commands:',0dh,0ah
                db      '/pri:<size>:<type>[:n] - create primary partition',0dh,0ah
                db      '/ext:<size>[:5][:n]    - create extended partition',0dh,0ah
                db      '/log:<size>[:type]     - create logical drive',0dh,0ah
		db	'/delete:<n>            - delete an entry',0dh,0ah
                db      '/deltype:<type>[:n]    - delete partition(s) of specified type',0dh,0ah
		db	'/delactive             - delete active partition',0dh,0ah
		db	'/delall                - delete all partitions from a disk',0dh,0ah
                db      '/notdel:<type>[,types] - delete all except specified type(s)',0dh,0ah
                db      '/activate:<n>          - activate a partition',0dh,0ah
                db      '/deactivate            - delete active flag',0dh,0ah
		db	'/changetype:<type>:<n> - change type of partition',0dh,0ah
                db      '/hidefat[:n]           - hide FAT partition(s)',0dh,0ah
                db      '/hident[:n]            - hide NTFS/HPFS partition(s)',0dh,0ah
		db	'/unhidefat[:n]         - unhide FAT partition(s)',0dh,0ah
		db	'/unhident[:n]          - unhide NTFS/HPFS partition(s)',0dh,0ah
		db	'/formatfat[:n][:label] - format FAT partition, can be a switch',0dh,0ah
		db	'/allsize               - puts the HD size in ALLSIZE environment variable',0dh,0ah
		db	'/freesize              - puts size of unpartitioned space in FREESIZE',0dh,0ah
		db	'/psize:<n>             - puts n-th partition',39,'s size in PSIZEnn',0dh,0ah
		db	'/ptype:<n>             - puts n-th partition',39,'s type in PTYPEnn',0dh,0ah
		db	'----- Press any key to continue ----$'
switche		db	0dh,'/putactive             - puts active partition nr. in ACTIVE variable',0dh,0ah
		db	'/numhds                - puts number of available HDs in NUMHDS variable',0dh,0ah
		db	'/mbr                   - install the standard DOS MBR loader',0dh,0ah
		db	'/sort                  - sorts the partition table in physical order',0dh,0ah
		db	'/save:<filename>       - save MBR to file',0dh,0ah
		db	'/restore:<filename>    - restore MBR from file',0dh,0ah
		db	'/cvtarea:<n>           - create a contiguous file for NTFS conversion',0dh,0ah
		db	'/label:<n>:<label>     - create/change label on a formatted FAT partition',0dh,0ah
		db	'/info                  - show info about hardisk',0dh,0ah
		db	'/show                  - show partition table',0dh,0ah
		db	'/dump                  - hexadecimal dump of partition table',0dh,0ah
		db	'/?                     - this help message',0dh,0ah
		db	0dh,0ah,'Switches:',0dh,0ah
		db	'/rel                   - use percentages at size definition',0dh,0ah
		db	'/y                     - assume Yes on queries',0dh,0ah
		db	'/wipe                  - wipe partitions to be deleted',0dh,0ah
		db	'/reboot                - reboot when ready',0dh,0ah
		db	'/dynamic               - leave for Win2000/XP dynamic volume',0dh,0ah
		db	'/noebios               - disable EBIOS access',0dh,0ah
		db	'/nolimit               - disable FAT limit check',0dh,0ah
		db	'n is a valid partition number. From 1 to 4 it means a primary partition.',0dh,0ah
		db	'From 5 it means a logical drive. Please read the documentation for more info.'
		db	'$'

harddisk	db	'---------------- Hard disk $'
ebiosex		db	'Microsoft/IBM extended BIOS $'
notf		db	'not $'
foundstr	db	'found.',0dh,0ah,'$'
biosstr		db	'BIOS characteristics (C/H/S): $'
ebiosstr	db	'EBIOS characteristics (C/H/S): $'

created		db	'Creating partition...',0dh,0ah,'$'
formatted	db	'Formatting FAT partition...',0dh,0ah,'$'
deleted		db	'Deleting partition(s)...',0dh,0ah,'$'
delalld		db	'Deleting all partitions...',0dh,0ah,'$'
activated	db	'Setting partition active...',0dh,0ah,'$'
deactivated	db	'Deleting active flag...',0dh,0ah,'$'
changedtype	db	'Changing type ID...',0dh,0ah,'$'
hiddened	db	'Hiding FAT partition(s)...',0dh,0ah,'$'
hiddenednt	db	'Hiding NTFS/HPFS partition(s)...',0dh,0ah,'$'
unhidden	db	'Unhiding FAT partition(s)...',0dh,0ah,'$'
unhiddennt	db	'Unhiding NTFS/HPFS partition(s)...',0dh,0ah,'$'
mbrinstalled	db	'Installing MBR loader code...',0dh,0ah,'$'
S_sorting	db	'Sorting partition table...',0dh,0ah,'$'
saveMBR		db	'Saving MBR to file...',0dh,0ah,'$'
restMBR		db	'Restoring MBR from file...',0dh,0ah,'$'
labelled	db	'Creating volume label...',0dh,0ah,'$'
S_skiplabel	db	'volume is not formatted.',0dh,0ah,'$'
S_nospacelab	db	'no available directory entry found.',0dh,0ah,'$'

savedMBR	db	'New partition table has been written to disk.',0dh,0ah,'$'
notsavedMBR	db	'There were errors, quitting...$'
sizeadjust	db	'FAT is too large, size adjusted automatically',0dh,0ah,'$'

error		db	'Error: $'
warning		db	'Warning: $'

S_NTbox		db	'cannot run in WinNT/2k/XP DOS box. Run from DOS or Win9x/ME',0dh,0ah
		db	'Press a key...$'
hdnotex		db	'specified harddisk does not exist.',0dh,0ah,'$'
need386		db	'this program requires at least a 386 processor.$'
memerror	db	'not enough memory. $'
badparamstr	db      'bad command line parameter. Use /? for help.',0dh,0ah,'$'
useext		db	'use the /ext switch to create an extended partition.',0dh,0ah,'$'
cvtname		db	'CVTAREA TMP'
S_cvtareae	db	'the /cvtarea can be used with formatted FAT32 drives only.',0dh,0ah,'$'
S_cvtarea	db	'Creating cvtarea.tmp for NTFS conversion...',0dh,0ah,'$'
badrelsize	db	'size in percent must be maximum 100.',0dh,0ah,'$'
badvalue	db	'invalid value.',0dh,0ah,'$'
badtypestr	db	'invalid partition type.',0dh,0ah,'$'
badnumstr	db	'invalid partition number.',0dh,0ah,'$'
badsignature	db	'invalid partition table signature.',0dh,0ah,'$'
cinstead	db	"partition ends after 1024 cyls, changing type 'b' to 'c' or '6' to 'e'",0dh,0ah,'$'
noentry		db	'no available partition entry found.',0dh,0ah,'$'
nospace		db	'no space left for partition.',0dh,0ah,'$'
toobig		db	'partition is too large.',0dh,0ah,'$'
occupied	db	'partition entry is not empty.',0dh,0ah,'$'
noextended	db	'extended partition not found for logical drive(s).',0dh,0ah,'$'
notfatf		db	'cannot format, not FAT type.',0dh,0ah,'$'
extalready	db	'extended partition already exists.',0dh,0ah,'$'
parterrmsg	db	'Partition table has error(s). Do you want to continue? (y/N)$'
alreadyact	db	'partition is already active.',0dh,0ah,'$'
S_emptyext	db	'empty and extended partitions cannot be activated.',0dh,0ah,'$'
notFAT		db	'partition is not FAT type or already hidden.',0dh,0ah,'$'
notNT		db	'partition is not NTFS/HPFS type or already hidden.',0dh,0ah,'$'
nothidden	db	'partition is not hidden FAT type.',0dh,0ah,'$'
nothiddennt	db	'partition is not hidden NTFS/HPFS type.',0dh,0ah,'$'
overCHS		db	'attempting to write beyond 8 Gigs without EBIOS support.',0dh,0ah,'$'
noenviron	db	'not enough environment space.',0dh,0ah,'$'
S_noenv		db	'main environment space not found.',0dh,0ah,'$'
maxsize		db	'Total capacity: $'

S_primary	db	'Primary partitions:',0dh,0ah,'$'
S_logical	db	0dh,0ah,'Logical partitions: $'
showheader	db	'No ID Type              Label       Size (MB) Boot',0dh,0ah,'$'
underline	db	'ЭЭ ЭЭ ЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭ ЭЭЭЭЭЭЭЭЭЭЭ ЭЭЭЭЭЭЭЭЭ ЭЭЭЭ',0dh,0ah,'$'
minus		db	' - $'

none		db	'none',0dh,0ah,'$'
MB		db	' MB$'
kotojel		db	' - $'
allenv		db	'ALLSIZE=',8 dup (0)
freenv          db      'FREESIZE=',8 dup (0)
psenv		db	'PSIZEnn=',8 dup (0)
ptenv		db	'PTYPEnn=',4 dup (0)
actenv		db	'ACTIVE=',2 dup (0)
numhdsenv	db	'NUMHDS=',8 dup (0)
comenv		db	'COMMAND'
dos4env		db	'4DOS'
;-------- File systems ---------

fstable	dw	offset empty,offset FAT12,offset xenix1,offset xenix2
	dw	offset FAT16,offset extend,offset bigdos,offset hpfs
	dw	offset aix1,offset aix2,offset bm,offset FAT32
	dw	offset FAT32x,offset reserv,offset LBIGDOS,offset LBAext
	dw	offset opus,offset HFAT12,offset compaq,offset reserv
	dw	offset HFAT16,offset reserv,offset HBIGDOS,offset HHPFS
	dw	offset ast,2 dup (offset reserv),offset HFAT32
	dw	offset HFAT32x,offset reserv,offset HBIGx,5 dup (offset reserv)
	dw	offset necdos,19 dup (offset reserv)
	dw	offset theos,offset theoss, offset theos4,offset theose,offset pmagic
	dw	3 dup (offset reserv),offset venix,offset prisc,offset sfs
	dw	2 dup (offset reserv), 4 dup (offset eumel), 4 dup (offset reserv)
        dw      2 dup (offset qnx),offset ober,offset dmro,offset dmrw,offset cpm
	dw	offset dmwo,offset dmddo,offset ezdr,offset golden
	dw	offset drvp,4 dup (offset reserv),offset pria,4 dup (offset reserv)
        dw      offset speed,offset reserv,offset hurd
	dw	offset nov286,offset nov386,offset reserv,offset novell
	dw	offset novell,offset novell,6 dup (offset reserv)
	dw	offset dsec,4 dup (offset reserv),offset pcix
	dw	10 dup (offset reserv),offset minix1,offset linux
	dw	offset linswap,offset ext2fs,offset os2re,offset linext,offset reserv
	dw	offset hpfsm,11 dup (offset reserv),offset amoeba
	dw	offset amobad,16 dup (offset reserv),offset freebs
	dw	17 dup (offset reserv),offset bsdi,offset bsdi2
	dw	5 dup (offset reserv),offset solboot,offset reserv,offset ctos
        dw      offset drfat12,2 dup (offset reserv)
	dw	offset drfat16,offset reserv,offset drbigd,offset syrinx
	dw	16 dup (offset reserv),offset cpm86,8 dup (offset reserv)
	dw	offset ssfat12,offset reserv,offset DOSro,offset ssfat16
	dw	6 dup (offset reserv),offset beos,5 dup (offset reserv)
	dw	offset stord1,offset DOSsec
	dw	offset reserv,offset sstor,8 dup (offset reserv),offset linra
	dw	offset lanstep,offset xenbad

empty	db	'Empty$'		; 0
FAT12	db	'FAT12$'		; 1
xenix1	db	'XENIX root$'		; 2
xenix2	db	'XENIX /usr$'		; 3
FAT16	db	'FAT16$'		; 4
extend	db	'Extended$'		; 5
bigdos	db	'BIGDOS$'		; 6
hpfs	db	'HPFS/NTFS/QNX$'	; 7
aix1	db	'AIX/SplitDrive$'	; 8
aix2	db	'AIX/Coherent$'		; 9
bm	db	'OS/2 BM/OPUS$'		;0Ah
FAT32	db	'FAT32$'		;0Bh
FAT32x	db	'FAT32 LBA$'		;0Ch
					;0Dh	 - reserved
LBIGDOS db	'BIGDOS LBA$'		;0Eh
LBAext	db	'Extended LBA$'	 	;0Fh
opus	db	'OPUS$'			;10h
HFAT12	db	'Hidden FAT12$'		;11h
compaq	db	'Compaq diag.$'         ;12h
					;13h	 - reserved
HFAT16	db	'Hidden FAT16$'		;14h
					;15h	 - reserved
HBIGDOS	db	'Hidden BIGDOS$'	;16h
HHPFS	db	'Hidden HPFS$'		;17h
ast	db	'AST swap$'		;18h
					;19h-1Ah - reserved (2)
HFAT32	db	'Hidden FAT32$'		;1Bh
HFAT32x	db	'Hidden FAT32 LBA$'	;1ch
					;1dh	 - reserved
HBIGx	db	'Hidden BIGDOS LBA$'	;1eh
					;1fh-23h - reserved (5)
necdos	db	'NEC MS-DOS 3.x$'	;24h
					;25h-37h - reserved (19)
theos	db	'Theos$'		;38h
theoss  db      'Theos v4 spanned$'	;39h
theos4  db      'Theos v4 4GB$'         ;3Ah
theose  db      'Theos v4 extended$'    ;3Bh
pmagic	db	'Partition Magic$'	;3Ch
					;3Dh-3Fh - reserved (3)
venix	db	'VENIX 80286$'		;40h
prisc	db	'Personal RISC$'	;41h
sfs	db	'Dynamic disk/SFS$'	;42h
					;43h-44h - reserved (2)
eumel   db      'EUMEL/Elan$'           ;45h-48h - EUMEL (4)
                                        ;49h-4ch - reserved (4)
qnx     db      'QNX 4.x$'              ;4dh-4eh - QNX (2)
ober	db	'Oberon/QNX$'		;4fh
dmro	db	'OnTrack DM RO$'	;50h
dmrw	db	'OnTrack DM R/W$'	;51h
cpm	db	'CP/M$'			;52h
dmwo	db	'OnTrack DM WO$'	;53h
dmddo	db	'OnTrack DM DDO$'	;54h
ezdr    db      'EZ-Drive$'             ;55h
golden	db	'GoldenBow$'		;56h
drvp    db      'DrivePro$'		;57h
                                        ;58h-5Bh - reserved (4)
pria    db      'Priam EDisk$'          ;5Ch
                                        ;5Dh-60h - reserved (4)
speed	db	'SpeedStor$'		;61h
					;62h	 - reserved
hurd	db	'SysV-FS / HURD$'	;63h
nov286	db	'NetWare 286$'		;64h
nov386	db	'NetWare 3.11$'		;65h
					;66h	 - reserved
novell	db	'Novell$'		;67h-69h
					;6Ah-6Fh - reserved (6)
dsec	db	'DiskSecure$'		;70h
					;71h-74h - reserved (4)
pcix	db	'PC/IX$'		;75h
					;76h-7fh - reserved (10)
minix1	db	'Minix$'		;80h
linux	db	'Minix / Linux$'	;81h
linswap	db	'Linux swap/UFS$'	;82h
ext2fs	db	'Linux$'		;83h
os2re	db	'OS/2-renumbered$'	;84h
linext  db      'Linux extended$'	;85h
                                        ;86h - reserved
hpfsm	db	'HPFS mirrored$'	;87h
					;88h-92h - reserved (11)
amoeba	db	'Amoeba$'		;93h
amobad	db	'Amoeba BBT$'		;94h
					;95h-A4h - reserved (16)
freebs	db	'UFS - BSD$'		;A5h
					;A6h-B6h - reserved (17)
bsdi	db	'BSDI FS$'		;B7h
bsdi2	db	'BSDI swap$'		;B8h
					;B9h-BDh - reserved (5)
solboot db      'Solaris boot$'         ;BEh
                                        ;BFh - reserved
ctos    db      'CTOS / REAL/32$'       ;C0h
drfat12 db	'DRDOS - FAT12$'	;C1h
					;C2h-C3h - reserved (2)
drfat16 db	'DRDOS - FAT16$'	;C4h
					;C5h	 - reserved
drbigd  db	'DRDOS - BIGDOS$'	;C6h
syrinx  db	'Syrinx Boot$'		;C7h
					;C8h-D7h - reserved (16)
cpm86	db	'CP/M-86 / CTOS$'	;D8h
					;D9h-E0h - reserved (8)
ssfat12	db	'SpeedStor FAT12$'	;E1h
					;E2h	 - reserved
DOSro	db	'DOS read-only$'	;E3h
ssfat16	db	'SpeedStor FAT16$'	;E4h
					;E5h-EAh - reserved (6)
beos	db	'BeFS$'			;EBh
					;ECh-F0h - reserved (5)
stord1	db	'Storage Dim.$'		;F1h
DOSsec	db	'DOS 3.3+ sec.$'	;F2h
					;F3h	 - reserved
sstor	db	'SpeedStor$'		;F4h
					;F5h-FCh - reserved (8)
linra   db      'Linux RAID$'           ;FDh
lanstep	db	'LANstep$'		;FEh
xenbad	db	'Xenix BBT$'		;FFh

reserv	db	'Reserved$'

star	db	' **$'


fatntfs		dw	offset checkifFAT, offset checkifHFAT
		dw	offset checkifNTFS, offset checkifHNTFS
fatntmsg	dw	offset notFAT, offset nothidden
		dw	offset notNT, offset nothiddennt

;---------- Error messages ----------

readerror	db	'Cannot read sector. $'
writerror	db	'Cannot write sector. $'
errcode		db	'Error code: $'
nodrive		db	'No hard disk found',0dh,0ah,'$'

;----- Command line parameters ----

rel		db	'/rel'
deltype		db	'/deltype'
cvtarea		db	'/cvtarea'
pri		db	'/pri'
ext		db	'/ext'
log		db	'/log'
activate	db	'/activate'
deactivate	db	'/deactivate'
changetype	db	'/changetype'
delete		db	'/delete'
delall		db	'/delall'
delactive	db	'/delactive'
notdel          db      '/notdel'
hidep		db	'/hidefat'
hidentp		db	'/hident'
unhide		db	'/unhidefat'
unhident	db	'/unhident'
putsig		db	'/allsize'
putfree		db	'/freesize'
partsize	db	'/psize'
parttype	db	'/ptype'
pactive		db	'/putactive'
numhds		db	'/numhds'
mbrsig		db	'/mbr'
save		db	'/save'
restore		db	'/restore'
show		db	'/show'
labello		db	'/label'
dump		db	'/dump'
info		db	'/info'
wipe		db	'/wipe'
reboot		db	'/reboot'
dynamic		db	'/dynamic'
noebios		db	'/noebios'
nolimit		db	'/nolimit'
formatfat	db	'/formatfat'
sort		db	'/sort'
yes		db	'/y'

;----------- Variables ------------

FAT16sig        db      0f8h,0ffh,0ffh,0ffh
FAT32sig        db      0f8h,0ffh,0ffh,0fh,0ffh,0ffh,0ffh,0fh,0ffh,0ffh,0ffh,0fh

readint		db	0		; interrupt no for disk sector read
writeint	db	0
numodrives	db	0
actualHD	db	0
startsect	dd	0
endsect		dd	0
emptyspace	db	0
startmainext	dd	0		; start of main extended
endmainext	dd	0		; end of main extended
extendstart	dd	0		; start of actual extended partition
extendend	dd	0		; end of actual extended partition

sortsect	dd	12 dup (0)	; sorted in growing order

maxBIOS		dd	0		; max BIOS sectors

cyls		dd	0
heads		dd	0
sectors		dd	0

ebios		db	0		; EBIOS indicator

ebiosparams 	dw	0		; buffer size
		dw	0		; information flags
ecyls		dd	0		; number of physical cylinders on drive
eheads		dd	0		; number of physical heads on drive
esectors	dd	0		; number of physical sectors per track
etotal		dd	0		; total number of sectors on drive
		dd	0
		dw	0		; bytes per sector
		dd	0
                db      36 dup (0)

; packet for extended read/write

packet		db	10h		; reserved
		db	0		; reserved
blocks		dw	0		; 1 block
transpoint	dd	0		; transfer buffer pointer
firstpoint	dd	0		; pointer to first block on disk
		dd	0

win95?          db      0
logicreate?	db	0		; creating logical drive?
get1error?	db	0		; no entry or space from getfirstfree
writeit?	db	0		; should we write?
format?		db	0
label?		db	0		; need label?
reboot?		db	0		; reboot?
wipe?		db	0		; wipe?
ffat32?		db	0
nofatlimit?	db	0		; disable FAT limit?
dynamic?	db	0		; leave space for Win2k/XP dynamic?
relative?	db	0		; relative creation?
CVTbegin	dd	0		; first cluster of file
CVTsize		dd	0		; number of clusters file uses
FATcounter	dw	0		; in FAT sector pointer
FATsize		dd	0
wildcard?	db	0		; if HD number is '*'
yes?		db	0		; if yes switch is used
allprisize	dd	0		; all size in primary relative
alllogsize	dd	0		; all size in extended
psize		dd	0		; partition size in sectors
sectorptr	dd	0
tempsize	dd	0		; store the original logical size,
					; when calculating the extended outside
tempflag	dw	0		; temporary flag for any use
cutspace	dd	0		; adjustment redundancy
ptype		db	0		; partition type
notdels		db	21 dup (0)	; for notdel more (max 20)

dataend		label
		ends

GROUP DGROUP _DATA

;ЩЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЛ
;К				Code Segment				     К
;ШЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭМ

_TEXT		segment	public
.386
ASSUME cs:_TEXT, ds:_DATA

;ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ Procedures ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ

;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
;ллллллллллллллллллллллллллллл Command line  лллллллллллллллллллллллллллл
;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

commandline	proc near

		mov	ax,_DATA
		mov	es,ax			; EX points to data
		xor	ch,ch
		mov	cl,byte ptr [si]	; CX - get command lenght
		inc	si
		lea	di,commandbuffer
		rep	movsb			; copy commands
		push	es
		pop	ds			; DS points to data

		call	tolower			; lowercase command line

		call	getnumodrives
		jnc	@driveexists		; return if no HD found
		ret

@driveexists:	mov	win95?,0
		mov	ax,1600h
		int	2fh		        ; detect Win95
		cmp	al,4
		jne	notw95
		mov	win95?,1

notw95: 	lea	si,commandbuffer
		call    skipwhite
		cmp	al,'?'			; usage info?
		je	prusage
		cmp	al,'/'
		je	preexamcommand		; command?
		cmp	al,'*'
		je	HDwild			; wild?
		cmp	al,38h
		ja	badparam		; HD number?
		cmp	al,30h
		ja	HDnumber
		cmp	al,' '
		jb	prusage

badparam:	lea	dx,badparamstr		; bad parameter message
		call	perror
                ret

prusage:	lea	dx,usage		; print usage info
		call	printstring
		mov	ah,8
		int	21h
		lea	dx,switche
		call	printstring
		clc
		ret

HDwild:		mov	wildcard?,1		; treat wildcard
		inc	si
		jmp	preexamcommand

HDnumber:	mov	ah,numodrives		; check if HD number is
		add	ah,7fh			; valid
		add	al,4fh
		cmp	al,ah			; jump if OK
		jbe	existHD

		lea	dx,hdnotex		; error is no HD with that
		call	perror
		ret

existHD:	mov	actualHD,al		; save HD ID and
		inc	si
		jmp	getMBR			; jump to get MBR

preexamcommand:	mov	actualHD,80h		; if HD number is * or
		cmp	byte ptr [si+1],'?'	; not specified
		je	prusage

getMBR:		mov	bx,5*512/16
		call	allocate		; allocate mem for buffers
						; dirty exit if bad
		xor	cx,cx
		cmp	wildcard?,1		; set number of loops
		jne	notwc			; based on * or not
		mov	cl,numodrives
		jmp	@doit
notwc:		mov	cl,1

@doit:		push	cx
		call	runcommand		; execute command line on
		pop	cx			; actual HD
		jc	errordoit		; jump if error
		cmp	cx,1
		je	sken			; skip enter if only 1 HD
		call	penter			; print newline
sken:		inc	actualHD		; jump to next HD and
		lea	si,commandbuffer	; restore command line
		call	skipwhite		; pointer to the
		cmp	al,'/'			; proper place
		je	noneedskip
		inc	si
		mov	cutspace,0		; we must zero this
noneedskip:	loop	@doit
		clc
errordoit:	call	freemem
		ret

commandline	endp


;-------------- Examine commanline and apply on selected HD -------------

runcommand	proc near

		mov	commandptr,si
		call	ebios_check		; check if EBIOS available
		call	getparams		; get normal parameters too

allocok:	xor	eax,eax
		xor	bx,bx
		mov	blocks,1
		call	getsectors		; load MBR
		jnc	examtable
		ret


examtable:	call	checksignature
		call	getYswitch
		call	checktable		; check partition table
		jnc	examcommand
		ret


;----------- collect /y switch -----------

getYswitch	proc
		push	es
		push	ds
		pop	es
		mov	di,commandptr
		mov	al,'/'
		mov	cx,127
@@scanon:	repnz	scasb
		jcxz	@@noyes
		cmp	byte ptr es:[di],'y'
		jne	@@scanon
		mov	yes?,1
@@noyes:	pop	es
		ret
		endp

;----------- examine command line --------

examcommand:	mov	si,commandptr
		call	skipwhite

		mov	cx,4
		lea	di,pri
		call	examcom			; primary?
		jc	notpri
		call	createprimary
		jnc	examcommand
		ret

notpri:		mov	cx,4
		lea	di,ext
		call	examcom			; extended?
		jc	notext
		call	createextended
		jnc	examcommand
		ret

notext:		mov	cx,4
		lea	di,log
		call	examcom			; logical?
		jc	notlog
		call	createlogical
		jnc	examcommand
		ret

notlog:
		mov	cx,4
		lea	di,rel
		call	examcom
		jc	notrel			; relative?
		add	si,4
		mov	commandptr,si
		mov	relative?,1
		call	getfirstfree		; get max space boundary
		call	calcsize		; calculate max space
		call	getmaxlog		; calculate max logical space
		jmp	examcommand
notrel:
		mov	cx,7
		lea	di,delete
		call	examcom
		jc	notdelete		; delete?
		call	deletepart
		jnc	examcommand
		ret

notdelete:	mov	cx,7
		lea	di,delactive
		call	examcom
		jc	notdelact		; delete?
		call	delactpart
		jnc	examcommand
		ret



notdelact:
		mov	cx,8
		lea	di,deltype
		call	examcom			; deltype?
		jc	notdeltype
		call	deletetype
		jnc	examcomm
		ret

notdeltype:	mov	cx,8
		lea	di,cvtarea
		call	examcom			; cvtarea?
		jc	@@nocvt
		call	createcvt
		jnc	examcomm
		ret

@@nocvt:
		mov	cx,7
		lea	di,delall
		call	examcom
		jc	notdelall		; delall?
		call	delallpart
		jnc	examcomm
		ret

notdelall:	mov	cx,7
		lea	di,notdel
		call	examcom
		jc	notnotdel		; notdel?
		call	notdelpart
		jnc	examcomm
		ret

notnotdel:	mov	cx,9
		lea	di,activate
		call	examcom
		jc	notactivate		; activate?
		call	activatepart
		jnc	examcomm
		ret

notactivate:	mov	cx,11
		lea	di,deactivate
		call	examcom
		jc	notdeactivate		; deactivate?
		call	deactivatepart
		jnc	examcomm
		ret

notdeactivate:	mov	cx,11
		lea	di,changetype
		call	examcom			; changetype?
		jc	@@nochtype
		call	changetypeid
		jnc	examcomm
		ret

@@nochtype:	mov	cx,8
		lea	di,hidep
		call	examcom			; hide FAT?
		jc	nothide
		add	si,8
		mov	tempflag,0
		lea	dx,hiddened
		call	hider
		jnc	examcomm
		ret

nothide:	mov	cx,10
		lea	di,unhide
		call	examcom
		jc	notunhide		; unhide FAT?
		add	si,10
		mov	tempflag,1
		lea	dx,unhidden
		call	hider
		jnc	examcomm
		ret

notunhide:	mov	cx,7
		lea	di,hidentp
		call	examcom			; hide NTFS?
		jc	nothident
		add	si,7
		mov	tempflag,2
		lea	dx,hiddenednt
		call	hider
		jnc	examcomm
		ret

nothident:	mov	cx,9
		lea	di,unhident
		call	examcom
		jc	notunhident		; unhide NTFS?
		add	si,9
		mov	tempflag,3
		lea	dx,unhiddennt
		call	hider
		jnc	examcomm
		ret

notunhident:	mov	cx,5
		lea	di,show
		call	examcom			; show?
		jc	notshow
		call	showtable
		jnc	examcomm
		ret

notshow:	mov	cx,6
		lea	di,labello
		call	examcom			; label?
		jc	notlabel
		call	makelabel
		jnc	examcomm
		ret

notlabel:	mov	cx,5
		lea	di,dump
		call	examcom			; dump?
		jc	notdump
		call	dumptable
		clc
		ret

notdump:	mov	cx,5
		lea	di,info
		call	examcom			; info?
		jc	notinfo
		call	showinfo
		clc
		ret

notinfo:	mov	cx,10
		lea	di,formatfat
		call	examcom
		jc	notformat
		cmp	byte ptr [si+10],':'
		je	speciffor		; format?
		mov	format?,1
		add	si,10
		mov	commandptr,si
		jmp	examcommand
speciffor:	mov	format?,0
		call	doformat
		jnc	examcomm
		ret

notformat:	mov	cx,5
		lea	di,sort
		call	examcom			; sort?
		jc	notsort
		add	si,5
		mov	commandptr,si
		call	sorttable
		jnc	examcomm
		ret

notsort:	mov	cx,8
		lea	di,dynamic
		call	examcom			; Win2000/XP?
		jc	@@notw2k
		mov	dynamic?,1
		add	si,8
		mov	commandptr,si
		jmp	examcomm

@@notw2k:	mov	cx,2
		lea	di,yes			; yes? skip it
		call	examcom
		jc	@@notyes
		add	si,2
		mov	commandptr,si
		jmp	examcomm

@@notyes:	mov	cx,7
		lea	di,reboot
		call	examcom			; reboot?
		jc	notreboot
		mov     reboot?,1
		add	si,7
		mov	commandptr,si
		jmp	examcomm

notreboot:	mov	cx,5
		lea	di,wipe
		call	examcom			; wipe?
		jc	@@notwipe
		mov	wipe?,1
		add	si,5
		mov	commandptr,si
		jmp	examcomm

@@notwipe:	mov	cx,8
		lea	di,noebios
		call	examcom			; disable EBIOS?
		jc	notnoeb
		mov	ebios,0
		mov	readint,2
		mov	writeint,3
		mov	eax,cyls
		cmp	eax,1024
		jbe	noebcy

		mov	eax,1024
		mov	cyls,eax
		mul	heads
		mul	sectors
		mov	etotal,eax
		dec	eax
		mov	maxBIOS,eax

noebcy:		add	si,8
		mov	commandptr,si
		jmp	examcommand

notnoeb:	mov	cx,8
		lea	di,nolimit
		call	examcom
		jc	notnolim
		mov	nofatlimit?,1		; no FAT limit?
		add	si,8
		mov	commandptr,si
		jmp	examcommand

notnolim:	mov	cx,8
		lea	di,putsig
		call	examcom
		jc	notputs			; put all size?
                call    putallsize
                jnc     examcomm
                ret

notputs:	mov	cx,9
		lea	di,putfree
		call	examcom
		jc	nofreesize		; put free size?
                call    putfreesize
		jnc	examcomm
		ret

nofreesize:	mov	cx,7
		lea	di,numhds		; put numhds?
		call	examcom
		jc	nonumhds
		call	putnumhds
		jnc	examcomm
		ret

nonumhds:	mov	cx,6
		lea	di,partsize
		call	examcom
		jc	@@nopsizes		; put partition sizes
		call	putpartsize
		jnc	examcomm
		ret

@@nopsizes:	mov	cx,6
		lea	di,parttype
		call	examcom
		jc	@@noptypes		; put primary partition type
		call	putparttype
		jnc	examcomm
		ret

@@noptypes:	mov	cx,10
		lea	di,pactive
		call	examcom
		jc	@@nopactive		; put active partition nr.
		call	putactive
		jnc	examcomm
		ret

@@nopactive:	mov	cx,5
		lea	di,save
		call	examcom
		jc	nosaveMBR
		call	dosaveMBR		; save MBR to file?
		jnc	examcomm
		ret

nosaveMBR:	mov	cx,8
		lea	di,restore
		call	examcom
		jc	norestMBR		; restore MBR from file?
		call	dorestMBR
		jnc	examcomm
		ret

norestMBR:	mov	cx,4
		lea	di,mbrsig
		call	examcom
		jc	quitparse		; new MBR?
		call	installMBR
		jnc	examcomm
		ret

examcomm:	jmp	examcommand

quitparse:	cmp	byte ptr [si],' '
		jb	nomoreparam
		jmp	badparam

nomoreparam:    cmp     writeit?,0
                je      skipwnew
		xor	eax,eax
        	xor	bx,bx
		mov	blocks,1
		call	writesectors	; write new partition table
		jnc	exitmsg
		ret

exitmsg:	lea	dx,savedMBR
		call	printstring

skipwnew:       mov     writeit?,0
        	clc
		ret

runcommand	endp

;лллллллллллллллллллллллллл Get number of drives лллллллллллллллллллллллл
getnumodrives	proc near
;Stores number of drives to 'numodrives' variable
;returns C=1 if no HD found

		push	dx
		push	ax
		push	bx
		push	cx
		mov	ah,8
		mov	dl,80h		; get drive params
		int	13h
		pop	cx
		pop	bx
		pop	ax
@oknum:		mov	numodrives,dl
		test	dl,dl
		pop	dx
		jz	@nodrive
		clc
		ret

@nodrive:	stc
		ret

getnumodrives	endp

;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
;лллллллллллллллллллллллл Get hard disk parameter ллллллллллллллллллллллл
;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
getparams	proc near

;Reads parameter of disk

		push	si
		push	eax
		push	ebx
		push	cx
		push	dx
		mov	ah,8
		mov	dl,actualHD
		int	13h			; get parameters
		movzx	ebx,cx
		xchg	bh,bl
		shr	bh,6
		inc	bx
		mov	cyls,ebx		; number of cylinders
		and	ecx,3fh
		mov	sectors,ecx		; number of sectors
		movzx	edx,dh
		inc	edx
		mov	heads,edx		; number of heads

		mov	eax,cyls
		mul	heads
		mul	sectors
		dec	eax			; calc max BIOS
		mov	maxBIOS,eax

		cmp	ebios,1
		jne	maxout

		mov	eax,heads
		mul	sectors
		mov	ebx,eax			; EBX - sectors*heads
		mov	eax,etotal
		div	ebx			;  proper cylinder number
		mov	cyls,eax

maxout:		mov	eax,cyls		; convert etotal to
		mul	heads			; cylinder boundary
		mul	sectors
		mov	etotal,eax
dontmax:	pop	dx
		pop	cx
		pop	ebx
		pop	eax
		pop	si

		ret

		endp

;------------------------ Check AA55 signature --------------------

checksignature	proc	near
; Check partition signature. Should be called after reading a
; partition table or boot sector
		push	dx
		cmp	word ptr es:[bx+510],0aa55h
		je	@@goodsig
		mov	word ptr es:[bx+510],0aa55h
		lea	dx,badsignature
		call	pwarning
		stc
		jmp	@@badsig
@@goodsig:	clc
@@badsig:	pop	dx
		ret
		endp


;ллллллллллллллллллллллллл Print error number лллллллллллллллллллллллллл

errno		proc near

		push	ax
		lea	dx,errcode
		call	printstring
		xor	eax,eax
		pop	ax
		mov	al,ah
		xor	ah,ah			; print error number
		call	Dec2Ascii
		call	penter			; print enter
		ret

		endp

;ллллллллллллллллллллллл Lower case commandline лллллллллллллллллллллллллл

tolower		proc near

		lea	si,commandbuffer-1
nextchar:	inc	si
		mov	al,[si]
		cmp	al,' '
		jb	endline
		cmp	al,'Z'
		ja	nextchar
		cmp	al,'A'
		jb	nextchar
		add	al,'a'-'A'
		mov	[si],al
		jmp	nextchar

endline:	ret

		endp

;ллллллллллллллллллллллл Check partition table лллллллллллллллллллллллллл

checktable	proc near

		mov	di,1beh
		mov	cx,4

checknext:	push	cx
		cmp	byte ptr es:[di+4],0
		je	noparterr		; don't check if empty

		mov	eax,es:[di+8]
		cmp	eax,maxBIOS		; check if start out of BIOS
		ja	noparterr		; don't check if yes

		call	LBA2CHS
		mov	eax,es:[di+1]
		and	eax,0ffffffh
		shl	ecx,8
		mov	cl,dh
		cmp	eax,ecx			; check start value
		je	noparterror
peror:		pop	cx
		jmp	parterror

noparterror:	mov	eax,es:[di+8]
		add	eax,es:[di+0ch]
		dec	eax
		cmp	eax,maxBIOS		; check if out of CHS
		ja	noparterr
		call	LBA2CHS
		mov	eax,es:[di+5]
		and	eax,0ffffffh
		shl	ecx,8
		mov	cl,dh
		cmp	eax,ecx			; check end value
		je	noparterr
		jmp	peror

noparterr:     	pop	cx
		add	di,16
		loop	checknext

		call    checkextended		; look for extended
		jc	conterr
		call	chkextended		; check if exists
		jc	parterror

conterr:	clc
		ret

parterror:	lea	dx,parterrmsg
		call	printstring
		cmp	yes?,1
		jne	@@getkeyf
		mov	al,'Y'
		jmp	@@skipgetf
@@getkeyf:	mov	ah,1
		int	21h
@@skipgetf:	push	ax
		call	penter
		pop	ax
		and	al,0dfh
		cmp	al,'Y'
		je	conterr
		stc
		ret

		endp

;------------ Check extended partitions for errors --------

chkextended	proc near

		call	getmainextended

		mov	di,extendbuffer+1beh
		cmp	byte ptr es:[di+4],0
		je	nomorex

chknex:		mov	eax,es:[di+8]
		add	eax,extendstart
		cmp	eax,maxBIOS	; check if out of CHS
		ja	gnex
		call	LBA2CHS
		mov	eax,es:[di+1]
		and	eax,0ffffffh
		shl	ecx,8
		mov	cl,dh
		cmp	eax,ecx			; check end value
		je	chkendex
stex:		stc
		ret

chkendex:	mov	eax,es:[di+8]
		add	eax,es:[di+0ch]
		add	eax,extendstart
		dec	eax
		cmp	eax,maxBIOS	; check if out of CHS
		ja	gnex
		call	LBA2CHS
		mov	eax,es:[di+5]
		and	eax,0ffffffh
		shl	ecx,8
		mov	cl,dh
		cmp	eax,ecx			; check end value
		je	gnex
		jmp	stex

gnex:		call	getnextext
		jc	badreadex
		test	al,al
		jz	chknex

nomorex:	clc
badreadex:      mov     extendstart,0
        	ret

		endp


;ллллллллллллллллллллллл Write empty boot sector лллллллллллллллллллллллл

;In: ES:DI - entry
;    EAX - start sector

writeboot       proc
		call	fillF6boot
	      	mov	bx,bootbuffer
		mov	blocks,1
		call	writesectors		; write one sector
		jc	erbw

		cmp	byte ptr es:[di+4],0bh
		je	fat32w
		cmp	byte ptr es:[di+4],1bh	; if FAT32, we need to
		je	fat32w			; write two more, plus
		cmp	byte ptr es:[di+4],0ch	; backup
		je	fat32w
		cmp	byte ptr es:[di+4],1ch
		jne	nomoref6

fat32w:		inc	eax
		mov	blocks,2
		call	writesectors		; write two more
		jc	erbw
		add	eax,5
		mov	blocks,3
		call	writesectors		; write backup
		jc	erbw
nomoref6:	clc
erbw:		ret
                endp

;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
;----------------- get available entry and starting sector --------------
;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

getfirstfree	proc near
;Out: startsect   - starting sector of largest free block
;     endsect     - ending sector of largest free block
;     emptyspace  - empty partition number

		push	eax
		push	si
		push	di
		mov	di,1beh
		lea	si,sortsect
		mov	eax,sectors
		dec	eax
		mov	[si],eax		; the first pseudo partition
		mov	[si+4],eax		; begins and ends on the
		add	si,8			; last sector of head 0

		xor	bx,bx			; counter

		mov	cx,4
addnext:	cmp	byte ptr es:[di+4],0
		jz	emptyentry		; don't add if empty
		mov	eax,es:[di+8]
		mov	[si],eax
		add	si,4			; store starting
		add	eax,es:[di+0ch]
		dec	eax
		mov	[si],eax
		add	si,4			; store ending
		inc	bx
emptyentry:	add	di,16
		loop	addnext

        	mov	eax,etotal		; fill absolute ending
		mov	[si],eax		; sector value


;-- examine allocated entries

		test	bx,bx
		jz	emptytable		; jump if no entries
		cmp	bx,1
		je	skipsort		; skip sort if only 1
		cmp	bx,4
		je	noavailable		; jump if no more space

; now begin sorting

		mov	cx,3

sortagain:	push	cx
		mov	cx,bx
		lea	si,sortsect

sortnext:	mov	eax,[si]		; get starting
		cmp	eax,[si+8]		; compare with next starting
		jb	skipit			; skip is first is smaller
		mov	edx,[si+8]		; else exchange the numbers
		mov	[si+8],eax
		mov	[si],edx
		mov	eax,[si+4]
		mov	edx,[si+12]
		mov	[si+12],eax
		mov	[si+4],edx

skipit:		add	si,8
		loop	sortnext

		pop	cx
		loop	sortagain

;-- find largest empty space

skipsort:	call	findlargest

;-- first empty entry

seekentry:	mov	cx,4
		mov	di,1beh+4
		xor	ah,ah
findempty:	mov	al,es:[di]
		test	al,al
		jz	emptye
		inc	ah
		add	di,16
		loop	findempty

;-- error if no free entry

noavailable:	mov	get1error?,0
		stc
		jmp	exitfseek

;-- fill these if table is empty

emptytable:	mov	eax,sectors
		mov	startsect,eax		; starting sector (on head 1)
		mov	eax,etotal
		dec	eax
		mov	endsect,eax		; ending sector
		xor	ax,ax

;--

emptye:		mov	emptyspace,ah
		mov	eax,endsect
		sub	eax,startsect
		clc
		jnz	exitfseek

		mov	get1error?,1		; no available space
		stc

exitfseek:	pop	di
		pop	si
		pop	eax
		ret

		endp

;-------------------------- Seek largest space -------------------

findlargest	proc near
; BX - number of occupied entries
; Out: startsect - starting sector of largest space
;      endsect   - ending sector

		mov	eax,sectors
		dec	eax
		mov	startsect,eax		; to prevent creating
		mov	endsect,eax		; partition in pseudo space

		mov	cx,bx
		inc	cx			; because we inserted a zero
		lea	si,sortsect+4		; partiton at the beginning

findlarge:	mov	edx,endsect
		sub	edx,startsect
		mov	eax,[si+4]		; next starting
		sub	eax,[si]		; - current ending
		cmp	eax,sectors
		jbe	notlarger		; jump if only max sec per h
		cmp	eax,edx
		jbe	notlarger

		mov	eax,[si]
		inc	eax
		mov	startsect,eax
		mov	eax,[si+4]
		dec	eax
		mov	endsect,eax

notlarger:	add	si,8
		loop	findlarge
                ret
                endp

;----------------------------------------------------
get&seek	proc	near

;IN:  emptyspace - selected partition
;OUT: DI - points to selected partition entry

		push	ax
		mov	ah,emptyspace
		mov	di,1beh
		mov	al,16
		mul	ah
		add	di,ax		; DI - points to selected entry
		pop	ax
		ret

		endp

;---------------------------------------
examcom:	push	si
		push	es

		push	ds
		pop	es
		rep	cmpsb
		je	paramok
		stc
		jmp	notthis
paramok:	clc

notthis:	pop	es
		pop	si
		ret

;-------------------------- Wipe a partition --------------------------
;IN: startsect - absolute starting sector
;    ES:DI - partition entry
wipepart	proc
		push	es
		push	eax
		push	bx
		push	ecx
		push	di

		mov	ecx,es:[di+0ch]
		push	ecx

		mov	ah,48h
		mov	bx,16*512/16
		int	21h			; allocate memory
		jc	@@waerr
		mov	es,ax
		mov	cx,16*512
		mov	al,0ffh
		xor	di,di			; will with FF
		rep	stosb

		pop	ecx
		mov	eax,startsect
		xor	bx,bx
		mov	blocks,16
@@wloop:	cmp	ecx,16
		jbe	@@wless
		call	writesectors
		jc	@@waerr
		add	eax,16
		sub	ecx,16
		jmp	@@wloop
@@wless:	mov	blocks,cx
		call	writesectors
@@waerr:	pop	di
		pop	ecx
		pop	bx
		pop	eax
		pop	es
		ret
		endp

;-------------------------- Create primary ----------------------------

createprimary	proc near

		lea	dx,created
		call	printstring

		add	si,4
		call	checkcolon
		jnc	colok1

badpar:		lea	dx,badparamstr
		call	perror
		ret

colok1:		call	getfirstfree		; get free entry
		jnc	getcrok
		call	prgeterr
		ret

getcrok:	call	asci2dec		; get size
		jnc	okpdec
		ret

okpdec:
		cmp	relative?,1
		jne	notrelpri
		call	checkrelsize		; check if relative
		jnc	okrelpri
		ret

okrelpri:	mov	ebx,allprisize
		call	calcrel			; calculate size
		add	eax,cutspace
		jmp	calcedp

notrelpri:
		test	eax,eax			; calc largest if
		jnz	notlargest		; specified size is 0
		mov	eax,endsect
		sub	eax,startsect
		cmp	dynamic?,1
		jne	calcedp			; sub 10M if win2k
		sub	eax,20480
		jmp	calcedp
notlargest:	shl	eax,11
calcedp:	mov	psize,eax		; store size in sectors
		call	checkcolon		; get type
		jnc	coltok

baddef:		lea	dx,badtypestr
		call	perror
		ret

coltok:		call	asci2hex
		jnc	okphex
		ret
okphex:		cmp	al,5			; check if type is extended
		je	nokgoon
		cmp	al,0fh
		je	nokgoon
		jmp	okgoon

nokgoon:	lea	dx,useext		; error if yes
		call	perror
		ret

okgoon:		mov	ptype,al
		call	correctsize
		call	checkcolon		; entry defined?
		jc	nopridef

		call	checkdefined		; get entry
		jnc	nopridef
		ret

nopridef:	call	checkoccupied		; check if free
		jnc	notoccup1
		ret

notoccup1:	mov	commandptr,si
		call	get&seek		; DI - pointer to selected part

		call	fillstart		; fill starting info
		jnc	okconv1
		ret

okconv1:	call	calcend			; calculate ending sector
		jnc	oksize			; and check size
		ret

oksize:		mov	endsect,eax
		xor	edx,edx
		div	heads
		xor	edx,edx
		div	sectors
		cmp	eax,1023
		jb	@@oktyp8g
		mov	al,ptype
		cmp	al,0bh
		jne	@@notab			; correct type if cyls beyond
		mov	al,0ch			;  1023
		jmp	@@correctyp
@@notab:	cmp	al,6
		jne	@@oktyp8g
		mov	al,0eh
@@correctyp:	mov	ptype,al
		lea	dx,cinstead
		call	pwarning
		clc
@@oktyp8g:	call	fillend			; fill ending info
		jnc	okconv2
		ret

okconv2:	call	sectorbefore		; fill sectors before
                call    sectorin		; fill sectors in
		call	activateit		; set it active

		mov	eax,startsect
		call	writeboot		; write boot sector
		jnc	creok
		ret

creok:		mov	writeit?,1
		cmp	format?,1
		je	formit
		clc
		ret

formit:		call	doformat
		ret

		endp

;--------------------------- Create extended -----------------------------

createextended	proc	near

		lea	dx,created
		call	printstring

		call	checkextended		; check if already exists
		jc	noteyet
		lea	dx,extalready
		call	perror
		ret

noteyet:	add	si,4
		call	checkcolon
		jnc	colok2
		jmp	badpar
colok2:		call	getfirstfree   		; get first available entry
		jnc	getcreok
		call	prgeterr
		ret

getcreok:	mov	eax,startsect		; check if it begins on
		sub	eax,sectors		; zero cyls and correct
		jne	dontads			; if yes

		mov	eax,heads
		mul	sectors			; correct it to 0/1/1
		mov	startsect,eax
		sub	allprisize,eax
		mov	eax,sectors
		add	allprisize,eax

dontads:	call	asci2dec		; get size
		jnc	okedec
		ret
okedec:
		cmp	relative?,1		; jump if absolute
		jne	notextrel

		call	checkrelsize		; calculate relative things
		jnc	okextsiz
		ret

okextsiz:	mov	ebx,allprisize
calcre:		call	calcrel
		add	eax,cutspace
		jmp	okextsize

notextrel:
		test	ax,ax			; calc largest if
		jnz	notlargext		; specified size is 0
		mov	eax,endsect
		sub	eax,startsect
		cmp	dynamic?,1
		jne	okextsize
		sub	eax,20480		; leave 10 Mb
		jmp	okextsize
notlargext:	shl	eax,11
okextsize:	mov	psize,eax		; store size
		add	eax,startsect
		cmp	eax,1024*256*63
		jb	force5
		cmp	ebios,1
		je	ftype
force5:		mov	ptype,5			; and type
		jmp	okexttype
ftype:		mov	ptype,0fh

okexttype:	call	checkcolon		; entry defined?
		jc	noextdef
		cmp	byte ptr [si],'5'
		jne	@@nftype
		inc	si
		mov	ptype,5

		call	checkcolon
		jc	noextdef

@@nftype:	call	checkdefined		; get entry
		jnc	noextdef
		ret

noextdef:	call	checkoccupied		; check if free
		jnc	notextoc
		ret

notextoc:	mov	commandptr,si
		call	get&seek		; DI - pointer to selected part

		call	fillstart
		jnc	okconv3
		ret

okconv3:	call	calcend
		jnc	oksize2
		ret

oksize2:	mov	endsect,eax
		call	fillend
		jnc	okconv4
		ret

okconv4:	call	sectorbefore
                call    sectorin

		call	fill0boot
		mov	eax,startsect
		mov	blocks,1
		mov	bx,bootbuffer
		mov	word ptr es:[bx+510],0aa55h
		call	writesectors	; write empty extended partition
		jnc	empextok
		ret

empextok:	call	getmaxlog
		jmp	subexit

		endp

;--------------------------- Create logical --------------------------

createlogical	proc near

		lea	dx,created
		call	printstring

		call	checkextended		; check if ext exists
		jnc	exexist

		lea	dx,noextended		; error if no
		call	perror
		ret

exexist:	add	si,4
		call	checkcolon		; check ':'
		jnc	oklog
		jmp	badpar

oklog:		call	asci2dec		; get size in AX
		jnc	okldec
		ret
okldec:		mov	commandptr,si		; save command ptr

		cmp	relative?,1		; jump if absolute size
		jne	notrellog

		call	checkrelsize		; else check value
		jnc	okrellog
		ret

okrellog:	mov	ebx,alllogsize
		call	calcrel			; calculate sectors from %
		jmp	okrels

notrellog:	shl	eax,11

okrels:		mov	psize,eax		; save partition info

		mov	ptype,1
		cmp	eax,1024*16*2
		jb	jfat12			; calculate FAT type
		cmp	eax,1024*32*2		; depending on size
		jb	jfat16
		cmp	eax,1024*2048*2
		jb	BIGDOSp
		cmp	nofatlimit?,1
		je	BIGDOSp
		add	ptype,5			; FAT32
BIGDOSp:	add	ptype,2			; BIGDOS
jfat16:		add	ptype,3			; FAT16
jfat12:		call	checkcolon
		jc	@@nologdef
		call	asci2hex
		mov	ptype,al
		call	correctsize		; !!!
		mov	commandptr,si
@@nologdef:	call	getmainextended		; get main extended
		jnc	initdone
		ret

initdone:	call	getlastextend		; load last extended in chain
		jnc	getlogok		; and create if needed
		ret

getlogok:	mov	di,extendbuffer+1beh
		mov	logicreate?,1
		call	fillstart		; fill starting info
		jnc	okconv5
		ret

okconv5:	call	calcend			; calculate ending sector
                jnc     oksize3			; and check size
		ret

oksize3:	mov	endsect,eax
		call	fillend			; fill ending info
		jnc	okconv6
		ret

okconv6:	mov	logicreate?,0
		mov	eax,sectors
		mov	es:[di+8],eax

		call	sectorin		; fill sectors in

		mov	bx,extendbuffer		; write new modified extended
		mov	blocks,1
		mov	eax,extendstart
		call	writesectors		; write father partition
		jnc	writef
		ret

writef:		mov	eax,es:[di+8]
		add	eax,extendstart
		mov	startsect,eax
		call	writeboot             ; write F6
		jnc	f6oka2
		ret

f6oka2:		mov	writeit?,1
		cmp	format?,1
		je	formit2
		clc
		ret

formit2:	call	doformat
		ret

		endp

;------------ Put specified partition size in environment -----------

putpartsize	proc	near

		add	si,6
		call	checkcolon
		jnc	colpsok
		jmp	badpar

colpsok:	call	asci2dec		; get partition number
		jnc	@@okpp
		ret

@@okpp:		mov	commandptr,si
		dec	al
		mov	emptyspace,al
		call	getbootstart		; es:di => entry (for logicals too)
		jnc	@@okgps
		ret
@@okgps:	mov	al,emptyspace
		cbw
		inc	al
		aaa
		xchg	al,ah
		add	ax,3030h
		lea	si,psenv		; SI - environment variable
		mov	[si+5],ax
		mov	dx,8			; variable length
		mov	eax,es:[di+12]
		shr	eax,11
		call	putvariable		; put all size
		ret

                endp

;------------ Put specified partition type in environment -----------

putparttype	proc	near

		add	si,6
		call	checkcolon
		jnc	colptok
		jmp	badpar

colptok:	call	asci2dec		; get partition number
		jnc	@@okppt
		ret

@@okppt:	mov	commandptr,si
		dec	al
		mov	emptyspace,al
		call	getbootstart		; es:di => entry (for logicals too)
		jnc	@@okgpt
		ret
@@okgpt:	mov	al,emptyspace
		cbw
		inc	al
		aaa
		xchg	al,ah
		add	ax,3030h
		lea	si,ptenv		; SI - environment variable
		mov	[si+5],ax
		mov	dx,8			; variable length
		movzx	eax,byte ptr es:[di+4]
		call	putvariable		; put type
		ret

                endp

;------------ Put active partition number in environment -----------

putactive	proc	near

                add     si,10
        	mov	commandptr,si
                mov     emptyspace,3            ; search backwards for active
		call	get&seek		; es:di => entry (for logicals too)
                mov     eax,4
                mov     cx,4
@@chka:         cmp     byte ptr es:[di], 80h
                je      @@gota
                dec     al
                sub     di,16
                loop    @@chka
@@gota:		lea	si,actenv		; SI - environment variable
		mov	dx,7			; variable length
		call	putvariable		; put type
		ret

                endp

;--------------------- Put ALLSIZE in environment -------------------

putallsize      proc near
		add	si,8
		mov	commandptr,si
		lea	si,allenv		; SI - environment variable
		mov	dx,8			; variable length
		mov	eax,etotal
		shr	eax,11			; EAX - total size in MB
		call	putvariable		; put all size
		ret
                endp

;----------- Put specified primary partition size in environment ---------

putfreesize     proc	near
		add	si,9
		mov	commandptr,si
		call	getfirstfree
		call	calcsize
		lea	si,freenv
		mov	dx,9			; variable length
		mov	eax,allprisize
		shr	eax,11
		call	putvariable
                ret
                endp

;--------------------- Put NUMHDS in environment -------------------

putnumhds	proc	near
		add	si,7
		mov	commandptr,si
		lea	si,numhdsenv		; SI - environment variable
		mov	dx,7			; variable length
		xor	eax,eax
		mov	al,numodrives
		call	putvariable		; put numhds
		ret
                endp


;-------------------------- Delete a partition ---------------------------

deletepart	proc near

        	lea	dx,deleted	; 'sucessfully deleted'
		call	printstring

		add	si,7
		call	checkcolon
		jnc	coldelok
		jmp	badpar

coldelok:	call	asci2dec
		jnc	okdp
		ret

okdp:		dec	al
                mov     emptyspace,al
		mov	commandptr,si
		call	getbootstart            ; get pointer to partition
                jnc     @@deletepa
                ret

@@deletepa:     cmp	wipe?,1			; wipe it?
		jne	@@swip
		call	wipepart
		jnc	@@swip
		ret
@@swip:		mov	cx,16
		xor	al,al
		rep	stosb
                mov     al,emptyspace
                cmp     al,3
                jbe     @@primdeleted           ; it was a primary partition

                mov     eax,extendstart
		mov	bx,extendbuffer         ; else save extended
                mov     blocks,1
                call    writesectors
                ret

@@primdeleted:	jmp	subexit

		endp


;------------------------ Delete active partition -------------------------

delactpart	proc near

		lea	dx,deleted	; 'sucessfully deleted'
		call	printstring

		add	si,10
		call	checkcolon
		jc	acdelok
		jmp	badpar

acdelok:	mov	commandptr,si
		mov	di,1beh
		mov	cx,4
@nact:		cmp	byte ptr es:[di],80h
		je	@gotact
		add	di,16
		loop	@nact
		jmp	subexit

@gotact:        mov     eax,es:[di+8]
		mov	startsect,eax
                cmp	wipe?,1			; wipe it?
		jne	@@swip2
		call	wipepart
		jnc	@@swip2
		ret
@@swip2:        xor	al,al
		mov	cx,16
		rep	stosb
		jmp	subexit

		endp


;------------------------ Delete specified type ---------------------------

deletetype	proc near

		lea	dx,deleted	; 'sucessfully deleted'
		call	printstring

		add	si,8
		call	checkcolon
		jnc	coltok4
		jmp	badpar

coltok4:	call	asci2hex		; get type
		jnc	okdhex
		ret
okdhex:		mov	ptype,al
		call	checkcolon		; number defined?
		jc	delalltype		; jump if not
		call	checkdefined		; else delete only defined
		jnc	okp
		ret

okp:		mov	commandptr,si
		call	get&seek		; DI -> entry
		mov	al,ptype
                cmp     byte ptr es:[di+4],al
                je      delit
		jmp	baddef

delit:          mov     eax,es:[di+8]
		mov	startsect,eax
                cmp	wipe?,1			; wipe it?
		jne	@@swip3
		call	wipepart
		jnc	@@swip3
		ret
@@swip3:	mov	cx,16
		xor	al,al
		rep	stosb
		jmp	subexit

delalltype:	mov	commandptr,si
		xor	al,al			; delete all with defined type
		mov	ah,ptype
		mov	di,1beh
		mov	cx,4
nextdel:	push	cx
		cmp	es:[di+4],ah
		jne	notdelit
		mov	cx,16
		rep	stosb
		sub	di,16
notdelit:	pop	cx
		add	di,16
		loop	nextdel
                jmp     subexit
		endp


;-------------------- create cvtarea.tmp file ----------------

createcvt       proc    near

		lea	dx,S_cvtarea		; print message
		call	printstring

		add	si,8
		call	checkcolon
		jnc	@@cvtcol
		jmp	badpar

@@cvtcol:	call	asci2dec		; get partition number
		jnc	@@okcv
		ret

@@okcv:		mov	commandptr,si
		dec	al
		mov	emptyspace,al
		call	getbootstart		; get boot record position
		jnc	@@okcgbs
		ret

@@okcgbs:	call	getboot			; read boot sector
		jnc	@@okcfat32
		ret

@@okcfat32:	call	calcCVTbegin
		call	calcCVTsize

		mov	eax,dword ptr es:[bootbuffer+488+512]
		sub	eax,CVTsize		; correct free cluster count
		mov	dword ptr es:[bootbuffer+488+512],eax

                mov     eax,startsect
		mov	bx,bootbuffer
       		mov	blocks,3
		call	writesectors		; write back boot sector
		jnc	@@okbw
		ret

@@okbw:		mov	blocks,1		; from now on
		call	createentry
		jnc	@@oklab
		ret

@@oklab:	call	patchFAT
		ret
                endp

;--------------

getboot		proc
;startsect - boot record
		mov	eax,startsect
		mov	bx,bootbuffer
		mov	blocks,3
		call	getsectors
		jc	@@badf

		call	checksignature
		mov	eax,'3TAF'
		cmp	dword ptr es:[offset bootbuffer+52h],eax
		je	@@valid32
		lea	dx,S_cvtareae
		call	perror
		ret

@@valid32:	mov	eax,dword ptr es:[offset bootbuffer+36]
		mov	FATsize,eax
		clc
@@badf:		ret
		endp

;----------------

calcCVTbegin	proc
		mov	eax,es:[di+12]		; get partition size
		cmp	eax,1000000h		; is it below 8 gigs?
		jb	@@below8
		mov	eax,600000h		; start at 3GB if larger
		jmp	@@gotbeg
@@below8:	shr	eax,1			; start at middle if smaller
@@gotbeg:	xor	edx,edx
		movzx	ebx,byte ptr es:[offset bootbuffer+13]
		div	ebx
		add	eax,4			; 4th cluster is the 1st data
		mov	CVTbegin,eax
		ret
		endp


;-------------------------------------------------------------

calcCVTsize	proc
		mov	eax,es:[di+12]		; get partition size
		sub	eax,32
		sub	eax,8
		sub	eax,FATsize
		sub	eax,FATsize
		shr	eax,3			; divide by 8 to get CVTsize
		cmp	eax,800000h		; max 4 GB (this sector number)
		jbe	@@okcvtsize
		mov	eax,800000h
@@okcvtsize:	xor	edx,edx
		movzx	ebx,byte ptr es:[offset bootbuffer+13]
		div	ebx
		test	edx,edx
		jz	@@okcvtcl
		inc	eax
@@okcvtcl:	mov	CVTsize,eax		; save size in clusters
		ret
		endp

;------------

createentry	proc
		movzx	eax,byte ptr es:[offset bootbuffer+13]
		push	eax			; get sectors per cluster
		mov	eax,startsect
		add	eax,32
		add	eax,FATsize
		add	eax,FATsize
		mov	sectorptr,eax		; root entry
		mov	bx,bootbuffer
		call	getsectors		; read root directory

		lea	si,cvtname
		mov	di,bx
		mov	cx,16			; 16 entry in the first sector
@@findd:	cmp	byte ptr es:[di],0	; first an empty
		je	@@foundd
		cmp	byte ptr es:[di],0e5h	;  or deleted one
		je	@@foundd
		add	di,20h
		loop	@@findd
		sub	di,20h			; else overwrite last one:((

@@foundd:	mov	cx,11
		rep	movsb
		mov	al,20h
		stosb				; store attribute
		add	di,8
		mov	eax,CVTbegin		; cluster HI
		shr	eax,16
		stosw
		call	filedatetime		; date and time
		mov	eax,CVTbegin
		stosw				; cluster LO
		mov	eax,CVTsize
		pop	ebx			; get sectors per cluster
		xor	edx,edx
		mul	ebx
		shl	eax,9
		stosd				; file size in bytes
		
		mov	eax,sectorptr
		mov	bx,bootbuffer
		call	writesectors
		ret
		endp

;------------------------------------------------------

patchFAT	proc


@@moreFAT:	xor	edx,edx
		mov	eax,CVTbegin
		mov	ebx,128			; calc first FAT32 sector no
		div	ebx
		add	eax,32			; EAX - FAT32 sec. to read
		add	eax,startsect
		mov	sectorptr,eax
		mov	FATcounter,dx		; cluster counter in sector
		shl	edx,2			; byte offset in FAT sector
		mov	bx,bootbuffer
		call	getsectors		; get FAT sector
		mov	di,bx
		add	di,dx			; DI - byte offset in sector
		mov	eax,CVTbegin

@@injectclust:	inc	eax
		stosd
		inc	FATcounter
		dec	CVTsize
		jz	@@doneFAT
		cmp	FATcounter,128		; stay in sector
		jb	@@injectclust
		mov	CVTbegin,eax
@@wrFAT:	mov	eax,sectorptr		; update 1st FAT
		call	writesectors
		add	eax,FATsize
		call	writesectors		; update 2nd FAT
		cmp	CVTsize,0
		jnz	@@moreFAT
		ret

@@doneFAT:	sub	di,4
		mov	eax,0fffffffh
		stosd				; write EOF
		jmp	@@wrFAT

		endp

;---------------------- saveMBR --------------------------

dosaveMBR	proc	near

		lea	dx,saveMBR
		call	printstring

		add	si,5
		call	checkcolon
		jnc	@savefok
		jmp	badpar

@savefok:	mov	dx,si
@@getfend:	lodsb
		cmp	al,' '
		ja	@@getfend
		dec	si
		mov	byte ptr [si],0		; terminate filename with 0
		mov	commandptr,si

		push	ax
		mov	ah,3ch
		xor	cx,cx			; create file
		int	21h
		mov	bx,ax
		mov	ah,40h
		mov	cx,512			; write to file
		xor	dx,dx
		push	ds
		push	es
		pop	ds
		int	21h
		pop	ds
		mov	ah,3eh			; close file
		int	21h
		pop	ax
		mov	[si],al
		ret
		endp

;---------------------- restoreMBR --------------------------

dorestMBR	proc	near

		lea	dx,restMBR
		call	printstring

		add	si,8
		call	checkcolon
		jnc	@@restfok
		jmp	badpar

@@restfok:	mov	dx,si
@@getfrend:	lodsb
		cmp	al,' '
		ja	@@getfrend
		dec	si
		mov	byte ptr [si],0		; terminate filename with 0
		mov	commandptr,si

		push	ax
		mov	ax,3d00h
		xor	cx,cx			; open file
		int	21h
		mov	bx,ax
		mov	ah,3fh
		mov	cx,512			; read from file
		xor	dx,dx
		push	ds
		push	es
		pop	ds
		int	21h
		pop	ds
		mov	ah,3eh			; close file
		int	21h
		pop	ax
		mov	[si],al
		jmp	subexit
		endp

;---------------------- sort --------------------------

sorttable	proc	near

		lea	dx,S_sorting
		call	printstring

		mov	di,bootbuffer
		mov	cx,4*16
		xor	al,al
		rep	stosb

		push	ds
		push	es
		pop	ds
		mov	di,bootbuffer		; copy temporarily there
@@srtagain:	mov	cx,4			; 4 entries to examine
		xor	bx,bx
@@sortnp:	mov	si,1beh			; point to partition table
		cmp	byte ptr [si+bx+4],0
		je	@@gotohell
		mov	eax,[si+bx+8]		; get sectors before
		push	cx
		mov	cx,4
@@chkns:	cmp	eax,[si+bx+8]
		jbe	@@lower
		cmp	byte ptr [si+bx+4],0
		je	@@lower
		jmp	@@evenlower
@@lower:	add	si,16
		loop	@@chkns
		mov	cx,16
		mov	si,1beh
		add	si,bx
		rep	movsb			; copy lowest
		sub	si,16
		push	di
		mov	di,si
		mov	cx,16
		xor	al,al
		rep	stosb			; and zero it
		pop	di
		pop	cx
		jmp	@@srtagain		; begin from start

@@evenlower:	pop	cx
@@gotohell:	add	bx,16
		loop	@@sortnp
		mov	si,bootbuffer
		mov	di,1beh
		mov	cx,4*16
		rep	movsb			; copy sorted
		pop	ds
		xor	eax,eax
		mov	blocks,1
		xor	bx,bx
		call	writesectors		; write back
		ret
		endp



;---------------------- Delall --------------------------

delallpart	proc near

        	lea	dx,delalld
		call	printstring

		add	si,7
		mov	commandptr,si

        	mov	di,1beh
		mov	cx,4
@@delall:       cmp     byte ptr es:[di+4],0
                je      @@skdel
                mov     eax,es:[di+8]
                mov     startsect,eax
                cmp	wipe?,1			; wipe it?
		jne	@@swip4
		call	wipepart
		jnc	@@swip4
		ret
@@swip4:        push    cx
                mov     cx,16
		xor	al,al
		rep	stosb
		sub	di,16
                pop     cx

@@skdel:	add	di,16
		loop    @@delall

okdelalled:	jmp	subexit

		endp

;---------------------- NotDel --------------------------

notdelpart	proc near

		lea	dx,deleted
		call	printstring

		add	si,7
		call	checkcolon
		jnc	okcolnot
		jmp	badpar

okcolnot:	xor	bx,bx

nextnot:	call	asci2hex
		jnc	okndhex
		ret

okndhex:	mov	[bx+offset notdels],al
		cmp	byte ptr [si],','
		jne	donotdel
		inc	bl
		inc	si
		jmp	nextnot

donotdel:	mov	commandptr,si
		mov	cx,4
		xor	al,al
		mov	di,1beh

exanpart:	xor	bx,bx
exannext:	mov	ah,[bx+offset notdels]
		test	ah,ah
		je	dellit
		cmp	es:[di+4],ah
                je      skipent
		inc	bl
		jmp	exannext

dellit:         mov     eax,es:[di+8]
                mov     startsect,eax
                cmp	wipe?,1			; wipe it?
		jne	@@swip5
		call	wipepart
		jnc	@@swip5
		ret
@@swip5:	push	cx
		mov	cx,16
                xor     al,al
		rep	stosb
		pop	cx
		sub	di,16
skipent:	add	di,16
		loop	exanpart

		push	es
		push	ds
		pop	es
		mov	cx,20
		lea	di,notdels
		rep	stosb			; clear types field
		pop	es
		jmp	subexit
		endp


;------------------ Get boot record's absolute sector -----------------
getbootstart	proc	near
;In: AL - specified partition on command line
;Out: startsect -> partition entry
;ES:DI: entry

		cmp	al,4			; primary or logical?
		jb	primform
		call	checkextended
		jnc	readfex

		lea	dx,noextended
		call	perror
		ret

readfex:	call	getmainextended		; get main table
		mov	di,extendbuffer+1beh
		mov	al,emptyspace
		sub	al,4
		test	al,al			; is it the first logical
		jz	firsfl			; drive? Jump if yes
		movzx	cx,al
gnef:		call	getnextext
		test	al,al
		jnz	nomlf
		loop	gnef
firsfl:		mov	eax,extendstart
		add	eax,es:[di+8]
		jmp	norfn

nomlf:		lea	dx,badnumstr
		call	perror
		ret

primform:	call	get&seek
		mov	eax,es:[di+8]
norfn:		mov	startsect,eax
		clc
		ret
		endp


;ллллллллллллллллллллллллл Format FAT partition лллллллллллллллллллллллллл

doformat	proc	near

		lea	dx,formatted
		call	printstring

		cmp	format?,1
		je	lformat			; we got EAX if jump
		add	si,10
		call	checkcolon
		jnc	okcolfor
		jmp	badpar

okcolfor:	call	asci2dec		; get partition number
		jnc	@@okppf
		ret

@@okppf:	dec	al
		mov	emptyspace,al

		call	checkcolon
		jc	nolabel
		call	getlabel
		mov	label?,1

nolabel:	mov	commandptr,si
		mov	al,emptyspace
		call	getbootstart
		jc	noferr

lformat:	mov	bx,bootbuffer			; read boot sector
		mov	blocks,3			; to check if formatted
		call	getsectors
		mov	ffat32?,0
		cmp	byte ptr es:[di+4],6		; jump if bigdos
		je	okdoformat
		cmp	byte ptr es:[di+4],0eh		; jump if bigdos
		je	okdoformat
		cmp	byte ptr es:[di+4],16h		; jump if bigdos
		je	okdoformat
		cmp	byte ptr es:[di+4],1eh		; jump if bigdos
		je	okdoformat
		cmp	byte ptr es:[di+4],0bh		; jump if FAT32
		je	f1f
		cmp	byte ptr es:[di+4],1bh		; jump if FAT32
		je	f1f
		cmp	byte ptr es:[di+4],0ch		; jump if FAT32
		je	f1f
		cmp	byte ptr es:[di+4],1ch		; jump if FAT32
		jne	bfrm
f1f:		mov	ffat32?,1
		jmp	okdoformat

bfrm:		cmp	format?,1
		clc
		je	noferr

		lea	dx,notfatf
		call	perror
noferr:		ret

okdoformat:	cmp	word ptr [es:bx+1feh],0aa55h
		je	@@nofillboot		; skip fill boot if formatted
		call	calcboot
@@nofillboot:	call	calcfree

		mov	ax,es:[bootbuffer+offset secperFAT-offset bootsec16]
		mov	secperFAT,ax
		mov	eax,es:[bootbuffer+offset secperFAT32-offset bootsec32]
		mov	secperFAT32,eax

		call	saveboot
		jc	exitformat
        	call	clearFATroot

exitformat:	ret
		endp


;---------------------------- Fill boot info ------------------------------

calcboot        proc	near
		push	di
		mov	al,actualHD
		mov	drivenum,al		; fill drive number
		mov	drivenum32,al		; fill drive number
		mov	eax,heads
		mov	numheads,ax		; fill heads
		mov	numheads32,ax		; fill heads
		mov	eax,sectors
		mov	secpertrack,ax		; fill sectors per track
		mov	secpertrack32,ax	; fill sectors per track
		mov	eax,startsect
		mov	hiddensecs,eax		; fill hidden sectors
		mov	hiddensecs32,eax	; fill hidden sectors
		mov	eax,es:[di+0ch]
		mov	numsecs,eax		; fill number of sectors
		mov	numsecs32,eax		; fill number of sectors

;--- calculate sectors per cluster value ----

		cmp	ffat32?,0
		jz	spc16

;--- FAT32 ---

		mov	cl,1			; we start with Sec/Clust=1
		mov	ebx,16777216
		cmp	eax,532480		; below this, CL=1
		jb	spc32
		mov	cl,8			; the next are 8, 16, 32 and 64
@@exacl32:	cmp	eax,ebx
		jb	spc32
		shl	cl,1
		cmp	cl,64			; max Sec/Clust=64
		je	spc32
		shl	ebx,1
		jmp	@@exacl32

;--- FAT16 ---

spc16:		mov	cl,2			; start with Sec/Clust=2
		mov	ebx,262144
		cmp	eax,32680		; EAX - size in sectors
		jb	spc32
		shl	cl,1
@@exacls:	cmp	eax,ebx
		jb	spc32
		shl	cl,1
		shl	ebx,1
		jmp	@@exacls

spc32:		mov	secperclust,cl
		mov	secperclust32,cl

;---- calculate sectors per FAT value ----

		xor	edx,edx
		mov	eax,es:[di+0ch]		; get number of sectors
;--- FAT32 size ---

		movzx	ebx,reserved32
		sub	eax,ebx			; sub reserved
		movzx	ebx,secperclust32
		shl	ebx,8
		add	ebx,2
                cmp     ffat32?,0
                jz      @f16f
		shr	ebx,1
@f16f:		add	eax,ebx
		dec	eax
		div	ebx
                cmp     ffat32?,0
                jz      @f16f2
                mov	secperFAT32,eax
		jmp	sernumb


;--- FAT16 size ---

@f16f2:		mov	secperFAT,ax

;---- serial number -----

sernumb:	xor	ah,ah
		int	1ah
		shl	ecx,16
		or	ecx,edx
		rol	ecx,16
		or	ecx,edx
		mov	serialnum,ecx		; fill serial number
		mov	serialnum32,ecx		; fill serial number

                cmp     ffat32?,0
                je      @@copy16
		lea	si,bootsec32
                jmp     @@copyit
@@copy16:	lea	si,bootsec16
@@copyit:	mov	di,bootbuffer
		mov	cx,512*3		; copy boot sector
		rep	movsb
		pop	di
		ret
		endp

;------------------------- save boot sector(s) ------------------------------

saveboot	proc

		mov	eax,startsect
		mov     bx,bootbuffer
                cmp     ffat32?,0		; FAT16 or FAT32?
                jz      savfat16		; jump if 16

;--- save FAT32 ---

		mov	cx,2			; boot and backup
                mov     blocks,3

@@fbackup:	call	writesectors		; write boot sectors
                jc      wrerrr
		add	eax,6
		loop	@@fbackup
		movzx	ebx,reserved32
                add     eax,ebx
		sub	eax,2*6			; jump to FAT beginning
		clc
                jmp     wrerrr

;--- save FAT16 ---

savfat16:	mov	blocks,1
		call	writesectors		; write boot sector
		jc	wrerrr
		movzx	ebx,reserved
		add	eax,ebx
		clc
wrerrr:		ret

                endp

;-------- calculate free clusters ------

calcfree	proc	near

                cmp     ffat32?,0		; skip if FAT16
		je	@@skipif16
		mov	ebx,secperfat32
                shl     ebx,1
		movzx	eax,reserved32
                add     ebx,eax
		mov	eax,es:[di+0ch]		; all sectors
		sub	eax,ebx
		movzx	ebx,secperclust32
		xor	edx,edx
                div     ebx
		dec	eax
		mov	es:[bootbuffer+offset freeclust-offset bootsec32],eax
		mov	eax,3
		mov	es:[bootbuffer+offset nextclust-offset bootsec32],eax
@@skipif16:	ret
		endp

;------------------ Clear FATs and root sectors ----------

clearFATroot	proc near
; EAX - position of first FAT


		call	fill0boot
		mov	bx,bootbuffer		; write first FAT sector
                mov     di,bx
		mov	blocks,1		; write 1 sector
                cmp     ffat32?,0
                jz      fat16fill               ; write FAT signature

                lea     si,FAT32sig
                mov     cx,12
                rep     movsb
                jmp     beginclearFAT

fat16fill:	lea	si,FAT16sig
		mov	cx,4
		rep	movsb

beginclearFAT:	mov	cx,2			; two FATs
nextFAT:	push	cx

		call	writesectors		; first sector of FAT
		jc	badrcl

		add	bx,12			; write zero sectors
		inc	eax
                cmp     ffat32?,0
                je      wr16f
                mov     ecx,secperFAT32
                jmp     wrfb
wr16f:		mov	cx,secperFAT
wrfb:		dec	cx
writenext:	call	writesectors		; erase FAT
		jc	badrcl
		inc	eax
		loop	writenext
                sub     bx,12

FATclear:	pop	cx			; fill next FAT
		loop	nextFAT

;--- clear root directory cluster ---

                mov     cx,32
                cmp     ffat32?,0
                je      @@okfrc
                movzx	cx,secperclust32
@@okfrc:	call	fill0boot

		cmp	label?,1
		jne	okCL

		mov	di,bx
		call	createlabel		; create label and save
		call	writesectors
		jnc	@@labws
		ret

@@labws:	call	fill0boot
		dec	cx			; dec cx if written
		inc	eax			; jump to next sector
		mov	label?,0

okCL:		call	writesectors		; write empty sectors
		jc	rootclear
		inc	eax
		loop	okCL

rootclear:	ret

badrcl:         pop     cx
                ret

		endp


;ллллллллллллллллллллллллл Get volume label ллллллллллллллллллллллллллллл

getlabel	proc	near
;IN DS:SI -> label

		push	ax
		push	bx
		push	di
		push	es

		lea	di,vollabel
		mov	cx,11
		push	ds
		pop	es
		mov	al,' '			; clear label
		rep	stosb

		lea	di,vollabel
		xor	bx,bx
nextch:		lodsb
		cmp	al,' '
		jbe	endlabel
		cmp	al,'a'
		jb	okcopy
		cmp	al,'z'
		ja	okcopy
		sub	al,32			; convert to upper

okcopy:		mov	ds:[di+bx],al		; copy character
		inc	bx
		cmp	bx,12
		jb	nextch

endlabel:	push	si
		lea	si,vollabel
		lea	di,vollabel32
		mov	cx,11			; copy to FAT32 too
		rep	movsb
		pop	si
		pop	es
		pop	di
		pop	bx
		pop	ax
		ret

		endp

;лллллллллллллл Create label entry in root dir лллллллллллллллллллллллллл

createlabel	proc	near

; vollabel
; ES:DI - memory buffer to create to


		push	ax
		push	cx
		push	si
		push	di
		mov	cx,11
		lea	si,vollabel		; copy name
		rep	movsb
		mov	al,28h
		stosb
		add	di,10
		call	filedatetime
		pop	di
		pop	si
		pop	cx
		pop	ax
		ret

		endp

;---------

bcd2num		proc near

; IN - AL: BCD number
;OUT - AL: number

		push	cx
		mov	cl,al
		shr	al,4
		mov	ah,10
		mul	ah
		and	cl,15
		add	al,cl
		pop	cx

		ret
		endp

;-------------------------------------------------------------------

filedatetime	proc	near
		mov	ah,2
		int	1ah			; get time (CH, CL, DH)
		mov	al,ch
		call	bcd2num
		mov	ch,al			; CH hours

		mov	al,cl
		call	bcd2num
		mov	cl,al			; CL minutes

		mov	al,dh
		call	bcd2num
		mov	dh,al			; DL seconds
		shr	dh,2

		xor	ax,ax
		mov	al,ch
		shl	ax,6
		or	al,cl
		shl	ax,5
		or	al,dh
		stosw				; store time

		mov	ah,4
		int	1ah			; get date (CH, CL, DH, DL

		mov	al,ch
		call	bcd2num
		mov	ch,al			; century

		mov	al,cl
		call	bcd2num
		mov	cl,al			; year

		mov	al,ch
		xor	ch,ch
		mov	ah,100
		mul	ah
		add	cx,ax
		sub	cx,1980			; CX - correct year

		mov	al,dh
		call	bcd2num
		mov	dh,al

		mov	al,dl
		call	bcd2num
		mov	dl,al

		mov	ax,cx
		shl	ax,4
		or	al,dh
		shl	ax,5
		or	al,dl
		stosw				; store date
		ret
		endp


;------------------ Create label on an existing partition ---------

makelabel	proc	near

		lea	dx,labelled		; print message
		call	printstring

		add	si,6
		call	checkcolon
		jnc	okoptlab		; check 1st colon
		jmp	badpar

okoptlab:	call	asci2dec
		jnc	okplab			; get partition no.
		jmp	badpar

okplab:		dec	al
		mov	emptyspace,al
		call	checkcolon		; check 2nd colon
		jnc	@@nowlab
		jmp	badpar

@@nowlab:	cmp	byte ptr [si],' '	; check if valid label
		ja	@@goodlab
		jmp	badpar

@@goodlab:	mov	al,emptyspace

		call	getbootstart		; get boot record
		jnc	@@getlabs		; and extended position
		ret

@@getlabs:	call	checkifFAT
		jnc	@@fatlabe		; accept only FAT
		lea	dx,notFAT
		call	perror
		ret

@@fatlabe:	mov	bx,bootbuffer
		mov	blocks,1
		call	getsectors		; get its boot sector
		jnc	@@oklgs
		ret

@@oklgs:	call	checksignature		; check if formatted
		jnc	@@formlab
		lea	dx,S_skiplabel
		call	perror
		ret

@@formlab:	call	getlabel		; copy it to bootbuffers
		call	copybootlab
		mov	commandptr,si
		call	writesectors		; write boot sector
		jnc	@@lab1
		ret

@@lab1:		call	FAT16orFAT32
		jc	@@biza32

		movzx	eax,secperFAT
		movzx	ebx,reserved
		jmp	@@getrootd

@@biza32:	mov	eax,secperFAT32
		movzx	ebx,reserved32
@@getrootd:	shl	eax,1
		add	eax,ebx
		add	eax,startsect
		mov	startsect,eax
		mov	bx,bootbuffer
		mov	blocks,3		; we have allocated max 3 secs
		call	getsectors		; get 3 root dir secs
		jnc	@@chkrlab
		ret

@@chkrlab:	mov	cx,(512/32)*3		;search for existing label entry
		mov	si,bx
@@chklabn:	mov	al,es:[si+0bh]
		cmp	al,0fh			; Long name?
		je	@@skiptlab
		test	al,8
		jnz	@@gotlabspac		; label?
		mov	al,es:[si]
		cmp	al,0			; never used?
		je	@@gotlabspac
		cmp	al,0e5h			; erased?
		je	@@gotlabspac
@@skiptlab:	add	si,32
		loop	@@chklabn
		lea	dx,S_nospacelab
		call	perror
		ret

@@gotlabspac:	mov	di,si
		call	createlabel
		mov	eax,startsect		; write back root dirs
		call	writesectors
		ret

		endp

;----------------- Copy boot sector back & forth -----------------------

copybootlab	proc	near

		push	di
		push	ds
		push	es

		push	di
		mov	cx,11
		lea	si,vollabel
		call	FAT16orFAT32
		mov	di,bx
		jnc	@@ezf16
		add	di,28
@@ezf16:	add	di,offset vollabel-bootsec16
		rep	movsb		; copy label from DS to ES boot sector
		pop	di

		call	FAT16orFAT32
		push	ds
		push	es		; copy full boot sector from ES to DS
		pop	ds
		pop	es
		mov	cx,512
		mov	si,bx
		jc	@@cop32
		lea	di,bootsec16
		jmp	@@coppit
@@cop32:	lea	di,bootsec32
@@coppit:	rep	movsb
		pop	es
		pop	ds
		pop	di
		ret
		endp

;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
;-------------------- Activate --------------------

activatepart	proc near

		lea	dx,activated		; print message
		call	printstring

		add	si,9
		call	checkcolon
		jnc	okopt3
		jmp	badpar

okopt3:		call	checkdefined
		jnc	okacti
		ret

okacti:		mov	commandptr,si
		call	get&seek
		cmp	byte ptr es:[di],80h	; check if already active
		je	@@alreadact
		cmp	byte ptr es:[di+4],0	; check if empty
		je	@@emptyext
		cmp	byte ptr es:[di+4],5	; check if empty
		je	@@emptyext
		cmp	byte ptr es:[di+4],0fh	; check if empty
		je	@@emptyext

		call	activateit
		jmp	subexit

@@emptyext:	lea	dx,S_emptyext
		jmp	@@prwar

@@alreadact:	lea	dx,alreadyact		; error if yes
@@prwar:	call	pwarning
		clc
		ret


		endp


;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
;-------------------------- Deactivate ----------------------------

deactivatepart	proc near

		lea	dx,deactivated		; print message
		call	printstring

		add	si,11
		call	checkcolon		; no ':' allowed
		jc	okopt3a
		jmp	badpar

okopt3a:	mov	commandptr,si
		mov	di,1beh
		mov	cx,4
@@clra:		mov	byte ptr es:[di],0h	; delete flag
		add	di,16
		loop	@@clra
		jmp	subexit
		endp


;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
;--------------------------- Change type ID -----------------------------

changetypeid	proc

		lea	dx,changedtype
		call	printstring

		add	si,11
		call	checkcolon
		jnc	@@typcolok1
		jmp	badpar
@@typcolok1:	call	asci2hex		; get type
		jnc	@@okchid
		ret
@@okchid:	mov	ptype,al
		call	checkcolon
		jnc	@@goch
		ret
@@goch:		call	checkdefined
		jnc	@@okallch
		ret

@@okallch:	mov	commandptr,si
		call	get&seek		; DI -> entry
		mov	al,ptype
		mov     byte ptr es:[di+4],al
		jmp	subexit
		endp

;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
;----------------------------- Hide FAT -------------------------------

hider		proc	near
;IN: tempflag (0-hidefat, 1-unhidefat, 2-hident, 3-unhident)
;    DX -> message

		call	printstring

		call	checkcolon
		jc	hideall

		call	asci2dec		; get partition number
		jnc	@@okh
		ret

@@okh:		mov	commandptr,si
		dec	al
		mov	emptyspace,al
		call	getbootstart		; get boot record
		jnc	@@okjaj			; and extended position
		ret
@@okjaj:	mov 	ax,tempflag
		lea	bx,fatntfs
		shl	ax,1
		add	bx,ax
		call	[bx]
		jnc	ok2hide

		lea	bx,fatntmsg	        ; error if not that type
		add	bx,ax
		mov	dx,[bx]
		call	perror
		ret

ok2hide:	mov	ax,tempflag
		cmp	ax,0			; jump if hider
		je	@@hidethat
		cmp	ax,2
		je	@@hidethat
		sub	byte ptr es:[di+4],20h	; else unhide

@@hidethat:	add	byte ptr es:[di+4],10h
		mov	al,emptyspace
		cmp	al,4			; jump if primary
		jb	@@ok2hid
		mov	eax,extendstart
		mov	blocks,1		; else save extended
		mov	bx,extendbuffer
		call	writesectors
		ret

hideall:	mov	commandptr,si
		mov	di,1beh
		mov	cx,4
		lea	bx,ds:fatntfs
		mov	ax,tempflag
		shl	ax,1
		add	bx,ax
		shr	ax,1
hidenext:	call	[bx]
		jc	skiphide
		cmp	ax,0			; jump if hider
		je	@hidethatf
		cmp	ax,2
		je	@hidethatf
		sub	byte ptr es:[di+4],20h
@hidethatf:	add	byte ptr es:[di+4],10h
skiphide:	add	di,16
		loop	hidenext
@@ok2hid:	jmp	subexit
		endp


;ллллллллллллллллллллллл Dump partition table лллллллллллллллллллллллллллл

dumptable	proc	near
		add	si,5
		mov	commandptr,si
		mov	di,1beh
		mov	cx,4
@@dumpcol:	push	cx
		mov	cx,16
@@dumprow:	mov	bh,es:[di]
		mov	bl,bh
		shr	bh,4
		and	bl,0fh
		add	bx,3030h
		cmp	bh,'9'
		jbe	@@bhok
		add	bh,'A'-'0'-10
@@bhok:		cmp	bl,'9'
		jbe	@@blok
		add	bl,'A'-'0'-10
@@blok:		mov	ah,2
		mov	dl,bh
		int	21h
		mov	ah,2
		mov	dl,bl
		int	21h
		mov	ah,2
		mov	dl,' '
		int	21h
		inc	di
		loop	@@dumprow
		pop	cx
		call	penter
		loop	@@dumpcol
		ret
		endp

;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
;----------------------------- Show partition table ------------------------

showtable	proc near

		add	si,5
		mov	commandptr,si

		mov	startmainext,0

		call	printHDnum

		lea	dx,S_primary
		call	printstring
		lea	dx,showheader
		call	printstring
		lea	dx,underline
		call	printstring
		mov	di,1beh
		mov	cx,1			; CX - actual entry

shownext:	call	printnotype		; print no. and type

		mov	eax,es:[di+8]
		mov	bx,bootbuffer		; pre-read boot sector
		mov	blocks,1		; for volume label
		call	getsectors
		jc	badg			; print FAT16 label
		call	printlabel
		jc	badg
		call	printpsize		; print size
		mov	dl,46
		call	setcol
		cmp	byte ptr es:[di],80h
		jne	notboot
		lea	dx,star			; print if bootable
		call	printstring

notboot:        call    penter

		add	di,16
		inc	cx
		cmp	cx,4
		jbe	shownext

		lea	dx,S_logical		; get logical data
		call	printstring
		call	checkextended
		jnc	logic
		lea	dx,none			; print none if no logical
		call	printstring
		jmp	nologic

logic:		call	penter

		lea	dx,showheader
		call	printstring
		lea	dx,underline
		call	printstring
		call	getmainextended		; load main extended
		mov	cx,5			; CX - first logical

nextloginfo:	mov	di,extendbuffer+1beh
		cmp	byte ptr es:[di+4],0	; is there a partition?
		jne	ylogic			; jump if found
		call	printnotype		; print no. type
@@nep:		call	penter
		inc	cx
		call	getnextext		; else try to search embedded
		jc	badg
		test	al,al
		jnz	nologic
		jmp	nextloginfo

ylogic:		call	printnotype		; print no. type
		mov	eax,extendstart
		add	eax,es:[di+8]
		mov	bx,bootbuffer		; pre-read boot sector
		call	getsectors
		jc	badg
		call	printlabel		; print label
		jc	badg
		call    printpsize		; print size
		jmp	@@nep

nologic:	clc
		ret

badg:		stc
		ret

		endp

;-----------------------------
printnotype	proc	near
		movzx	eax,cx
		call	Dec2Ascii		; print partition no.

		mov	dl,3
		call	setcol			; set column

		mov	bl,es:[di+4]		; get type
		mov	al,bl
		call	Hex2Ascii		; print hex ID

		mov	dl,6
		call	setcol			; set column

		shl	bx,1
		lea	si,fstable		; print type
		mov	dx,[si+bx]
		call	printstring

		mov	dl,24
		call	setcol
		ret
		endp

;-----------------------------

printpsize	proc	near
		mov	dl,36
		call	setcol

		mov	eax,es:[di+0ch]
                call    printsize		; print size
		ret
		endp

;-----------------------------

printlabel	proc	near
;EAX - boot sector
;BX - bootbuffer
		push	cx
		push	di
		cmp	word ptr es:[bx+1feh],0aa55h
		jne	@@skiplabel		; skip unformatted or invalid
		mov	sectorptr,eax
		mov	al,es:[di+4]		; get type for label detection
		cmp	al,6
		je	@@fat16lab
		cmp	al,16h
		je	@@fat16lab
		cmp	al,0eh
		je	@@fat16lab
		cmp	al,1eh
		je	@@fat16lab
		cmp	al,0bh
		je	@@fat32lab
		cmp	al,1bh
		je	@@fat32lab
		cmp	al,0ch
		je	@@fat32lab
		cmp	al,1ch
		je	@@fat32lab
		cmp	al,7
		je	@@ntfslab
		cmp	al,17
		je	@@ntfslab
		jmp	@@skiplabel

@@fat16lab:	movzx	eax,word ptr es:[bx+16h]
		shl	eax,1			; 2 FATs
		jmp	@@prlab

@@fat32lab:	movzx	eax,byte ptr es:[bx+0dh]
		mov	ecx,es:[bx+2ch]
		sub	ecx,2
		mul	ecx
		mov	ecx,es:[bx+24h]		; sectors per FAT
		shl	ecx,1			; 2 FATs
		add	eax,ecx

@@prlab:	add	eax,sectorptr		; plus beginning sector
		movzx	ecx,word ptr es:[bx+0eh]
		add	eax,ecx			; plus reserved sectors
		movzx	cx,byte ptr es:[bx+13]	; examine all sects per cluster
@@nxts:		call	getsectors		; get root directory
		jc	@@prvq

		push	cx
		mov	cx,16			; scan 16 entries for label
@@searchlab:	cmp	byte ptr es:[bx],0	; empty?
		je	@@nla
		cmp	byte ptr es:[bx],0e5h	; empty?
		je	@@nla
		cmp	byte ptr es:[bx+11],8	; volume label?
		je	@@lab
		cmp	byte ptr es:[bx+11],28h	; volume label?
		je	@@lab
@@nla:		add	bx,32
		loop	@@searchlab
		pop	cx
		inc	eax
		mov	bx,bootbuffer
		loop	@@nxts
		jmp	@@skiplabel

@@lab:		pop	cx
		mov	cx,11		; show only 11 chars from volume
@@fatvolc:	mov	al,es:[bx]
		cmp	al,' '
		jb	@@skiplabel
		mov	dl,al
		mov	ah,2
		int	21h
		inc     bx
		loop	@@fatvolc
		jmp	@@skiplabel

@@ntfslab:	call	printntlabel
		jmp	@@prvq
@@skiplabel:	clc
@@prvq:		pop	di
		pop	cx
		ret
		endp

;-----------------------

printntlabel	proc	near

		mov	si,bx
		xor	eax,eax
		mov	al,es:[si+0dh]		; get sec/clust
		mul	dword ptr es:[si+30h]	; mul by MFT logical cluster
		add	eax,es:[di+8]		; add boot sector offset
		add	eax,6			; add VOLUME offset
		add	eax,extendstart		; add some if logical
		call	getsectors		; get VOLUME MFT entry
		jnc	@@okntvol
		ret

@@okntvol:	cmp	dword ptr es:[si],'ELIF'; FILE? Bad if not...
		jne	@@ntlabexit

		push	di
		add	si,150h			; ??? Guess...
		mov	cx,0b0h
		mov	al,60h			; scan for volume label ID
		mov	di,si
		repnz	scasb
		jcxz	@@skipnt
		dec	di
		mov	cx,es:[di+10h]		; get volume name length
		shr	cx,1			; it's Unicode...
		test	cx,cx
		jz	@@skipnt
		add	di,word ptr es:[di+14h]	; point to string
		mov	si,di
@@nvolc:	mov	ax,es:[si]
		cmp	al,' '
		jb	@@skipnt
		mov	dl,al
		mov	ah,2
		int	21h
		add	si,2
		loop	@@nvolc
@@skipnt:	pop	di
@@ntlabexit:	clc
		ret
		endp

;---------------- Set column ----------------

setcol		proc near
;DL - column
		push	cx

		push	dx
		mov	ah,3
		xor	bh,bh
		int	10h
		pop	cx

		xor	ch,ch
		sub	cl,dl
		mov	dl,' '
@@prspac:	mov	ah,2
		int	21h
		loop	@@prspac

		pop	cx
		ret

		endp

;ллллллллллллллллллллллл Print HD number лллллллллллллллллллллллллллллллл

printHDnum	proc near

		lea	dx,harddisk
		call	printstring
		mov	ah,2
		mov	dl,actualHD
		sub	dl,79
		int	21h
		call	penter
		ret
		endp


;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
;---------------------- Put variable in environment --------------------

putvariable	proc	near
;EAX - number
;SI - pointer to environment string
;DX - environment variable length

		push	es
		call	FindEnviron		; ES:0 -> root environment
		jnc	@@gotenv
		lea	dx,S_noenv
		jmp	@@quitenv

@@gotenv:	push	eax			; save size

		xor	al,al			; for seeking zeros
		mov	di,1			; DI - environment pointer

noenvend:	dec	di
		push	si
		push	cx
		mov	cx,dx			; get variable length
		rep	cmpsb			; compare
		pop	cx
		pop	si
		jne	noextsize		; jump if that's not ours

		push	si
		push	ds
		sub	di,dx
		push	di			; now we found and old value
		repnz	scasb
		dec	di
		mov	si,di
		pop	di
		dec	di			; DI -> zero before old value
		push	es			; overwrite old
		pop	ds
nextcp:		lodsb
		test	al,al
		jz	endenv?
nextenv:	stosb	
		jmp	nextcp
endenv?:	stosb				; store a zero
		lodsb				; examine if next is also zero
		test	al,al
		jz	endenvir		; jump if yes
		jmp	nextenv			; else move next variable

endenvir:	pop	ds
		pop	si
		jmp	copynewenv

noextsize:	repnz	scasb			; find next zero
		cmp	cx,50
		jb	notenvsp		; jump if no environment space
		scasb
		jnz	noenvend		; only one zero -> not env end
		dec	di			; else end, create new

copynewenv:	pop	eax			; get number
		call	copysize		; put it after variable name
		push	si
@@copyenv:	lodsb
		test	al,al			; put variable to environment
		jz	@@finito
		stosb
		jmp	@@copyenv

@@finito:	pop	si
		add	si,dx
		stosb				; the new is always the
		stosb				;  last, so put 2 zeros
		pop	es
		xor	eax,eax
		mov	[si],eax
		mov	[si+4],eax
		clc
		ret

notenvsp:	lea	dx,noenviron
@@quitenv:	call	perror
		pop	eax
		pop	es
		ret

		endp

;----------

copysize	proc	near
; EAX - number to store

		push	edx
		push	si		
		push	di
		mov 	di,si
		add	di,dx			; DI -> after the '=' string

		mov	ebx,0ah
		lea	si,ascnum+7

zz5:		xor	edx,edx
		div	ebx
		add	dl,30h
		mov	[si],dl
		dec	si
		or	eax,eax
		jne	zz5

		lea	si,ascnum
		mov	cx,7
nzerr:		cmp	byte ptr [si],'0'
		jne	wrnn
		inc	si
		loop	nzerr

wrnn:		inc	cx
		push	es
		push	ds
		pop	es
		rep	movsb			; copy stringed number
		pop	es
		lea	si,ascnum
		mov	eax,30303030h
		mov	[si],eax
		mov	[si+4],eax
		pop	di
		pop	si
		pop	edx
		ret

		endp

;------------------- find master environment table -----------------

FindEnviron	proc near
;Out:	ES

		push	eax
		push	bx
		push	si
		mov	ah,52h
		int	21h		; get list of lists
		mov	si,bx
		sub	si,2
		mov	ax,es:[si]	; get first MCB's segment
		mov	es,ax
                call    lookMCB
                jnc     @@findenv
        	mov	ah,52h
		int	21h
		push	ds
		lds	si,es:[bx+12h]	; get ptr to disk buffer info
		mov	ax,ds:[si+1Fh]	; get address of the first UMB
		pop	ds
		inc	ax		; (FFFF if no UMBs present)
		jz	@@noUMB
		dec	ax
		mov	es,ax
                call    lookMCB
                jnc     @@findenv
@@noUMB:	stc
		jmp	@@exitMCB

@@findenv:	mov	ax,es:[1]	; get COMMAND.COM PSP segment
		mov	es,ax
		mov	ax,es:[2ch]
		dec	ax
		mov	es,ax		; get environment segment - 1
		mov	cx,es:[3]	; get env length
		shl	cx,4
		inc	ax
		mov	es,ax
		clc
@@exitMCB:	pop	si
		pop	bx
		pop	eax
		ret

lookMCB:	cmp	byte ptr es:[0],'Z'	; final?
		je	@@noMCB
		cmp	byte ptr es:[0],'M'	; be sure it's not corrupt
		jne	@@noMCB
		mov	cx,7
		lea	si,comenv	; is it "COMMAND"?
		mov	di,8
		rep	cmpsb
                je      @@gotMCB
		mov	cx,4
		lea	si,dos4env	; is it "4DOS"?
		mov	di,8
		rep	cmpsb
		je	@@gotMCB
        	add	ax,es:[3]	; add MCB size and inc to
		inc	ax		; get next MCB's segment
		mov	es,ax
		jmp	lookMCB
@@gotMCB:       clc
                ret
@@noMCB:        stc
                ret


FindEnviron	ENDP

;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
;--------------------------- Show HD info -------------------------------
;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

showinfo	proc near

		call	printHDnum

		lea	dx,ebiosex		; extended BIOS?
		call	printstring
		cmp	ebios,1
		je	fext
		lea	dx,notf
		call	printstring
fext:		lea	dx,foundstr
		call	printstring

		cmp	ebios,1
		je	showebi

		lea	dx,biosstr
		jmp	showpa

showebi:	lea	dx,ebiosstr		; print EBIOS CHS
showpa:		call	printstring

		mov	eax,cyls
		call	printCHS		; print BIOS CHS
		mov	eax,heads
		call	printCHS
		mov	eax,sectors
		call	Dec2Ascii
		call	penter

		lea	dx,maxsize
		call	printstring
		mov	eax,etotal
		call	printsize
		lea	dx,MB
		call	printstring
		call	penter
		ret
		
		endp

;---------------------

printCHS	proc near
;EAX - number
		call	Dec2Ascii		; print number
		mov	ah,2
		mov	dl,'/'			; print '/'
		int	21h
		ret
		endp



;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
;--------------------------- Install MBR loader --------------------------

installMBR	proc near

		lea	dx,mbrinstalled
		call	printstring

		add	si,4
		mov	commandptr,si
		lea	si,MBRloader
		xor	di,di
		mov	cx,24*16+10
		rep	movsb			; copy standard loader
		mov	di,510
		mov	ax,0aa55h
		stosw				; store MBR signature

subexit:	mov	writeit?,1
		clc
		ret

		endp

;--------------------------- Print newline --------------------------

penter		proc near

        	mov	ah,2
		mov	dl,0dh			; print newline
		int	21h
		mov	dl,0ah
		int	21h
                ret

                endp

;-------------------- Correct the size based on type ---------------

correctsize	proc near
;In:  ptype
;Out: psize

		push	eax
		push	ebx

		mov	eax,sectors
		mul	heads
		mov	ebx,eax

@@notcfat32:	cmp	ptype,6
		jne	notBIGDOS

		cmp	nofatlimit?,1
		jne	noskiplim
		mov	eax,4*1024*1024*2	; max is 4 Gigs with nolimit
		jmp	@cnotf

noskiplim:	mov	eax,2*1024*1024*2	; max is 2 Gigs
@cnotf:		sub	eax,ebx
		call	mustcorrect
		jmp	sizeOK

notBIGDOS:	cmp	ptype,4
		jne	notFAT16

		mov	eax,32*1024*2		; max is 32 Megs
		sub	eax,ebx
		call	mustcorrect
		jmp	sizeOK

notFAT16:	cmp	ptype,0Bh
		je	@@fat32corr
		cmp	ptype,0Ch
		jne	@@nofat32s
@@fat32corr:	cmp	nofatlimit?,1
		je	@@nofat32s
		mov	eax,127*1024*1024*2	; max is 127 Gigs without nolimit
		sub	eax,ebx
		call	mustcorrect
		jmp	sizeOK

@@nofat32s:

sizeOK:		pop	ebx
		pop	eax
		ret

		endp


;--------

mustcorrect     proc near

		push	ebx
		push	dx
		cmp	eax,psize
		ja	sizeO
		mov	ebx,psize
		sub	ebx,eax
		mov	cutspace,ebx
		mov	psize,eax
		lea	dx,sizeadjust
		call	pwarning
sizeO:		pop	dx
		pop	ebx
		ret

                endp

;--------------------- Print size in MB to cursor ------------------
 
printsize       proc	near
;In: EAX - number

		shr	eax,11			; AX - size in MB
		call	Dec2Ascii
                ret

                endp

;-------------------- Calc size for relative calculations --------------

calcsize	proc near
;Out: EAX - max size in sectors
;     'allprisize' - ditto

		mov	eax,endsect
		mov	ebx,startsect
		sub	eax,ebx
		jz	emptys
		inc	eax			; partitions begin on
		sub	eax,sectors		; the next head only
emptys:		mov	allprisize,eax
		ret

                endp

;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
;---------------------- Get max logical size  -----------------------

getmaxlog	proc near
		call	checkextended
		jnc	okgetml
		ret

okgetml:	call	getmainextended		; get main extended

followch:	call	getnextext		; get all extended,
		jc	badgne			; exit if error
		test	al,al
		jz	followch

		mov	di,extendbuffer+1beh	; if first is empty, then
		cmp	byte ptr es:[di+4],0	; all extended space is OK
		jne	calclog			; Else subtract the
						; existing logical size
		mov	ebx,startmainext

gotlogs:	mov	eax,endmainext
		sub	eax,ebx
		sub	eax,sectors
		inc	eax
		mov	alllogsize,eax
		clc
badgne:		ret

calclog:	mov	ebx,es:[di+8]		; get end of last logical
		add	ebx,es:[di+0ch]
		add	ebx,extendstart
		jmp	gotlogs

		endp


;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
;---------------------- Check relative size argument -------------------

checkrelsize	proc near
;In: AX - number

		cmp	ax,100
		jbe	validsize

		lea	dx,badrelsize
		call	perror
		ret

validsize:	clc
		ret

		endp

;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
;------------------- Check if extended exists or not -------------------

checkextended	proc	near
;Out: C=1 if not found

		push	ax
		push	cx
		push	di
		mov	di,1beh+4
		mov	cx,4
searchext:	mov	al,es:[di]
		cmp	al,5
		jz	foundext
		cmp	al,0fh
		jz	foundext
		add	di,16
		loop	searchext
		stc
		jmp	notfext

foundext:	clc
notfext:	pop	di
		pop	cx
		pop	ax
		ret

		endp


;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
;------------------------ Check if defined valid -----------------------

checkdefined    proc near
;CF if not defined
;Out: emptyspace
;AX - selected entry
		call	asci2dec		; get if defined
		jc	dontrep
		dec	al
		cmp	al,3
		jbe	okpnumx
		lea	dx,badnumstr
		call	printstring
		stc
dontrep:	ret

okpnumx:	mov	emptyspace,al
		clc
		ret

		endp

;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
;------------------------ Check if defined occupied -----------------------

checkoccupied	proc near

		call	get&seek		; DI - pointer to selected part
		cmp	byte ptr es:[di+4],0	; check if occupied
		jz	nodef

		lea	dx,occupied
		call	perror
		ret

nodef:		clc
		ret

                endp


;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
;----------------- Calculate sector value from relative percent --------------

calcrel         proc near
;In:  AX - percent
;     EBX - max size
;Out: EAX - size in sectors

		push	ebx
		push	ecx
		push	edx
		and	eax,0ffffh
        	xor	edx,edx
		mul	ebx
		mov	ecx,100
		div	ecx
		pop	edx
		pop	ecx
		pop	ebx
                ret

                endp

;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
;--------------------- Read main extended partition table --------------

getmainextended	proc near

;Out: ES:512 - main extended
;     startmainext
;     endmainext

		push	si
		mov	si,1beh+4
		mov	cx,3
		xor	ah,ah
findex:		mov	al,byte ptr es:[si]
		cmp	al,5			; find extended entry
		je	thisise
		cmp	al,0fh
		je	thisise
		inc	ah
		add	si,16
		loop	findex		

thisise:	mov	al,16
		mul	ah
		mov	di,1beh
		add	di,ax			; calculate table entry offset
		mov	eax,es:[di+8]
		mov	extendstart,eax		; store start info
		add	eax,es:[di+0ch]
		dec	eax
		mov	extendend,eax		; store end info
		mov	eax,es:[di+8]
		mov	bx,extendbuffer
		mov	blocks,1
		call	getsectors
		jnc	fillfather
		jmp	@@exma

fillfather:	call	checksignature
		mov	eax,extendstart
		mov	startmainext,eax
		mov	eax,extendend
		mov	endmainext,eax
		clc
@@exma:		pop	si
		ret

		endp


;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
;------------ Follow chain and create new extended if needed ------------

getlastextend	proc near

followchain:	call	getnextext
		jc	getnerr
		test	al,al
		jz	followchain
		mov	di,extendbuffer+1beh
		cmp	byte ptr es:[di+4],0	; test if log not exists
		jne	createnext		; create next ext if yes

;----- Found empty table, fill logical info -------

		mov	eax,extendstart
		add	eax,sectors
		mov	startsect,eax
		mov	eax,extendend
		mov	endsect,eax
		mov	eax,sectors
		sub	psize,eax
		clc
getnerr:	ret

;------ Found an entry, but no embedded extended, so create it ------

createnext:	mov	eax,extendstart		; get start of father
		add	eax,es:[di+8]		; add existant logical offset
		add	eax,es:[di+0ch]		; and size
		mov	startsect,eax		; to get start of new extended
		mov	eax,psize		; store orininal size, because
		mov	tempsize,eax		; we'll change it now
		mov	eax,endmainext
		mov	endsect,eax
		call	calcend			; calc end and check size
		mov	endsect,eax		; end of new extended
		jnc	okexsize
		ret

okexsize:	add	di,16
		call	fillstart
		jnc	okconv7
		ret

okconv7:	mov	al,ptype
		push	ax
		mov	ptype,5			; create new extended
		mov	eax,endsect
		call	fillend
		pop	ax
		mov	ptype,al
		jnc	okconv8
		ret

okconv8:	mov	eax,startsect
		push	eax
		sub	eax,startmainext
		mov	startsect,eax
		call	sectorbefore
		pop	eax
		mov	startsect,eax
                call    sectorin

		mov	eax,tempsize		; restore original logical
		mov	psize,eax		; size

		mov	eax,extendstart
		mov	bx,extendbuffer
		mov	blocks,1
		call	writesectors		; write modified ext table
		jnc	wemp
		ret

wemp:		call	fill0boot
		mov	eax,startsect
		mov	bx,bootbuffer
		mov	word ptr es:[bx+510],0aa55h
		mov	blocks,1
		call	writesectors		; write empty new table
		jnc	empextok2
		ret

empextok2:	jmp	followchain

		endp

;----------------------- Get next embedded extended ---------------------

getnextext	proc near
;IN:  ES:512 - current extended table
;OUT: ES:512 - next embedded if exists
;     extendstart - start of got extended partition
;     AL=0 if OK, AL=1 if no more

		push	di
		push	cx
		mov	cx,4			; 4 entries
		mov	di,extendbuffer+1beh

seekext:	cmp	byte ptr es:[di+4],5
		je	loadnext
		add	di,16
		loop	seekext

		clc
		mov	al,1			; AL=1 if no more embedded
		jmp	badload			; found

loadnext:	mov	eax,es:[di+8]		; if found embedded, then
		add	eax,startmainext	; calculate its absolute
		mov	extendstart,eax		; start and load it
		mov	bx,extendbuffer
		mov	blocks,1
		call	getsectors
		jnc	foundnext
		jmp	badload

foundnext:	call	checksignature
		xor	al,al
badload:	pop	cx
		pop	di
		ret

		endp

;----------------------- Fill starting info -----------------------------

fillstart       proc near
		mov	eax,startsect

underlimit:	call	LBA2CHS
		jnc	nonz
		ret

nonz:		mov	byte ptr es:[di+1],dh	; set starting head
		mov	byte ptr es:[di+2],cl	; sector and
		mov	byte ptr es:[di+3],ch	; cylinder
		clc
                ret
                endp

;--------- Calculate ending adjusted to cylinder boundary ------------------

calcend         proc near
;Out: EAX - ending sector

		push	ebx
		push	edx
		xor	edx,edx
		mov	eax,heads
		mov	ebx,sectors
		mul	bx
		mov	bx,ax			; BX - heads * sectors
		mov	eax,startsect
		add	eax,psize		; correct it to a value
		div	ebx			; which doesn't give a
		sub	ebx,edx			; remainder
		add	psize,ebx

		pop	edx
		pop	ebx

		mov	eax,startsect
		add	eax,psize
		dec	eax

		cmp	eax,endsect
		jbe	oklarge

		cmp	relative?,1
		jne	toolarge
		mov	eax,endsect
		jmp	oklarge

toolarge:	lea	dx,toobig
		call	perror
		ret

oklarge:        clc
                ret

                endp

;----------------------- Fill ending cylinder info -------------------

fillend		proc near

		mov	eax,endsect
		call	LBA2CHS
		jnc	zeroeend
		ret

zeroeend:	mov	byte ptr es:[di+6],cl	; sector
		mov	byte ptr es:[di+7],ch
		mov	es:[di+5],dh
		mov	al,ptype
		mov	byte ptr es:[di+4],al	; set type
		clc
		ret

		endp

;------------------- Calculate sectors before partition -----------------

sectorbefore    proc near
		
		mov	eax,startsect	; EAX - starting cylinder
		mov	es:[di+8],eax	; setting preceeding sector number

	        ret

                endp

;---------------------- Calculate sectors in partition -----------------
sectorin        proc near

		mov	eax,endsect
		sub	eax,startsect
		inc	eax
		mov	es:[di+0ch],eax	; setting num of sectors entry
		ret

                endp


;---------------------- Activate selected entry ----------------------

activateit      proc near
;In: DI - pointer to entry to activate

		push	di
		push	cx
		push	ax
		mov	di,1beh
		mov	cx,4
		xor	al,al			; clear all active flags
clrnext:	mov	byte ptr es:[di],al
		add	di,16
		loop	clrnext
		pop	ax
		pop	cx
		pop	di
		mov	byte ptr es:[di],80h	; activate the selected
		ret

		endp



;----------------------- Get1st Error msg --------------------------

prgeterr	proc
		cmp	get1error?,0
		jne	nospac
		lea	dx,noentry
		jmp	per
nospac:		lea	dx,nospace
per:		call	perror
		ret
		endp

;--------------------------- Warning msg --------------------------

pwarning	proc
		push	dx
		lea	dx,warning
		call	printstring
		pop	dx
		call	printstring
		ret
		endp

;--------------------------- Check CPU type --------------------------

check_CPU	proc near
;Out: AL - type (086, 286, 386, 386
		pushf			; push original FLAGS
		pop	ax 		; get original FLAGS
		mov	cx,ax		; save original FLAGS
		and	ax,0fffh	; clear bits 12-15 in FLAGS
		push    ax              ; save new FLAGS value on stack
		popf                    ; replace current FLAGS value
		pushf                   ; get new FLAGS
		pop     ax              ; store new FLAGS in AX
		and     ax, 0f000h      ; if bits 12-15 are set, then CPU
		cmp     ax, 0f000h      ;   is an 8086/8088
		mov	al,1		; turn on 8086/8088 flag
		jne     check_80286     ; jump if CPU is not 8086/8088
		ret

;       Intel 286 CPU check
;       Bits 12-15 of the FLAGS register are always clear on the
;       Intel 286 processor in real-address mode.
;
check_80286:
		or      cx, 0f000h      ; try to set bits 12-15
		push    cx              ; save new FLAGS value on stack
		popf                    ; replace current FLAGS value
		pushf                   ; get new FLAGS
		pop     ax              ; store new FLAGS in AX
		and     ax, 0f000h      ; if bits 12-15 clear, CPU=80286
		mov     al,2		; turn on 80286 flag
		jnz     check_80386     ; if no bits set, CPU is 80286
		ret

;       Intel386 CPU check
;       The AC bit, bit #18, is a new bit introduced in the EFLAGS
;       register on the Intel486 DX CPU to generate alignment faults.
;       This bit cannot be set on the Intel386 CPU.
;
check_80386:
;       It is now safe to use 32-bit opcode/operands

		mov	ebx,esp		; save current stack pointer to align
		and	esp,not 3	; align stack to avoid AC fault
		pushfd			; push original EFLAGS
		pop	eax		; get original EFLAGS
		mov	ecx,eax		; save original EFLAGS
		xor	eax,1 shl 18	; flip AC bit in EFLAGS
		push    eax		; save new EFLAGS value on stack
		popfd			; replace current EFLAGS value
		pushfd			; get new EFLAGS
		pop	eax		; store new EFLAGS in EAX
		xor	eax,ecx		; can't toggle AC bit, CPU=80386
		mov	al,3		; turn on 80386 CPU flag
		mov	esp,ebx		; restore original stack pointer
		jnz	check_486	; jump if 80486 CPU
		ret

check_486:	and	sp, not 3       ; align stack to avoid AC fault
		push	ecx
		popfd			; restore AC bit in EFLAGS first
		mov	esp,ebx		; restore original stack pointer

;       Intel486 DX CPU, Intel487 SX NDP, and Intel486 SX CPU check
;       Checking for ability to set/clear ID flag (Bit 21) in EFLAGS
;       which indicates the presence of a processor
;       with the ability to use the CPUID instruction.
;
check_80486:
		mov     eax, ecx	; get original EFLAGS
		xor	eax,200000h	; flip ID bit in EFLAGS
		push	eax		; save new EFLAGS value on stack
		popfd			; replace current EFLAGS value
		pushfd			; get new EFLAGS
		pop	eax		; store new EFLAGS in EAX
		xor	eax,ecx		; can't toggle ID bit
		mov	al,4
		ret

		endp

;------------------------------------------------------------------

checkNT		proc
		mov	ax,3306h
		int	21h
		cmp	bx,3205h		; NT dos box
		je	@@itsNT
		clc
		ret

@@itsNT:	mov	ax,_DATA
		mov	ds,ax
		lea	dx,S_NTbox
		call	perror
		xor	ax,ax
		int	16h
		stc
		ret
		endp

;--------------------------- Allocate memory ----------------------------

allocate	proc	near
;IN:  BX - paragraphs
;OUT: ES - segment
;   0- 511 - buffer for MBR
; 512-1023 - buffer for extended
;1024-2559 - buffer for boot sector (3 for FAT32)

		push	ax
		push	bx
		push	di

		mov	ah,48h
		int	21h			; allocate
		jnc	okmem
		push	ax
		lea	dx,memerror		; print error
		call	perror
		pop	ax
		call	errno
		mov	ax,4c01h		; dirty exit
		int	21h

okmem:		mov	es,ax
		pop	di
		pop	bx
		pop	ax
		ret

allocate	endp

;----------------------------- Free memory ------------------------------

freemem         proc	near
;IN: ES
		pushf
		push	ax
		mov	ah,49h
		int	21h			; free ES segment
		mov	ax,ds
		mov	es,ax			; restore ES
		pop	ax
		popf
		ret
                endp

;---------------------------- Check EBIOS ----------------------------

ebios_check	proc	near

		mov	ebios,0
		mov	readint,2
		mov	writeint,3

		push	ax
		push	bx
		push	cx
		push	dx
		push	si
		mov	ah,41h
		mov	bx,55aah
		mov	dl,actualHD
		int	13h			; installation check
		jnc	checkit
		jmp	qebios

checkit:        cmp     bx,0aa55h		; check 1
                jne     qebios
                and     cx,1			; check 2
                jz      qebios

		mov	ah,48h
		mov	dl,actualHD
		lea	si,ebiosparams
                mov     word ptr [si],1ah
		int	13h
		jc	qebios

		mov	ebios,1
		mov	readint,42h
		mov	writeint,43h
		clc
		jmp	okebios

qebios:		stc
okebios:	pop	si
		pop	dx
		pop	cx
		pop	bx
		pop	ax
		ret
		endp

;ллллллллллллллллллллллл Calculate CHS from LBA ллллллллллллллллллллллллл

LBA2CHS		proc near
;IN:  EAX - LBA sector
;OUT: CH - cylinder low
;     CL - sector + cylinder high
;     DH - head

		cmp	eax,maxBIOS		; check size
		jbe	noaboveCHS		; jump if below BIOS limit

		cmp	ebios,1			; check if ebios available
		je	noaboveCHS		; jump if yes

		lea	dx,overCHS		; else print error
		call	perror
		ret

noaboveCHS:	push	eax
		push	ebx

		xor	ecx,ecx			; erase upper nibbles
		mov	ebx,eax
		mov	eax,heads		; first divide the LBA value
		mul	sectors			; by max sectors*max heads
		xchg	eax,ebx			; to calculate the cylinder
		div	ebx			; value
		mov	cx,ax			; CX - cylinder
		cmp	cx,1023			; correct if above
		jbe	dontccyl		;  1023 cyls
        	mov	cx,1023
dontccyl:	xchg	ch,cl
		shl	cl,6
		mov	eax,edx			; then divide the remainder
		xor	edx,edx
		div	sectors			; by the max sectors to get
		mov	dh,al			; the head and the sector
		or	cl,dl
		inc	cl			; sector is 1-based

		clc
		pop	ebx
		pop	eax
		ret

		endp


;ллллллллллллллллллллллллллллл Get sectors ллллллллллллллллллллллллллл
getsectors	proc near

;EAX - firstpoint for EBIOS
;BX - buffer
;blocks
;actualHD

		push	eax
		push	cx
		push	dx
		push	si

		cmp	ebios,1
		je	skiptrans

		call	LBA2CHS			; calc CHS if no EBIOS
		jc	@noerror

skiptrans:	mov	firstpoint,eax		; store firstpoint
		mov	ax,es
		shl	eax,16
		mov	ax,bx
		mov	transpoint,eax		; store transpoint
		mov	al,1
		lea	si,packet

		mov	dl,actualHD

@retryread:	mov	ah,readint
		int	13h			; read MBR
		jnc	@noerror

		push	ax
		lea	dx,readerror
		call	perror
		pop	ax
		call	errno
		stc

@noerror:	pop	si
		pop	dx
		pop	cx
		pop	eax
		ret

getsectors	endp

;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
;ллллллллллллллллллллллллллллл Write sector(s) лллллллллллллллллллллллллл
;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

writesectors	proc near
;EAX - firstpoint
;BX - buffer
;blocks
		push	eax
		push	cx
		push	dx
		push	si

		cmp	ebios,1
		je	skipCHSw

		call	LBA2CHS
		jc	@written

skipCHSw:	mov	firstpoint,eax
		mov	ax,es
		shl	eax,16
		mov	ax,bx
		mov	transpoint,eax
		lea	si,packet

		mov	dl,actualHD

                call    lockvolume

@nexttry:	mov	al,0		; no verify
		cmp	ebios,1
		je	writebb
		mov	ax,blocks
writebb:	mov	ah,writeint
		int	13h		; write
		call	unlockvolume
		jnc	@written

		push	ax
		lea	dx,writerror
		call	perror
		pop	ax
		call	errno
		stc

@written:	pop	si
		pop	dx
		pop	cx
		pop	eax
		ret

writesectors	endp


;-------------------------- Lock volume under Win95 ---------------------
lockvolume	proc
		cmp	win95?,1
		jne	@@dontlock

		push	ax
		push	bx
		push	cx
		push	dx
		mov	ax,440dh
		mov	cx,084bh
		mov	bh,1			; level 1 lock
		mov	bl,actualHD
		mov	dx,2			; disable writes
		int	21h
		pop	dx
		pop	cx
		pop	bx
		pop	ax
@@dontlock:	ret
		endp

;------------------------- Unlock volume ---------------------------
unlockvolume	proc

		pushf
		cmp	win95?,1
		jne	@@dontunlock

		push	ax
		push	bx
		push	cx
		mov	ax,440dh
		mov	cx,086bh
		mov	bl,actualHD
		int	21h
		pop	cx
		pop	bx
		pop	ax

@@dontunlock:	popf
		ret
		endp



;----------------------- Check if FAT partition ---------------------
checkifFAT	proc
;IN: ES:DI -> partition entry

		push	ax
		mov	al,es:[di+4]		; examine if the
		cmp	al,1			; selected is some FAT
		je	ok2hid
		cmp	al,4
		je	ok2hid
		cmp	al,6
		je	ok2hid
		cmp	al,0bh
		je	ok2hid
		cmp	al,0ch
		je	ok2hid
		cmp	al,0eh
		je	ok2hid
                stc
		jmp	@@gotifat

ok2hid:		clc
@@gotifat:	pop	ax
		ret
		endp

;---------------------- Check if hidden FAT --------------------

checkifHFAT	proc	near
;IN: ES:DI -> partition entry

		push	ax
		mov	al,es:[di+4]		; examine if the
		cmp	al,11h			; selected is some hidden FAT
		je	ok2unhid
		cmp	al,14h
		je	ok2unhid
		cmp	al,16h
		je	ok2unhid
		cmp	al,1bh
		je	ok2unhid
		cmp	al,1ch
		je	ok2unhid
		cmp	al,1eh
		je	ok2unhid
                stc
                jmp	@@unhex

ok2unhid:	clc
@@unhex:	pop	ax
		ret
		endp


;---------------------- Check if NTFS --------------------

checkifNTFS	proc	near

		push	ax
		mov	al,es:[di+4]		; examine if the
		cmp	al,7			; selected is some NTFS
		je	@@ok2hidnt
                stc
                jmp	@@ecnt

@@ok2hidnt:	clc
@@ecnt:		pop	ax
		ret

		endp


;---------------------- Check if hidden NTFS --------------------

checkifHNTFS	proc	near

		push	ax
		mov	al,es:[di+4]		; examine if the
		cmp	al,17h			; selected is some hidden NTFS
		je	ok2unhidnt
                stc
                jmp	@@ecunt

ok2unhidnt:	clc
@@ecunt:	pop	ax
		ret
		endp


;------------------------ FAT16 or FAT32 -----------------------

FAT16orFAT32	proc	near
;IN: ES:DI -> entry
;OUT: C=1 if FAT32, 0 if FAT16

		push	ax
		mov	al,es:[di+4]
		cmp	al,0bh			; check if FAT32
		je	@@32lab
		cmp	al,1bh
		je	@@32lab
		cmp	al,0ch
		je	@@32lab
		cmp	al,1ch
		je	@@32lab
		clc
		jmp	@@exfof

@@32lab:	stc
@@exfof:	pop	ax
		ret
		endp

;------------------------ check double colon -------------------------

checkcolon	proc near
;Check colon and place SI to number

		cmp	byte ptr [si],':'
		jne	badcolon
		inc	si
		clc
		ret

badcolon:	stc
		ret
		endp

;------------- skips spaces and returns first non-whitespace ------------

skipwhite	proc near
;IN:  SI -> command line element
;OUT: AL - first non white chatacter
;     SI -> to AL

skipitw:	mov	al,byte ptr [si]
		cmp	al,' '
		jne	exskip
		inc	si
		jmp	skipitw
exskip:		ret
skipwhite	endp

;-------------- Convert to ASCII decimal and print at cursor ----------------

Dec2Ascii	proc	near
;IN: EAX - number

		push	eax
		push	ebx
		push	cx
		push	edx
		push	si

		mov	ebx,0ah
		lea	si,ascnum+7

zz4:		xor	edx,edx
		div	ebx
		add	dl,30h
		mov	[si],dl
		dec	si
		or	eax,eax
		jne	zz4

		lea	si,ascnum
		mov	cx,7
nzer:		cmp	byte ptr [si],'0'
		jne	wrn
		inc	si
		loop	nzer
wrn:		mov	dx,si
		call	printstring
		lea	si,ascnum
		mov	eax,30303030h
		mov	[si],eax
		mov	[si+4],eax

		pop	si
		pop	edx
		pop	cx
		pop	ebx
		pop	eax
		ret

		endp	Dec2Ascii

;-------------- Convert to ASCII hexa and print at cursor ---------------

Hex2Ascii	proc	near
;IN: AL - number

		push	ax
		mov	dh,al
		mov	dl,al
		shr	dl,4			; most significant nibble 1st
		and	dh,00001111b		; least then
		mov	ah,2			; write character
		add	dx,3030h
		cmp	dl,'9'
		jbe	@@numberd
		add	dl,'A'-3Ah
@@numberd:	int	21h
		mov	ah,2
		mov	dl,dh
		cmp	dl,'9'
		jbe	@@numberd2
		add	dl,'A'-3Ah
@@numberd2:	int	21h
		pop	ax
		ret

		endp	Hex2Ascii

;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
;------------------------------ ASCII to hex ----------------------------
;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

asci2hex	proc	near
;SI - ASCII buffer
;Out: AX - hexa numa

		xor	ax,ax
		cmp	byte ptr [si],' '
		ja	nexthexa

		lea	dx,badvalue
		call	perror
		ret

nexthexa:	or	ah,al
		shl	ah,4
		mov	al,[si]

		cmp	al,39h
		jna	number1
		cmp	al,90
		jb	capital1
		sub	al,20h
capital1:	sub	al,7h
number1:	sub	al,30h

		inc	si
		cmp	byte ptr [si],' '
		jbe	endhexa
		cmp	byte ptr [si],':'
		je	endhexa
		cmp	byte ptr [si],','
		je	endhexa
		jmp	nexthexa

endhexa:	or	al,ah
		xor	ah,ah
		clc
		ret
		endp

;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
;------------------------- ASCII to dec -----------------------------
;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

asci2dec	proc near
;SI - ASCII buffer
;Out: EAX - dec numa

		mov	al,[si]
		cmp	al,39h
		ja	baddec
		cmp	al,30h
		jb	baddec
		jmp	gooddec

baddec:		lea	dx,badvalue
		call	perror
		ret

gooddec:	push	ebx
		push	ecx
		push	edx
		xor	eax,eax
		xor	ebx,ebx
		xor	edx,edx
		mov	ecx,0ah
@ndigit:	mov	bl,[si]
		inc	si
		cmp	bl,39h
		ja	@convend
		sub	bl,30h
		jb	@convend
		mul	ecx
		add	eax,ebx
		adc	dl,dh
		je	@ndigit
@convend:	dec	si
		clc
		pop	edx
		pop	ecx
		pop	ebx
		ret
		endp


;--------------------------- Error msg --------------------------
;DX - pointer to error

perror		proc
		push	dx
		lea	dx,error
		call	printstring
		pop	dx
		call	printstring
		stc
		ret
		endp

;---------------- Fill boot buffer with F6 values ----------------------
fillF6boot	proc
		push	ax
		push	cx
		push	di
		mov	al,0f6h
		mov	di,bootbuffer
		mov	cx,512*3
		rep	stosb
		pop	di
		pop	cx
		pop	ax
		ret
		endp

;----------------- Fill boot buffer with 00 values ---------------------

fill0boot	proc
		push	ax
		push	cx
		push	di
		mov	di,bootbuffer
		mov	cx,512*3
		xor	al,al
		rep	stosb
		pop	di
		pop	cx
		pop	ax
		ret
		endp

;------------------------ Print string -----------------

printstring	proc	near
		push	ax
		mov	ah,9
		int	21h
		pop	ax
		ret
		endp


;*****
;ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ Main Code ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ
;*****
_aefdisk	proc

		cld

		call	check_CPU
		cmp	al,3
		jae	okproc
		mov	ax,_DATA
		mov	ds,ax
		lea	dx,need386
		call	printstring
                stc
                jmp     gexit

okproc:		mov	bx,200h
		mov	ax,ss
		shr	bx,4		; stack length / 16 + 1
		inc	bx
		add	bx,ax
		mov	ax,cs
		sub	ax,10h
		sub	bx,ax
		mov	es,ax
		mov	ah,4ah		; resize memory block
		int	21h

		mov	si,80h

		call	checkNT
		jc	gexit

		cmp	byte ptr [si],0	; examine command line
		je	noparams	; jump if no command line param

		call	commandline	; process command line
		mov	format?,0
		mov	relative?,0
		jc	errorexit

		cmp	reboot?,0	; reboot?
		je	gexit

		mov	ah,0dh		; flush disk
		int	21h

        	mov	ax,40h		; set ES to BIOS data segment
		mov	es,ax

		mov	di,17h		; simulate CTRL-ALT-DEL first
		or	byte ptr es:[di],0Ch
		mov	ah,4Fh
		mov	al,53h		; DEL
		stc
		int	15h		; this should reboot now

		mov	di,72h		; if not, warm reset
		mov	ax,1234h
		stosw			; warm reboot
		db	0eah
		dw	0, 0ffffh       ; jmp 0ffffh:0000h

gexit:		mov	ax,4c00h
		adc	al,0
		int	21h		; exit with error code

errorexit:	lea	dx,notsavedMBR
		call	printstring
		stc
		jmp	gexit

;---------------

noparams:	mov	ax,_DATA
		mov	ds,ax		; DS - data segment
		lea	dx,usage	; print usage info
		call	printstring
		mov	ah,8
		int	21h
		lea	dx,switche
		call	printstring
		clc
		jmp	gexit

_aefdisk	endp
		ends
		end	_aefdisk

;===============================End of program================================
