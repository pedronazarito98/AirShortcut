#ifndef AirShortcutMultitouchBridge_h
#define AirShortcutMultitouchBridge_h

#include <stdbool.h>
#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

typedef struct {
    int32_t identifier;
    int32_t state;
    float normalizedX;
    float normalizedY;
    float velocityX;
    float velocityY;
    float pressure;
    float majorAxis;
    float minorAxis;
    float angle;
    float density;
} ASRawTouch;

typedef void (*ASMultitouchFrameCallback)(
    const ASRawTouch *touches,
    int32_t touchCount,
    double timestamp,
    int32_t frame,
    void *context
);

typedef void *ASMultitouchHandle;

bool ASMultitouchFrameworkIsAvailable(void);
ASMultitouchHandle ASMultitouchCreate(
    ASMultitouchFrameCallback callback,
    void *context
);
int32_t ASMultitouchStart(ASMultitouchHandle handle);
void ASMultitouchStop(ASMultitouchHandle handle);
void ASMultitouchDestroy(ASMultitouchHandle handle);
const char *ASMultitouchLastError(void);

#ifdef __cplusplus
}
#endif

#endif
