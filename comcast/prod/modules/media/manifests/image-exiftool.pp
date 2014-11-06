class media::image-exiftool {

$img_exif_pkg	= 'Image-ExifTool-9.65'
$tar_file	= "$img_exif_pkg.tar"
$tar_url	= "http://yumrepo.sys.comcast.net/ssd/media-tars/$tar_file"

    exec { 'wget_tar_file' :
	cwd	=> '/var/tmp',
	path	=> '/bin:/usr/bin',
	command	=> "wget $tar_url > /tmp/wget_$img_exif_pkg",
	creates	=> "/var/tmp/$tar_file",
	require	=> Package [ 'ImageMagick' ],
    }

    exec { 'untar_tar_file' :
	cwd	=> '/var/tmp',
	path	=> '/bin:/usr/bin',
	command	=> "tar -xvf $tar_file > /tmp/tar_$tar_file",
	creates	=> "/var/tmp/$img_exif_pkg",
	require	=> Exec [ 'wget_tar_file' ],
    }

    exec { 'perl_make' :
	cwd	=> "/var/tmp/$img_exif_pkg",
	path	=> '/bin:/usr/bin',
	command	=> 'perl Makefile.PL > /tmp/perl_make',
	creates	=> "/var/tmp/$img_exif_pkg/Makefile",
	require	=> Exec [ 'untar_tar_file' ],
    }

    exec { 'make_install' :
	cwd	=> "/var/tmp/$img_exif_pkg",
	path	=> '/bin:/usr/bin',
	command	=> 'make install > /tmp/make_install',
	creates	=> '/usr/local/bin/exiftool',
	require	=> Exec [ 'perl_make' ],
    }

}
