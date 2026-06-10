/*
 * Verifies that the CSpice shared library actually re-exports CSPICE entry
 * points. This test deliberately links ONLY against the CSpice shared library
 * (not the static CSPICE archive), so if the re-export mechanism fails on a
 * given platform the link step fails here -- making this a per-platform check
 * that the whole-archive / export-all configuration works.
 *
 * Both functions exercised need no SPICE kernels:
 *   - tkvrsn_c : returns the toolkit version string
 *   - vnorm_c  : pure vector math (a different CSPICE object file)
 */
#include <SpiceUsr.h>
#include <stdio.h>
#include <string.h>

int main(void)
{
    ConstSpiceChar * version = tkvrsn_c("TOOLKIT");
    if (version == NULL)
    {
        fprintf(stderr, "tkvrsn_c returned NULL\n");
        return 1;
    }
    printf("CSPICE toolkit version: %s\n", version);
    if (strncmp(version, "CSPICE", 6) != 0)
    {
        fprintf(stderr, "unexpected toolkit version string: %s\n", version);
        return 2;
    }

    SpiceDouble v[3] = { 3.0, 4.0, 0.0 };
    SpiceDouble n = vnorm_c(v);
    printf("vnorm_c({3,4,0}) = %f\n", n);
    if (n < 4.999 || n > 5.001)
    {
        fprintf(stderr, "vnorm_c returned unexpected value: %f\n", n);
        return 3;
    }

    return 0;
}
