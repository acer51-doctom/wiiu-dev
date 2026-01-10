cmake_minimum_required(VERSION 3.13)

# 1. DIRECT BYPASS
set(WUT_ROOT "/opt/devkitpro/wut")
include("${WUT_ROOT}/share/wut.cmake")

project(AnotherClock4WiiU C)

# 2. Add library and include locations
include_directories("${WUT_ROOT}/include")
link_directories("${WUT_ROOT}/lib")

add_executable(AnotherClock4WiiU source/main.c)

# 3. LINKING LOGIC
# whb: The homebrew base we just installed
# wut: The core Wii U library
# coreinit: This tells the linker to look for Wii U system functions
target_link_libraries(AnotherClock4WiiU whb wut coreinit)

# 4. Create the 3 formats
wut_create_rpx(AnotherClock4WiiU)
wut_create_wuhb(AnotherClock4WiiU
    NAME "Another Clock 4 Wii U"
    AUTHOR "Acer_51"
    ICON "${CMAKE_CURRENT_SOURCE_DIR}/assets/icon.png"
)

# 5. Legacy ELF
add_custom_command(TARGET AnotherClock4WiiU POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy AnotherClock4WiiU.elf AnotherClock4WiiU_legacy.elf
)