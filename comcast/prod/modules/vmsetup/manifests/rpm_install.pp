
define vmsetup::rpm_install (
   $rpm_package = $title,
   $rpm_source = "/var/tmp",
) {
   package { $rpm_package :
    name	=> $rpm_package,
    ensure	=> installed,
    provider => 'rpm',
    source	=> "$rpm_source/$rpm_package*.rpm",
    require     => Exec ['unpack tar-gz']
  }
  
}
