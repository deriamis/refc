# -*- mode: makefile-gmake -*-
ifeq ($(OS),Windows_NT)
    OS_TYPE := Windows

    ifneq ($(shell wmic get Caption /value | findstr /B /C:"Windows 11"),)
        HOST_OS := Windows11
    else
        HOST_OS := Windows
    endif

    EXEEXT  := .exe
    DLLEXT  := .dll

    ifeq ($(PROCESSOR_ARCHITEW6432),AMD64)
        HOST_ARCH := x86_64
    else
        ifeq ($(PROCESSOR_ARCHITECTURE),AMD64)
            HOST_ARCH := x86_64
        endif
        ifeq ($(PROCESSOR_ARCHITECTURE),ARM64)
            HOST_ARCH := arm64
        endif
        ifeq ($(PROCESSOR_ARCHITECTURE),X86)
            HOST_ARCH := i686
        endif
    endif

    ifndef $(TARGET_ARCH)
        TARGET_ARCH := $(HOST_ARCH)
    endif

    # Detect cmd.exe and find a compatible shell
    ifdef COMSPEC
        BASH := $(shell where bash.exe)
        ifneq (,$(BASH))
            override SHELL := bash.exe
        else
            PWSH := $(shell where pwsh.exe)
            ifneq ($(SHELL),,)
                override SHELL := pwsh.exe
            else
                $(error Could not locate either bash.exe or pwsh.exe)
            endif
        endif
    endif

    ifeq ($(HOST_ARCH),x86_64)
        MSVC_HOST_ARCH      := x64
        MSVC_COMPONENT_ARCH := x86.64
    endif
    ifeq ($(HOST_ARCH),arm64)
        MSVC_HOST_ARCH      := arm64
        ifeq ($(HOST_OS),Windows11)
            MSVC_COMPONENT_ARCH := ARM64EC
        else
            MSVC_COMPONENT_ARCH := ARM64
        endif
    endif
    ifeq ($(HOST_ARCH),i686)
        MSVC_HOST_ARCH      := x86
        MSVC_COMPONENT_ARCH := x86.64
    endif
else
    OS_TYPE      := POSIX
    SHELL        := bash
    EXEEXT       :=
    HOST_ARCH    := $(shell uname -p)
    UNAME_SYSTEM := $(shell uname -s)

    ifndef $(TARGET_ARCH)
        TARGET_ARCH := $(HOST_ARCH)
    endif

    ifeq ($(UNAME_SYSTEM),Linux)
        HOST_OS := Linux
        DLLEXT := .so
    endif
    ifneq ($(filter GNU%,$(UNAME_SYSTEM)),)
        HOST_OS := GNU
        DLLEXT := .so
    endif
    ifeq ($(UNAME_SYSTEM),Darwin)
        HOST_OS := Darwin
        DLLEXT := .dylib
    endif
    ifneq ($(filter %BSD,$(UNAME_SYSTEM)),)
        HOST_OS := BSD
        DLLEXT := .so
    endif
endif

ifeq ($(OS_TYPE),Windows)
    ifdef $(VCINSTALLDIR)
        CC  ?= "$(VCINSTALLDIR)\\bin\\cl.exe"
        CXX ?= "$(CC)"
        LD  ?= "$(VCINSTALLDIR)\\bin\\link.exe"
        AR  ?= "$(VCINSTALLDIR)\\bin\\lib.exe"
    else
        MSVC_COMPONENT  := Microsoft.VisualStudio.Component.VC.Tools.$(MSVC_ARCH)
        MSVC_INSTALLDIR := $(shell vswhere -latest -products * -requires $(MSVC_COMPONENT) -property installationPath)

        ifdef $(MSVC_INSTALLDIR)
            MSVC_VERSION_FILE := $(MSVC_INSTALLDIR)\\VC\\Auxiliary\\Build\\Microsoft.VCToolsVersion.default.txt

            MSVC_VERSION := $(strip $(shell gc -raw "$(MSVC_VERSION_FILE)"))
            MSVC_TOOLSDIR     := $(MSVC_INSTALLDIR)\\VC\\Tools\\MSVC\\$(MSVC_VERSION)\\bin\\Host$(MSVC_HOST_ARCH)\\$(TARGET_ARCH)

            CC                := $(MSVC_TOOLSDIR)\\cl.exe
            CXX               := $(CC)
            LD                := $(MSVC_TOOLSDIR)\\link.exe
            AR                := $(MSVC_TOOLSDIR)\\lib.exe
        endif
    endif
