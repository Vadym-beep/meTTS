#include "math.h"
#include "stdio.h"
#include "stdlib.h"
#include <SDL2/SDL.h>
#include <SDL2/SDL_audio.h>
#include <SDL2/SDL_timer.h>

double WAVlenght(const char *filename, const double freq) {
  SDL_AudioSpec spec;
  uint32_t audioLen;
  uint8_t *audioBuf;
  double seconds = 0.0;

  if (SDL_LoadWAV(filename, &spec, &audioBuf, &audioLen) != NULL) {
    // we aren't using the actual audio in this example
    SDL_FreeWAV(audioBuf);
    uint32_t sampleSize = SDL_AUDIO_BITSIZE(spec.format) / 8;
    uint32_t sampleCount = audioLen / sampleSize;
    // could do a sanity check and make sure (audioLen % sampleSize) is 0
    uint32_t sampleLen = 0;
    if (spec.channels) {
      sampleLen = sampleCount / spec.channels;
    } else {
      // spec.channels *should* be 1 or higher, but just in case
      sampleLen = sampleCount;
    }
    seconds = (double)sampleLen / (double)freq;
  } else {
    // uh-oh!
    fprintf(stderr, "ERROR: can't load: %s: %s\n", filename, SDL_GetError());
  }

  return seconds * 1000;
}

int main(int argc, char *argv[]) {
  // returns zero on success else non-zero
  if (SDL_Init(SDL_INIT_AUDIO) != 0) {
    printf("error initializing SDL: %s\n", SDL_GetError());
    SDL_Quit();
    return 1;
  }
  int num = round(WAVlenght(argv[1], 44100));
  char out[20];
  snprintf(out, 20, "%d", num);
  printf("%s\n", out);
  SDL_Quit();
  return 0;
}