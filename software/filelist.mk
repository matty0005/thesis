# Library sources
LIB_PATH=./lib

APP_INC += -I$(LIB_PATH)
APP_SRC += $(wildcard $(LIB_PATH)/*.c)

# Actual application
APP_SRC += src/project.c
