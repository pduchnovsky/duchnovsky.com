function FindProxyForURL(url, host) {
  if (
    shExpMatch(host, "*free-mp3-download.net") ||
    shExpMatch(host, "*warforum.cz") ||
    shExpMatch(host, "*torrentleech.org") ||
    shExpMatch(host, "*tleechreload.org") ||
    shExpMatch(host, "*sktorrent.eu") ||
    shExpMatch(host, "*rutracker.org")
  )
    return "PROXY 10.10.10.2:8888";
  // Eveything else goes direct
  return "DIRECT";
}
