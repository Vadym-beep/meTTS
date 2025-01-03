#!/usr/bin/lua
-- I am trying to make my own basic Text-To-Speech program
-- that speaks in Italian

-- This program was created on Linux and was meant to be used on Linux.
-- It is for my own use and I did not implement any code for cross-platform
-- compatibility.

-- This program uses SDL2 and SDL_mixer to play sound files
-- which can be installed on Arch Linux with:

-- # pacman -S sdl2

-- This program requires the luarocks package "lua-sdl2" for playing audio
-- which can be installed with:

-- $ luarocks install lua-sdl2

-- This program uses a custom made program just to get the lenght of each sound
-- the source code file is called WAVlength.c
-- and should be compiled with the following command:

-- $ gcc -lSDL2main -lSDL2 -O3 -lm -s WAVlength.c -o WL

-- for the program to function correctly
-- and the executable should be placed next to the main.lua file and should
-- be named "WL"

---------------------------------------------------------------
--                       NOTES                          --
-- Ideas for non-separated text processing:
-- Use the gmatch() function to capture strings which contain at least one
-- character of anything other than the desired separator.
-- RegEx
-- Something
--                                                      --
-- Phonemes represented by multiple letters in Italian:
-- GL, SC, GN
--                                                      --
-- Modifiers and special strings:
-- [PAUSE] - Short pause
-- PROVA1 - Play the test sound "PROVA1.wav"
----------------------------------------------------------------

audioFolderPath = "./audio/" -- If the folder doesn't already exist, create it yourself.
fileExtension = ".wav"       -- Note: it only supports wav, don't change this.
ERROR_COUNT = 0
SDL = require("SDL")
assert(SDL.init {
  SDL.flags.Audio
})
print(string.format("Using SDL %d.%d.%d",
  SDL.VERSION_MAJOR,
  SDL.VERSION_MINOR,
  SDL.VERSION_PATCH
))
MIXER = require("SDL.mixer")
assert(MIXER.openAudio(44100, SDL.audioFormat.S16, 2, 1024))

----------------------------------------------------------------
-- Text Processing
-- Note: for now you will need to enter the hard C as K and soft G as J
-- For now, you will have to enter strings like this:
-- c i a o
-- sc i a r e
-- k o n i gl i o
-- p a r m a r e j j i o
print("Please enter text: ")
text = io.read()

while text == nil or text == "" do
  print("Please provide input.")
  text = io.read()
end

function capture(cmd)
  local out = io.popen(cmd, 'r')
  if out ~= nil then
    local outstr = out:read('*all')
    out:close()
    return outstr
  elseif out == nil then -- error handling, I usually don't do this (i'm not a
    -- really good programmer)
    print("Uh oh! Command failed! Something bad happened! The output is nil!")
    ERROR_COUNT = ERROR_COUNT + 1
    return "0" -- I made it 0 so 0 milliseconds
  end
end

function getSoundLength(fileName) -- I made it error handle and now it's more complicated than a single return statement.
  -- could have used ffprobe but I've already made a program specifically to
  -- get the sound length
  local x, y = pcall(tonumber, capture("./WL " .. fileName)) -- idk how to name the variable so it's just x for now
  if x == false or y == nil then
    print("Uh oh! Something bad happened! Either the tonumber function failed or it returned nil. That's weird.")
    ERROR_COUNT = ERROR_COUNT + 1
    return "0" -- I made it 0 so 0 milliseconds
  else
    return y
  end
end

function splitPhonemes(inputstr)
  local sep = " "
  local t = {}
  for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
    table.insert(t, str)
  end
  return t
end

function fileExists(name)
  local f = io.open(name, "r")
  if f ~= nil then
    io.close(f)
    return true
  else
    return false
  end
end

function playFile(fileName)
  if not fileExists(fileName) then
    print("Are you sure that file exists? If it does, I can't read it!")
    ERROR_COUNT = ERROR_COUNT + 1
    return
  end
  local status, sound = pcall(MIXER.loadWAV, fileName)
  if sound == nil then
    print("Uh oh! Something bad happened! loadWAV failed. What the fuck? Why is it nil?") -- programmers have a sense of humour too!
    ERROR_COUNT = ERROR_COUNT + 1
  elseif status ~= false and sound ~= nil then                                            -- error handling, making it more complicated
    local soundLength = getSoundLength(fileName)
    sound:playChannel(1)
    print("Sound length: " .. soundLength) -- debug
    SDL.delay(soundLength)
  elseif status == false then
    print("Uh oh! Something bad happened! loadWAV failed.")
    ERROR_COUNT = ERROR_COUNT + 1
  end
end

function pronounce(phoneme)
  local phonemeFilename = audioFolderPath .. phoneme .. fileExtension
  print("Pronouncing: " .. phonemeFilename) -- debug
  playFile(phonemeFilename)
end

function pronouncePhonemes(phonemeList)
  for _, v in ipairs(phonemeList) do
    pronounce(v)
  end
end

pronouncePhonemes(splitPhonemes(text))
SDL.quit()

if ERROR_COUNT > 0 then
  print("WARNING! An error happened in the program at least once along the way!")
  print("Error count: " .. ERROR_COUNT)
end
