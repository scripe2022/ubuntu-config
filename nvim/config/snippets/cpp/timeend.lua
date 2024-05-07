return {
    s(
        "timeend",
        fmt(
            "// D_BEGIN: time end\n"
                .. "auto TEST_TIME_END = std::chrono::high_resolution_clock::now();\n"
                .. "auto TEST_TIME_DURATION = std::chrono::duration_cast<std::chrono::microseconds>(TEST_TIME_END - TEST_TIME_START);\n"
                .. 'std::cerr << "Running time: " << TEST_TIME_DURATION.count() / 1000 << "ms" << std::endl;\n'
                .. "// D_END:{}\n",
            {
                i(1, ""),
            }
        )
    ),
}
