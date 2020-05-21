# @summary This module manages linky Exporter
#
# Init class of linky Exporter module. It can installes linky Exporter binaries and single Service.
#
# @param version
#  linky exporter release. See https://github.com/anclrii/linky-Exporter/releases
# @param os
#  Operating system.
# @param base_dir
#  Base directory where linky is extracted.
# @param bin_dir
#  Directory where binaries are located.
# @param base_url
#  Base URL for linky Exporter.
# @param download_url
#  Complete URL corresponding to the linky exporter release, default to undef.
# @param extract_command
#  Custom command passed to the archive resource to extract the downloaded archive.
# @param manage_user
#  Whether to create user for linky_exporter or rely on external code for that.
# @param manage_group
#  Whether to create user for linky_exporter or rely on external code for that.
# @param user
#  User running linky_exporter.
# @param group
#  Group under which linky_exporter is running.
# @param user_shell
#  if requested, we create a user for linky_exporter. The default shell is false. It can be overwritten to any valid path.
# @param extra_groups
#  Add other groups to the managed user.
# @param service_ensure
#  State ensured from linky_exporter service.
# @param listen_address
#  linky exporter listen address.
# @param listen_port
#  linky exporter listen port (required to be accessible).
# @param serial_device
#  linky serial device.
# @param baud_rate
#  linky baud rate.
# @example
#   include linky_exporter
class linky_exporter (
  String                                           $version         = '1.0.0',
  String                                           $os              = downcase($facts['kernel']),

  # Installation
  Stdlib::Absolutepath                             $base_dir        = '/opt',
  Stdlib::Absolutepath                             $bin_dir         = '/usr/local/bin',
  Stdlib::HTTPUrl                                  $base_url        = 'https://github.com/syberalexis/linky-exporter/releases/download',
  Optional[Stdlib::HTTPUrl]                        $download_url    = undef,
  Optional[String]                                 $extract_command = undef,

  # User Management
  Boolean                                          $manage_user     = false,
  Boolean                                          $manage_group    = false,
  String                                           $user            = 'root',
  String                                           $group           = 'root',
  Stdlib::Absolutepath                             $user_shell      = '/bin/false',
  Array[String]                                    $extra_groups    = [],

  # Service
  Variant[Stdlib::Ensure::Service, Enum['absent']] $service_ensure  = 'running',
  Stdlib::Host                                     $listen_address  = '0.0.0.0',
  Stdlib::Port                                     $listen_port     = 9901,
  Stdlib::Absolutepath                             $serial_device   = '/dev/serial0',
  Integer                                          $baud_rate       = 1200,
) {
  case $facts['architecture'] {
    'x86_64', 'amd64': { $real_arch = 'amd64' }
    'aarch64':         { $real_arch = 'arm64' }
    'armv6l':          { $real_arch = 'armv6' }
    default:           {
      fail("Unsupported kernel architecture: ${facts['architecture']}")
    }
  }

  if $download_url {
    $real_download_url = $download_url
  } else {
    $real_download_url = "${base_url}/v${version}/linky-exporter-${version}-${os}-${real_arch}"
  }

  include linky_exporter::install
  include linky_exporter::service

  Class['linky_exporter::install'] -> Class['linky_exporter::service']
}
