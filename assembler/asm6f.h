
#if defined(__cplusplus)
#include <cstddef>
#include <cstdint>
#else
#include <stddef.h>
#include <stdint.h>
#endif


enum labeltypes {LABEL,VALUE,EQUATE,MACRO,RESERVED};
enum cdltypes {NONE=0,CODE=1,DATA=2};
//	LABEL: known address
//	VALUE: defined with '='
//	EQUATE: made with EQU
//	MACRO: macro (duh)
//	RESERVED: reserved word


typedef struct {
	const char *name;		//label name
	// ptrdiff_t so it can hold function pointer on 64-bit machines
	ptrdiff_t value;		//PC (label), value (equate), param count (macro), funcptr (reserved)

	// [freem addition (from asm6_sonder.c)]
	int pos;				// location in file; used to determine bank when exporting labels

	char *line;			//for macro or equate, also used to mark unknown label
							//*next:text->*next:text->..
							//for macros, the first <value> lines hold param names
							//for opcodes (reserved), this holds opcode definitions, see initlabels
	int type;				//labeltypes enum (see above)
	int used;				//for EQU and MACRO recursion check
	int pass;				//when label was last defined
	int scope;				//where visible (0=global, nonzero=local)
	int ignorenl;			//[freem addition] output this label in .nl files? (0=yes, nonzero=no)
	void *link;			//labels that share the same name (local labels) are chained together
} label;

label *to_label(uint16_t v);
void initlabels();

int cpu_asmfile(const char *fname);