endif

ifneq (,$(VCINSTALLDIR)$(MSVC_VERSION))
    COMPILER := MSVC
    LINKER   := MSVC
else
    CC_ORIGIN  := $(origin CC)
    CXX_ORIGIN := $(origin CXX)

    ifneq (,$(filter $(CC_ORIGIN),undefined default))

        # Bootstrap the compiler type so we can execute it later
        FOUND_C_COMPILER := $(shell for prog in $(CC) gcc clang; do \
            prog="$$(which "$${prog}")"; \
            found="$$("$${prog}" -dM -E "$(UTILSDIR)configure/configure.h" 2>/dev/null \
                      | grep 'COMPILER_NAME' \
                      | rev | cut -d ' ' -f1 | rev | tr -d \")"; \
            if [[ -n "$${found}" ]]; then \
                printf "%s:%s\n" "$${found}" "$${prog}"; \
            fi; \
        done | head -1)

        ifeq (,$(FOUND_C_COMPILER))
            $(warn "No C compiler found!")
        endif

                 C_COMPILER := $(word 1,$(subst :, ,$(FOUND_C_COMPILER)))
        override CC         := $(word 2,$(subst :, ,$(FOUND_C_COMPILER)))
    else
        C_COMPILER := $(shell "$(CC)" -dM -E "$(UTILSDIR)configure/configure.h" 2>/dev/null \
                               | grep 'COMPILER_NAME' \
                               | rev | cut -d ' ' -f1 | rev | tr -d '"')

        ifeq (,$(C_COMPILER))
            $(error "Non-working C compiler: `$(CC)'")
        endif
    endif

    ifneq (,$(filter $(CXX_ORIGIN),undefined default))

        # Bootstrap the compiler type so we can execute it later
        FOUND_CXX_COMPILER := $(shell for prog in $(CXX) g++ clang++; do \
            prog="$$(which "$${prog}")"; \
            found="$$("$${prog}" -dM -E "$(UTILSDIR)configure/configure.h" 2>/dev/null \
                      | grep 'COMPILER_NAME' \
                      | rev | cut -d ' ' -f1 | rev | tr -d \")"; \
            if [[ -n "$${found}" ]]; then \
                printf "%s:%s\n" "$${found}" "$${prog}"; \
            fi; \
        done | head -1)

        ifeq (,$(FOUND_CXX_COMPILER))
            $(warn "No C++ compiler found!")
        endif

                 CXX_COMPILER := $(word 1,$(subst :, ,$(FOUND_CXX_COMPILER)))
        override CXX          := $(word 2,$(subst :, ,$(FOUND_CXX_COMPILER)))
    else
        CXX_COMPILER := $(shell "$(CXX)" -dM -E "$(UTILSDIR)configure/configure.h" 2>/dev/null \
                                 | grep 'COMPILER_NAME' \
                                 | rev | cut -d ' ' -f1 | rev | tr -d '"')

        ifeq (,$(CXX_COMPILER))
            $(error "Non-working C++ compiler: `$(CXX)'")
        endif
    endif

    ifneq (,$(filter $(CC_ORIGIN),undefined default))
    ifneq (,$(filter $(CXX_ORIGIN),undefined default))
    ifneq ($(C_COMPILER),$(CXX_COMPILER))
        $(error "!! C compiler `$(C_COMPILER)' (from: $(CC_ORIGIN)) does not match C++ compiler `$(CXX_COMPILER)' (from: $(CXX_ORIGIN)) !!")
    endif
    endif
    endif

    TEST_CC        := $(if $(CC),$(CC),$(CXX))
    ifeq (,$(TEST_CC))
        $(error "No working C or C++ compilers found!")
    endif

    COMPILER       := $(if $(C_COMPILER),$(C_COMPILER),$(CXX_COMPILER))

    ifneq (,$(filter $(COMPILER),GCC MinGW Clang))

        AR             := $(shell $(TEST_CC) --print-prog-name $(if $(AR),$(AR),ar))
        AS             := $(shell $(TEST_CC) --print-prog-name $(if $(AS),$(AS),as))
        RANLIB         := $(shell $(TEST_CC) --print-prog-name $(if $(RANLIB),$(RANLIB),ranlib))
        OBJCOPY        := $(shell $(TEST_CC) --print-prog-name $(if $(OBJCOPY),$(OBJCOPY),objcopy))
        STRIP          := $(shell $(TEST_CC) --print-prog-name $(if $(STRIP),$(STROP),strip))

        ifeq ($(COMPILER),MinGW)
            override EXEEXT := .exe
            override DLLEXT := .dll

            TEST_CFLAGS := -mconsole
        endif

        CONFTEST_TEMP      := $(shell mktemp -d conftest.XXXXXXXXXX)

        # Note: These commands are only used for finding the actual binaries that get called
        #       for each compiler stage to assist with finding the linker. They currently do
        #       not get used for producing any output in `Makefile`s.
        PREPROCESS_COMMAND := $(strip \
                                  $(shell "$(TEST_CC)" $(CPPFLAGS) $(CFLAGS) $(TEST_CFLAGS) \
                                      -v -E "$(UTILSDIR)configure/conftests/test_main.c" \
                                      -o "$(CONFTEST_TEMP)/test_main.c.i" 2>&1 \
                                      | tr -d '"' | grep -E -- "/(cc1|clang(-[^[:space:]]+)? -cc1)"))
        PREPROCESSOR_BIN   := $(word 1,$(PREPROCESS_COMMAND))

        COMPILE_COMMAND    := $(strip \
                                  $(shell "$(TEST_CC)" $(CPPFLAGS) $(CFLAGS) $(TEST_CFLAGS) \
                                      -v -S "$(UTILSDIR)configure/conftests/test_main.c" \
                                      -o "$(CONFTEST_TEMP)/test_main.s" 2>&1 \
                                      | tr -d '"' | grep -E -- "/(cc1|clang(-[^[:space:]]+)? -cc1)"))
        COMPILER_BIN       := $(word 1,$(COMPILE_COMMAND))
        COMPILER_ARGS      := $(filter-out %/test_main.c,$(wordlist 2, $(words $(COMPILE_COMMAND)),$(COMPILE_COMMAND)))

        ASSEMBLER_COMMAND  := $(strip \
                                  $(shell "$(TEST_CC)" $(CPPFLAGS) $(CFLAGS) $(TEST_CFLAGS) \
                                      -v -c "$(CONFTEST_TEMP)/test_main.s" \
                                      -o "$(CONFTEST_TEMP)/test_main.o" 2>&1 \
                                      | tr -d '"' | grep -E -- "/([^[:space:]]-?as|clang(-[^[:space:]]+)? -cc1as)"))
        ASSEMBLER_BIN      := $(word 1,$(ASSEMBLER_COMMAND))
        ASSEMBLER_ARGS     := $(filter-out %/test_main.s,$(wordlist 2, $(words $(ASSEMBER_COMMAND)),$(ASSEMBLER_COMMAND)))

        LINK_COMMAND       := $(strip \
                                  $(shell "$(TEST_CC)" $(CPPFLAGS) $(CFLAGS) $(TEST_CFLAGS) \
                                      -v "$(CONFTEST_TEMP)/test_main.o" \
                                      -o "$(CONFTEST_TEMP)/test_main$(EXEEXT)" 2>&1 \
                                      | tr -d '"' | grep -E -- "/(collect2|mold|ld(\.*))"))

        ifeq (collect2,$(patsubst %/collect2,collect2,$(word 1,$(LINK_COMMAND))))
            # Simulate collect2 going through the GCC search paths
            LINKER_WRAPPER := $(word 1,$(LINK_COMMAND))
            FOUND_LINKER   := $(strip \
                            $(shell \
                "$(TEST_CC)" \
                    -c "$(UTILSDIR)/configure/conftests/test_main.c" \
                    -o /dev/null \
                    '-###' 2>&1 \
                | tr -d '"' \
                | grep -Eo -- '--with-ld(=| +)[^[:space:]]+' \
                | sed -E 's/--with-ld(=| +)//'))

            ifeq (,$(FOUND_LINKER))
                FOUND_LINKER := $(strip \
                                $(shell \
                    "$(TEST_CC)" \
                        --print-prog-name real-ld \
                    2>/dev/null \
                    | sed -E '/^real-ld$$/d'))
            endif
            ifeq (,$(FOUND_LINKER))
                FOUND_LINKER := $(shell which real-ld)
            endif
            ifeq (,$(FOUND_LINKER))
                FOUND_LINKER := $(strip \
                                $(shell \
                    "$(TEST_CC)" \
                        -dM -E - \
                    < /dev/null \
                    2>/dev/null \
                    | \grep 'REAL_LD_FILE_NAME'))
            endif
            ifeq (,$(FOUND_LINKER))
                FOUND_LINKER := $(strip \
                                $(shell \
                    "$(TEST_CC)" \
                        --print-prog-name ld \
                    2>/dev/null \
                    | sed -E '/^ld$$/d'))
            endif
        else
            FOUND_LINKER  := $(word 1,$(LINK_COMMAND))
        endif

        LINKER_ARGS       := $(wordlist 2, $(words $(LINK_COMMAND)),$(LINK_COMMAND))

        LINKERS_AVAILABLE := $(shell \
            "$(TEST_CC)" $(CPPFLAGS) $(CFLAGS) $(TEST_CFLAGS) \
                -c "$(UTILSDIR)configure/conftests/test_main.c" \
                -o "$(CONFTEST_TEMP)/test_main.o" \
            2>/dev/null; \
            for linker in $(LD) $(FOUND_LINKER) ld.mold ld.lld ld.bfd ld.gold ld; do \
               if "$${linker}" $(LINKER_ARGS) 2>/dev/null; then \
                   linker_path="$$(which "$${linker}")"; \
                   linker_bin="$$(basename "$${linker_path}")"; \
                   linker_name="$${linker_bin#ld.}"; \
                   echo "$${linker_name}:$${linker_path}"; \
               fi; \
            done \
            | sort \
            | uniq; \
            rm -rf "$(CONFTEST_TEMP)")

        ifndef LINKERS_AVAILABLE
            $(error No linker found)
        endif

        ifdef USE_LINKER
                     LINKER := $(word 1,$(subst :, ,$(filter $(USE_LINKER):%,$(LINKERS_AVAILABLE))))
            override LD     := $(word 2,$(subst :, ,$(filter $(USE_LINKER):%,$(LINKERS_AVAILABLE))))
        else
                     LINKER := $(word 1,$(subst :, ,$(firstword $(LINKERS_AVAILABLE))))
            override LD     := $(word 2,$(subst :, ,$(firstword $(LINKERS_AVAILABLE))))
        endif

        LINKER_ARGS := $(filter-out $(CONFTEST_TEMP)/test_main.o,\
                       $(filter-out -o $(CONFTEST_TEMP)/test_main$(EXEEXT),$(LINKER_ARGS)))

        LDFLAGS     += $(shell echo "$(LINKER_ARGS)" \
            | grep -Eo -- '-arch [^[:space:]]+|-platform_version [^-]*' \
            | tr '\n' ' ')
        LDFLAGS     += $(shell echo "$(LINKER_ARGS)" \
            | grep -Eo -- '--?plugin(=| +)[^[:space:]]+|-plugin-opt=+[^[:space:]]+' \
            | tr '\n' ' ')
        LDFLAGS     += $(shell echo "$(LINKER_ARGS)" \
            | grep -Eo -- '--?(fuse-ld|syslibroot|lto_library|rpath|m(arch|cpu))(=| +)[^[:space:]]+|-(L|m)|[^[:space:]]+' \
            | tr '\n' ' ')
        LDFLAGS     += $(shell echo "$(LINKER_ARGS)" \
            | grep -Eo -- '--?(sysroot|subsystem)(=| +)[^[:space:]]+' \
            | tr '\n' ' ')

        ifeq ($(HOST_OS),Darwin)
            # Fixes a duplicate library warning with Homebrew GCC
            LDFLAGS += -no_warn_duplicate_libraries
        endif

        LDLIBS     += $(shell echo "$(LINKER_ARGS)" \
            | grep -Eo -- '-(l|B)[^[:space:]]+|[^[:space:]]*/lib[^[:space:]]+\.(so|a|dylib)\.?[^[:space:]]*|[^[:space:]]*/crt[^[:space:]]\.o' \
            | grep -Ev -- '-lto_library|libLTO' \
            | tr '\n' ' ')

    endif
endif

E :=
$(info $(E))
$(info $(E)  Host OS: $(HOST_OS))
$(info $(E)Host Arch: $(HOST_ARCH))
$(info $(E))
$(info $(E)Toolchain: $(COMPILER))
$(info $(E)       CC: $(CC))
$(info $(E)      CXX: $(CXX))
$(info $(E)       AR: $(AR))
$(info $(E)       AS: $(AS))
$(info $(E)   RANLIB: $(RANLIB))
$(info $(E)  OBJCOPY: $(OBJCOPY))
$(info $(E)    STRIP: $(STRIP))
$(info $(E))
$(info $(E)   Linker: $(LINKER))
$(info $(E)       LD: $(LD))
$(info $(E)  LDFLAGS: $(LDFLAGS))
$(info $(E)   LDLIBS: $(LDLIBS))
$(info $(E))
