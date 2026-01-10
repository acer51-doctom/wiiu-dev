#include <stdio.h>
#include <coreinit/time.h>
#include <coreinit/screen.h>
#include <whb/proc.h>
#include <whb/log.h>
#include <whb/log_console.h>

int main(int argc, char **argv) {
    WHBProcInit();
    WHBLogConsoleInit();

    // Set up screens for output
    OSScreenInit();
    size_t tv_size = OSScreenGetBufferSizeEx(SCREEN_TV);
    size_t drc_size = OSScreenGetBufferSizeEx(SCREEN_DRC);
    
    // In many legacy environments, you need to manually manage buffers
    // but WHBLogConsole often handles this. If screens are black, 
    // we'd add manual buffer allocation here.

    while (WHBProcIsRunning()) {
        OSScreenClearBufferEx(SCREEN_TV, 0);
        OSScreenClearBufferEx(SCREEN_DRC, 0);

        // --- FIXED TIME LOGIC ---
        OSCalendarTime rtc;
        OSTick ticks = OSGetTime(); // Changed from OSTicks to OSTick
        OSTicksToCalendarTime(ticks, &rtc);

        char timeStr[64];
        
        // Members in modern WUT OSCalendarTime:
        // tm_year, tm_mon, tm_mday, tm_hour, tm_min, tm_sec
        snprintf(timeStr, sizeof(timeStr), "Date: %04d-%02d-%02d", 
                 rtc.tm_year, rtc.tm_mon + 1, rtc.tm_mday);
        OSScreenPutFontEx(SCREEN_TV, 0, 2, timeStr);
        OSScreenPutFontEx(SCREEN_DRC, 0, 2, timeStr);

        snprintf(timeStr, sizeof(timeStr), "Time: %02d:%02d:%02d", 
                 rtc.tm_hour, rtc.tm_min, rtc.tm_sec);
        OSScreenPutFontEx(SCREEN_TV, 0, 3, timeStr);
        OSScreenPutFontEx(SCREEN_DRC, 0, 3, timeStr);

        OSScreenPutFontEx(SCREEN_TV, 0, 5, "Press HOME to exit.");
        OSScreenPutFontEx(SCREEN_DRC, 0, 5, "Press HOME to exit.");

        OSScreenFlipBuffersEx(SCREEN_TV);
        OSScreenFlipBuffersEx(SCREEN_DRC);
    }

    WHBLogConsoleFree();
    WHBProcShutdown();
    return 0;
}