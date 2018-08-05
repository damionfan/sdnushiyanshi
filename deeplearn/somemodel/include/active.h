
#include "../include/model.h"


struct active {
	unsigned char *name;
	void (*activefunc)(unsigned char *name, unsigned char *data);
};

struct active_list{
	unsigned char *name;
	struct active *func;
	struct active_list *Next;
};

//extern  u32 _register_active_(unsigned char *name,struct active *active);
//extern  struct active * _find_active_(unsigned char *name);
