return {
    s(
        "timestart",
        fmt("// D_BEGIN: debug time start\n#include <chrono>\nauto TEST_TIME_START = std::chrono::high_resolution_clock::now();\n// D_END:{}\n", {
            i(1, ""),
        })
    ),
}
