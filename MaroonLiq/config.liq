#!/usr/bin/liquidsoap
radio = single("/playlist/test.mp3")
output.icecast(%vorbis,
  host = "localhost", port = 8000,
  password = "hackme", mount = "basic-radio.ogg", 
  fallible=true,
  radio)
