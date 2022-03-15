#include <stdio.h>
#include <string.h>
#include <pulse/pulseaudio.h>

typedef struct pa_devicelist
{
    uint8_t initialized;
    char name[512];
    uint32_t index;
    char description[256];
} pa_devicelist_t;

typedef struct pa_deviceblock
{
    pa_devicelist_t pa_input_devicelist[16];
    pa_devicelist_t pa_output_devicelist[16];
    pa_devicelist_t pa_sinkinput_devicelist[16];
    pa_devicelist_t pa_sourceoutput_devicelist[16];
} pa_deviceblock_t;

pa_deviceblock_t getDevices();
