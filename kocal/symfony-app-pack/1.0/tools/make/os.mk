######
# Os #
######

# Os detection helpers.
#
# Examples:
#
# Example #1: conditions on linux
#
#   echo $(if $(OS_LINUX),Running on Linux,*NOT* running on Linux)

ifeq ($(OS),Windows_NT)
OS = windows
OS_WINDOWS = 1
else
# See: https://make.mad-scientist.net/deferred-simple-variable-expansion/
OS = $(eval OS := $$(shell uname -s | tr '[:upper:]' '[:lower:]'))$(OS)
OS_LINUX = $(if $(findstring linux,$(OS)),1)
OS_DARWIN = $(if $(findstring darwin,$(OS)),1)
endif
