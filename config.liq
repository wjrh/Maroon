#!/usr/bin/liquidsoap
radio = sine()
output.icecast(%vorbis,
  host = "wjrh.org", port = 8000,
  password = "WJRHSourceHighSecurity1456", mount = "basic-radio.ogg",
  radio)
