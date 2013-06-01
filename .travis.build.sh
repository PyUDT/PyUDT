#!/bin/sh
set -e

# Directories.
root_dir=`pwd`
install_dir="$root_dir/_travis/install"

# Shortcuts.
git_clone="git clone --quiet --recursive"

# Create layout.
rm -rf "$install_dir"
mkdir -p "$install_dir"
mkdir -p "$install_dir/lib"
mkdir -p "$install_dir/include/udt"

# Current Python version
export PYTHON_VERSION=`python -c 'import sys; print(sys.version[:3])'`

# Setup environment variables.
export LD_LIBRARY_PATH="$install_dir/lib:$LD_LIBRARY_PATH"
export PKG_CONFIG_PATH="$install_dir/lib/pkgconfig:$PKG_CONFIG_PATH"
export CFLAGS="-I$install_dir/include -L$install_dir/lib"
export CXXFLAGS="-I$install_dir/include -L$install_dir/lib"

# Build package
echo "Building UDT..."

# move library and headers to appropriate location 
cd ${root_dir}/udt/UDT4

echo "Installing package files..."
make -j1                               
cp src/libudt.so ${install_dir}/lib/
cp src/udt.h ${install_dir}/include/udt/udt.h

cd ../..

echo "Calling setup.py..."
python ${root_dir}/setup.py build
echo "Installing PyUDT..."
sudo python ${root_dir}/setup.py install --prefix="~/virtualenv/python$PYTHON_VERSION"

echo "Running tests..."
cd example
./run_tests.sh
cd ..
