/*
 * This translation unit intentionally contains no code.
 *
 * The CSpice shared library exists purely to re-export the full CSPICE C API
 * so that managed consumers (e.g. PRo3D.SPICE) can P/Invoke SPICE entry points
 * directly. The actual symbols come from the static CSPICE archive, which is
 * force-loaded in its entirety at link time (see ../CMakeLists.txt):
 *   - Windows : /WHOLEARCHIVE + WINDOWS_EXPORT_ALL_SYMBOLS
 *   - macOS   : -Wl,-force_load
 *   - Linux   : -Wl,--whole-archive
 *
 * CMake requires at least one source file for a SHARED target, hence this file.
 */
