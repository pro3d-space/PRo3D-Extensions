# CSpice: a shared library that re-exports the complete CSPICE C API.
#
# CSPICE is distributed as a static archive. A normal link only pulls in the
# object files that are actually referenced, so to expose the whole API for
# direct P/Invoke we force the entire archive into the shared library and make
# sure its symbols are exported. The output name is "cspice" on every platform
# (libcspice.dylib / libcspice.so / cspice.dll) so consumers can simply
# DllImport("cspice").

add_library(CSpice SHARED src/reexport.c)
set_target_properties(CSpice PROPERTIES OUTPUT_NAME cspice C_STANDARD 11)
target_include_directories(CSpice PRIVATE ${CSPICE_INCLUDE_DIR})

if(MSVC)
    # /WHOLEARCHIVE pulls in every object; WINDOWS_EXPORT_ALL_SYMBOLS exports them.
    set_target_properties(CSpice PROPERTIES WINDOWS_EXPORT_ALL_SYMBOLS ON)
    target_link_libraries(CSpice PRIVATE ${CSPICE_LIBRARY_RELEASE})
    target_link_options(CSpice PRIVATE "/WHOLEARCHIVE:${CSPICE_LIBRARY_RELEASE}")
elseif(APPLE)
    # -force_load includes the whole archive; symbols keep default visibility.
    target_link_options(CSpice PRIVATE "-Wl,-force_load,${CSPICE_LIBRARY_RELEASE}")
else()
    # Linux / other UNIX: --whole-archive + libm for the f2c math runtime.
    target_link_options(CSpice PRIVATE "-Wl,--whole-archive,${CSPICE_LIBRARY_RELEASE},--no-whole-archive")
    target_link_libraries(CSpice PRIVATE m)
endif()

install(TARGETS CSpice   RUNTIME DESTINATION bin COMPONENT runtime
                         LIBRARY DESTINATION bin COMPONENT runtime
                         ARCHIVE DESTINATION lib COMPONENT develop)

# Test: links ONLY against the CSpice shared lib, so a successful link + run
# proves the re-export works on this platform.
add_executable(test_reexport test/test_reexport.c)
target_include_directories(test_reexport PRIVATE ${CSPICE_INCLUDE_DIR})
target_link_libraries(test_reexport PRIVATE CSpice)
add_test(NAME cspice_reexport COMMAND test_reexport)
