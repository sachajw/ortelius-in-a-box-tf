#/bin/bash
# Monitors the config map and reloads bird on change

inotifywait -m -e moved_to /usr/local/etc |
while read events ; do
  /usr/local/sbin/birdc configure
done
