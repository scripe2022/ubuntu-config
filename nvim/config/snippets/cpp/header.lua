return {
	s(
        "header",
        fmt(
            -- "// compile: make " .. vim.fn.expand("%:t:r") .. "\n" ..
            "// comp := g++ ".. vim.fn.expand("%:t") .. " /home/jyh/.local/include/cpglib/print.o -o " .. vim.fn.expand("%:t:r") .. " -O1 -std=gnu++20 -Wall -Wextra -Wshadow -D_GLIBCXX_ASSERTIONS -fmax-errors=2 -DLOCAL\n" ..
            "// run  := ./" .. vim.fn.expand("%:t:r") .. " < data.in\n" ..
            "// dir  := .\n" ..
            "// wid  :=\n" ..
            "#include <bits/stdc++.h>\n" ..
            "using namespace std;\n" ..
            "#pragma GCC optimize(\"unroll-loops\")\n" ..
            "#pragma GCC target(\"avx2,bmi,bmi2,lzcnt,popcnt\")\n" ..
            "#ifdef LOCAL\n" ..
            "#include <cpglib/print.h>\n" ..
            "#define debug(x...) _debug_print(0, #x, x);\n" ..
            "#define Debug(x...) _debug_print(1, #x, x);\n" ..
            "#define DEBUG(x...) _debug_print(2, #x, x);\n" ..
            "std::ifstream terminal(\"/dev/tty\");\n" ..
            "#define PP cerr<<\"\033[1;30mpause...\\e[0m\",terminal.ignore();\n" ..
            "#else\n" ..
            "#define debug(x...)\n" ..
            "#define Debug(x...)\n" ..
            "#define DEBUG(x...)\n" ..
            "#define PP\n" ..
            "#endif\n" ..
            "template<typename...Args> void print_(Args...args){{((cout<<args<<\" \"),...)<<endl;}}\n" ..
            "#define rep(i,a,b) for(int i=(a);i<(int)(b);++i)\n" ..
            "#define sz(v) ((int)(v).size())\n" ..
            "#define print(...) print_(__VA_ARGS__);\n" ..
            "#define FIND(a, x) ((find(a.begin(),a.end(),(x))!=a.end())?1:0)\n" ..
            "#define cmin(x,...) x=min({{(x),__VA_ARGS__}})\n" ..
            "#define cmax(x,...) x=max({{(x),__VA_ARGS__}})\n" ..
            "#define INTMAX (int)(9223372036854775807)\n" ..
            "#define INF (int)(1152921504606846976)\n" ..
            "#define NaN (int)(0x8b88e1d0595d51d1)\n" ..
            "#define double long double\n" ..
            "#define int long long\n" ..
            "#define uint unsigned long long\n" ..
            "#define endl \"\\n\"\n" ..
            "#define MAXN 200010\n" ..
            "\n" ..
            "int32_t main() {{\n" ..
            "    ios::sync_with_stdio(false); cin.tie(nullptr); cout.tie(nullptr);\n" ..
            "\n" ..
            "    {}\n" ..
            "\n" ..
            "    return 0;\n" ..
            "}}\n"
        , {
            i(1, "")
        })

    )
}
