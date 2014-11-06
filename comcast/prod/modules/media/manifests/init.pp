class media {

    include media::imagemagick
    include media::image-exiftool
    include media::ffmpeg

    package { 'libmediainfo':
	ensure	=> present,
    }

    package { 'mediainfo' :
	ensure	=> present,
    }

    # this service will be installed and shut down
    # for tomcat servers
    include media::monit

}
