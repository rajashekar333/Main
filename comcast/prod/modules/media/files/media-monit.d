check process media with pidfile /opt/xplat/media/media.pid
  alert mohamed_haleem@comcast.com only on { timeout, nonexist }
  start program = "/opt/xplat/media/bin/startup.sh"
    as uid xplat and gid xplat
  stop program = "/opt/xplat/media/bin/shutdown.sh"
    as uid xplat and gid xplat
