cmake_minimum_required(VERSION 3.13)

# 1. Load the Wii U rules
set(WUT_ROOT "/opt/devkitpro/wut")
include("${WUT_ROOT}/share/wut.cmake")

project(wiiu-hello-world C)

# 2. Tell the linker WHERE the libraries are
link_directories("${WUT_ROOT}/lib")
include_directories("${WUT_ROOT}/include")

add_executable(wiiu-hello-world main.c)

# 3. Link only to wut (since whb functions are usually in the headers you have)
# If you get "undefined reference" errors later, we will add 'whb' back.
target_link_libraries(wiiu-hello-world wut)

# 4. Create the Wii U executable
wut_create_rpx(wiiu-hello-world)