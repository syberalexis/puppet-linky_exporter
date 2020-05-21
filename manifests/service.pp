# @summary This class manages service
#
# @param ensure
#  State ensured from linky_exporter service.
# @param user
#  User running linky_exporter.
# @param group
#  Group under which linky_exporter is running.
# @param listen_address
#  linky exporter listem address (required to be accessible).
# @param listen_port
#  linky exporter listen port (required to be accessible).
# @param serial_device
#  linky serial device.
# @param baud_rate
#  linky baud rate.
# @param bin_dir
#  Directory where binaries are located.
# @example
#   include linky_exporter::service
class linky_exporter::service (
  Variant[Stdlib::Ensure::Service, Enum['absent']] $ensure         = $linky_exporter::service_ensure,
  String                                           $user           = $linky_exporter::user,
  String                                           $group          = $linky_exporter::group,
  Stdlib::Host                                     $listen_address = $linky_exporter::listen_address,
  Stdlib::Port                                     $listen_port    = $linky_exporter::listen_port,
  Stdlib::Absolutepath                             $serial_device  = $linky_exporter::serial_device,
  Integer                                          $baud_rate      = $linky_exporter::baud_rate,
  Stdlib::Absolutepath                             $bin_dir        = $linky_exporter::bin_dir,
) {
  $_file_ensure    = $ensure ? {
    'running' => file,
    'stopped' => file,
    default   => absent,
  }
  $_service_ensure = $ensure ? {
    'running' => running,
    default   => stopped,
  }

  file { '/lib/systemd/system/linky-exporter.service':
    ensure  => $_file_ensure,
    content => template('linky_exporter/service.erb'),
    notify  => Service['linky-exporter']
  }
  service { 'linky-exporter':
    ensure => $_service_ensure,
    enable => true,
  }

  File['/lib/systemd/system/linky-exporter.service'] -> Service['linky-exporter']
}
