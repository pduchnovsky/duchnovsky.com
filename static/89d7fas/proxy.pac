function FindProxyForURL(url, host) {
  if (
    shExpMatch(host, "*airvpn.org") ||
    shExpMatch(host, "*free-mp3-download.net") ||
    shExpMatch(host, "*torrentleech.org") ||
    shExpMatch(host, "*tleechreload.org") ||
    shExpMatch(host, "*sktorrent.eu")
  )
    return "PROXY 10.10.10.2:8888; PROXY 10.10.10.22:8888";
  return "DIRECT";
}
