#!/usr/bin/liquidsoap
songs = mksafe(playlist("playlist/Airtim/"))
stationIDs = playlist("playlist/stationIDs/")
stationIDsTimed = delay(1800., stationIDs)

recorded_notice = sine(duration=10.0)
shows = sine(duration=5.0, 300.0)
shows_with_notices = prepend(shows, fun(_) -> recorded_notice)

song_content = fallback([stationIDsTimed, songs])
show_content = fallback([shows_with_notices, song_content])

play_show = interactive.bool("play_show", false)
content = switch([(play_show, show_content), ({true}, song_content)])

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

def on_air(~protocol,~data,~headers,uri) =
  ignore(server.execute("var.set onair = true"))
  source.skip(content)
  http_response(
    protocol=protocol,
    code=301,
    data="Now on air!"
  )
end

def off_air(~protocol,~data,~headers,uri) =
  source.skip(content) #removes station ID queued due to delay
  ignore(server.execute("var.set onair = false"))
  http_response(
    protocol=protocol,
    code=301,
    data="Now off air."
  )
end

def play_shows(~protocol,~data,~headers,uri) =
  ignore(server.execute("var.set play_show = true"))
  http_response(
    protocol=protocol,
    code=301,
    data="Now playing recorded shows."
  )
end 

def stop_shows(~protocol,~data,~headers,uri) =
  source.skip(content) #removes station ID queued due to delay
  ignore(server.execute("var.set play_show = false"))
  http_response(
    protocol=protocol,
    code=301,
    data="Now not playing recorded shows."
  )
end

harbor.http.register(port=8005,method="GET", "onair", on_air)
harbor.http.register(port=8005,method="GET", "offair", off_air)
harbor.http.register(port=8005,method="GET", "playshows", play_shows)
harbor.http.register(port=8005,method="GET", "stopshows", stop_shows)
