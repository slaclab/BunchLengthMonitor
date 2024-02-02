#Makefile at top of application tree
TOP = .
include $(TOP)/configure/CONFIG
DIRS := $(DIRS) $(filter-out $(DIRS), configure)
#DIRS := $(DIRS) $(filter-out $(DIRS), $(wildcard *App))

#ifeq ($(filter facet,$(MAKECMDGOALS)),facet)
#    DIRS += blenFACETApp
#else
#    DIRS += blenApp
#endif
#DIRS += blenApp
DIRS += blenFACETApp
DIRS := $(DIRS) $(filter-out $(DIRS), $(wildcard iocBoot))

#ifeq ($(filter facet,$(MAKECMDGOALS)),facet)
#    DIRS += blenFACETApp
#else
#    DIRS += blenApp
#endif

#facet: DIRS += blenFACETApp
#facet: all

define DIR_template
 $(1)_DEPEND_DIRS = configure
endef
$(foreach dir, $(filter-out configure,$(DIRS)),$(eval $(call DIR_template,$(dir))))

iocBoot_DEPEND_DIRS += $(filter %App,$(DIRS))

include $(TOP)/configure/RULES_TOP


