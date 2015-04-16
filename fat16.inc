bootsec16	label

		DB	0EBh,03Ch,090h
		db	'MSDOS5.0'	; oem name
		dw	512		; bytes per sector
secperclust	db	0		; sectors per cluster
reserved	dw	1		; reserved sectors
		DB	2		; FATs on disk
		dw	512		; root entries
totsec		dw	0		; 0 if size > 32Mb
		db	0F8h		; media byte
secperFAT	dw	0		; sectors per FAT
secpertrack	dw	0		; sectors per track
numheads	dw	0		; number of heads
hiddensecs	dd	0		; sectors before partition
numsecs		dd	0		; number of sectors if size > 32Mb
drivenum	db	80h		; physical drive number
		db	0		; reserved
		db	29h		; signature byte
serialnum	dd	0		; serial number
vollabel	db	'NO NAME    '	; volume label
		db	'FAT16   '	; FAT type

		db 0FAh,033h
		DB 0C0h,08Eh,0D0h,0BCh,000h,07Ch,016h,007h,0BBh,078h,000h,036h,0C5h,037h,01Eh,056h
		DB 016h,053h,0BFh,03Eh,07Ch,0B9h,00Bh,000h,0FCh,0F3h,0A4h,006h,01Fh,0C6h,045h,0FEh
		DB 00Fh,08Bh,00Eh,018h,07Ch,088h,04Dh,0F9h,089h,047h,002h,0C7h,007h,03Eh,07Ch,0FBh
		DB 0CDh,013h,072h,079h,033h,0C0h,039h,006h,013h,07Ch,074h,008h,08Bh,00Eh,013h,07Ch
		DB 089h,00Eh,020h,07Ch,0A0h,010h,07Ch,0F7h,026h,016h,07Ch,003h,006h,01Ch,07Ch,013h
		DB 016h,01Eh,07Ch,003h,006h,00Eh,07Ch,083h,0D2h,000h,0A3h,050h,07Ch,089h,016h,052h
		DB 07Ch,0A3h,049h,07Ch,089h,016h,04Bh,07Ch,0B8h,020h,000h,0F7h,026h,011h,07Ch,08Bh
		DB 01Eh,00Bh,07Ch,003h,0C3h,048h,0F7h,0F3h,001h,006h,049h,07Ch,083h,016h,04Bh,07Ch
		DB 000h,0BBh,000h,005h,08Bh,016h,052h,07Ch,0A1h,050h,07Ch,0E8h,092h,000h,072h,01Dh
		DB 0B0h,001h,0E8h,0ACh,000h,072h,016h,08Bh,0FBh,0B9h,00Bh,000h,0BEh,0E6h,07Dh,0F3h
		DB 0A6h,075h,00Ah,08Dh,07Fh,020h,0B9h,00Bh,000h,0F3h,0A6h,074h,018h,0BEh,09Eh,07Dh
		DB 0E8h,05Fh,000h,033h,0C0h,0CDh,016h,05Eh,01Fh,08Fh,004h,08Fh,044h,002h,0CDh,019h
		DB 058h,058h,058h,0EBh,0E8h,08Bh,047h,01Ah,048h,048h,08Ah,01Eh,00Dh,07Ch,032h,0FFh
		DB 0F7h,0E3h,003h,006h,049h,07Ch,013h,016h,04Bh,07Ch,0BBh,000h,007h,0B9h,003h,000h
		DB 050h,052h,051h,0E8h,03Ah,000h,072h,0D8h,0B0h,001h,0E8h,054h,000h,059h,05Ah,058h
		DB 072h,0BBh,005h,001h,000h,083h,0D2h,000h,003h,01Eh,00Bh,07Ch,0E2h,0E2h,08Ah,02Eh
		DB 015h,07Ch,08Ah,016h,024h,07Ch,08Bh,01Eh,049h,07Ch,0A1h,04Bh,07Ch,0EAh,000h,000h
		DB 070h,000h,0ACh,00Ah,0C0h,074h,029h,0B4h,00Eh,0BBh,007h,000h,0CDh,010h,0EBh,0F2h
		DB 033h,0C9h,03Bh,016h,018h,07Ch,073h,073h,0F7h,036h,018h,07Ch,0FEh,0C2h,088h,016h
		DB 04Fh,07Ch,08Bh,0D1h,0F7h,036h,01Ah,07Ch,088h,016h,025h,07Ch,0A3h,04Dh,07Ch,0F8h
		DB 0C3h,0B4h,002h,08Bh,016h,04Dh,07Ch,0B1h,006h,0D2h,0E6h,00Ah,036h,04Fh,07Ch,08Bh
		DB 0CAh,086h,0E9h,08Ah,016h,024h,07Ch,08Ah,036h,025h,07Ch,0CDh,013h,0C3h,00Dh,00Ah
		DB 04Eh,06Fh,06Eh,02Dh,053h,079h,073h,074h,065h,06Dh,020h,064h,069h,073h,06Bh,020h
		DB 06Fh,072h,020h,064h,069h,073h,06Bh,020h,065h,072h,072h,06Fh,072h,00Dh,00Ah,052h
		DB 065h,070h,06Ch,061h,063h,065h,020h,061h,06Eh,064h,020h,070h,072h,065h,073h,073h
		DB 020h,061h,06Eh,079h,020h,06Bh,065h,079h,00Dh,00Ah,000h,02Bh,016h,018h,07Ch,041h
		DB 0EBh,080h,090h,090h,090h,090h,049h,04Fh,020h,020h,020h,020h,020h,020h,053h,059h
		DB 053h,04Dh,053h,044h,04Fh,053h,020h,020h,020h,053h,059h,053h,000h,000h,055h,0AAh
