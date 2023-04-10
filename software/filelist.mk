# Library sources
LIB_PATH=./lib
SRC_PATH=./src

APP_INC += -I$(LIB_PATH)
APP_INC += -I$(SRC_PATH)
APP_SRC += $(wildcard $(LIB_PATH)/*.c)

# Actual application
APP_SRC += src/project.c
APP_SRC += src/cli.c
