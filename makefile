# Macros for building, deleting. Needs Borland C compiler/linker for DOS

AS=\borlandc\bin\tasm
ASFLAGS=/m9 /q
# /zi

LINK=\borlandc\bin\tlink /x
# /v

RM=del

# Rule to build .obj from .asm

.asm.obj:
	$(AS) $(ASFLAGS) $*;

.obj.exe:
	$(LINK) $*;

.obj.com:
	$(LINK) /t $*;


# Targets:

all: aefdisk.exe

aefdisk.exe: aefdisk.obj

aefdisk.obj: aefdisk.asm

# Clean up:

clean:
	-$(RM) *.obj
	-$(RM) aefdisk.exe
