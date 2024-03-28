# nlohmann
rm -rf $HOME/.local/include/nlohmann
git clone https://github.com/nlohmann/json.git
cp -r json/include/nlohmann/ $HOME/.local/include/nlohmann
rm -rf json

# boost
rm -rf $HOME/.local/include/boost
curl -Ls https://boostorg.jfrog.io/artifactory/main/release/1.84.0/source/boost_1_84_0.tar.gz | tar xz
cp -r boost_1_84_0/boost/ $HOME/.local/include/boost
rm -rf boost_1_84_0

# jngen
rm -f $HOME/.local/include/jngen.h
curl https://raw.githubusercontent.com/ifsmirnov/jngen/master/jngen.h -o $HOME/.local/include/jngen.h

# cpglib
rm -rf $HOME/.local/include/cpglib
git clone https://github.com/scripe2022/cpglib.git $HOME/.local/include/cpglib

# precompile
make -C $HOME/.local/include/cpglib
sudo g++ /usr/include/x86_64-linux-gnu/c++/13/bits/stdc++.h -O1 -std=gnu++20 -Wall -Wextra -Wshadow -D_GLIBCXX_ASSERTIONS -fmax-errors=2 -DLOCAL
