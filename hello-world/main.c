#include <whb/proc.h>
#include <whb/log.h>
#include <whb/log_console.h>
#include <unistd.h>

int main(int argc, char **argv) {
    WHBProcInit();

    while (WHBProcIsRunning()) {
        // 1. Reset the console to the top every frame
        WHBLogConsoleInit();
        WHBLogConsoleSetColor(0x00000000); // Black background

        // 2. Print your messages
        WHBLogPrintf("Hello, world!");
        WHBLogPrintf(""); // Empty line for spacing
        WHBLogPrintf(""); // Empty line for spacing
        WHBLogPrintf(""); // Empty line for spacing
        WHBLogPrintf(""); // Empty line for spacing
        WHBLogPrintf("Press HOME to exit.");

        // 3. Draw to the screen
        WHBLogConsoleDraw();

        // 4. Free the console so it can be re-initialized next loop
        WHBLogConsoleFree();

        // Cap at 60fps to keep it steady
        usleep(16666);
    }

    WHBProcShutdown();
    return 0;
}