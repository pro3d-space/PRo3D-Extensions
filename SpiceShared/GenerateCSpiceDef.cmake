# Generates a module-definition (.def) file that exports every public symbol
# in a static library, by parsing the output of `dumpbin /LINKERMEMBER:1`.
#
# Invoked at build time:
#   cmake -DCSPICE_LIB=<path> -DDEF_OUT=<path> -P GenerateCSpiceDef.cmake
#
# This is the Windows counterpart to -force_load / --whole-archive: it lets the
# CSpice shared library re-export the full CSPICE C API. It is required because
# WINDOWS_EXPORT_ALL_SYMBOLS only exports symbols from a target's own object
# files, not symbols coming from a linked static library.

if(NOT CSPICE_LIB OR NOT DEF_OUT)
    message(FATAL_ERROR "CSPICE_LIB and DEF_OUT must be set")
endif()

execute_process(
    COMMAND dumpbin /LINKERMEMBER:1 "${CSPICE_LIB}"
    OUTPUT_VARIABLE _dump
    ERROR_VARIABLE _err
    RESULT_VARIABLE _rc)

if(NOT _rc EQUAL 0)
    message(FATAL_ERROR "dumpbin failed (${_rc}): ${_err}")
endif()

string(REPLACE "\r" "" _dump "${_dump}")
string(REPLACE "\n" ";" _lines "${_dump}")

# Data lines look like:  "        0000003C    tkvrsn_c"
# Export only the documented CSPICE C API (the *_c entry points). This is the
# surface managed consumers P/Invoke and avoids exporting f2c-internal symbols
# (e.g. "mode", "size") that are not real linkable definitions.
set(_symbols "")
foreach(_line IN LISTS _lines)
    if(_line MATCHES "^[ \t]*[0-9A-Fa-f]+[ \t]+([A-Za-z_][A-Za-z0-9_]*)[ \t]*$")
        set(_name "${CMAKE_MATCH_1}")
        if(_name MATCHES "_c$")
            list(APPEND _symbols "${_name}")
        endif()
    endif()
endforeach()

list(REMOVE_DUPLICATES _symbols)
list(LENGTH _symbols _count)
if(_count EQUAL 0)
    message(FATAL_ERROR "No exportable symbols parsed from ${CSPICE_LIB} -- dumpbin format may have changed")
endif()

set(_content "EXPORTS\n")
foreach(_sym IN LISTS _symbols)
    string(APPEND _content "    ${_sym}\n")
endforeach()

file(WRITE "${DEF_OUT}" "${_content}")
message(STATUS "CSpice: wrote ${_count} exports to ${DEF_OUT}")
