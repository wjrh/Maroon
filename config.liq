#!/usr/bin/liquidsoap
songs = mksafe(playlist("playlist/Airtim/"))
stationIDs = playlist("playlist/stationIDs/")
stationIDsTimed = delay(100., stationIDs)
#stationIDsTimed = stationIDs

content = fallback([stationIDsTimed, songs])

onair = interactive.bool("onair", false)
to_dj_booth = switch([(onair, blank()), ({true}, content)])

output.icecast(%vorbis,
  host = "localhost", port = 8000,
  password = "hackme", mount = "to_dj_booth.ogg", fallible=true, to_dj_booth)

from_dj_booth = input.http("http://localhost:8000/to_dj_booth.ogg")
radio = fallback(track_sensitive=false, [strip_blank(max_blank=15., from_dj_booth), content]) 

output.icecast(%vorbis,
  host = "localhost", port = 8000,
  password = "hackme", mount = "wjrh.ogg", radio)

def turn_off_content(~protocol,~data,~headers,uri) =
  ignore(server.execute("var.set onair = true"))
  source.skip(content)
  http_response(
    protocol=protocol,
    code=301,
    data="Now on air!"
  )
end

def turn_on_content(~protocol,~data,~headers,uri) =
  source.skip(content) #removes station ID queued due to delay
  ignore(server.execute("var.set onair = false"))
  http_response(
    protocol=protocol,
    code=301,
    data="Now off air."
  )
end

harbor.http.register(port=8005,method="GET", "on", turn_off_content)
harbor.http.register(port=8005,method="GET", "off", turn_on_content)
