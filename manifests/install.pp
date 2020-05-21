# @summary This class install linky exporter requirements and binaries.
#
# @param version
#  linky exporter release. See https://github.com/anclrii/linky-Exporter/releases
# @param os
#  Operating system.
# @param arch
#  Architecture.
# @param base_dir
#  Base directory where linky is extracted.
# @param bin_dir
#  Directory where binaries are located.
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
# @example
#   include linky_exporter::install
class linky_exporter::install (
  String               $version            = $linky_exporter::version,
  String               $os                 = $linky_exporter::os,
  String               $arch               = $linky_exporter::real_arch,
  Stdlib::Absolutepath $base_dir           = $linky_exporter::base_dir,
  Stdlib::Absolutepath $bin_dir            = $linky_exporter::bin_dir,
  Stdlib::HTTPUrl      $download_url       = $linky_exporter::real_download_url,
  Optional[String]     $extract_command    = $linky_exporter::extract_command,

  # User Management
  Boolean              $manage_user        = $linky_exporter::manage_user,
  Boolean              $manage_group       = $linky_exporter::manage_group,
  String               $user               = $linky_exporter::user,
  String               $group              = $linky_exporter::group,
  Stdlib::Absolutepath $user_shell         = $linky_exporter::user_shell,
  Array[String]        $extra_groups       = $linky_exporter::extra_groups,
) {
  archive { "/tmp/linky-exporter-${version}-${os}-${arch}":
    ensure          => 'present',
    extract         => true,
    extract_path    => $base_dir,
    source          => $download_url,
    checksum_verify => false,
    creates         => "${base_dir}/linky-exporter-${version}/linky-exporter-${version}-${os}-${arch}",
    cleanup         => true,
    extract_command => $extract_command,
  }
  file {
    "${base_dir}/linky-exporter-${version}":
      ensure => directory;
    "${base_dir}/linky-exporter-${version}/linky-exporter-${version}-${os}-${arch}":
      owner => 'root',
      group => 0, # 0 instead of root because OS X uses "wheel".
      mode  => '0555';
    "${bin_dir}/linky-exporter":
      ensure => link,
      target => "${base_dir}/linky-exporter-${version}/linky-exporter-${version}-${os}-${arch}";
  }

  File["${base_dir}/linky-exporter-${version}"]
  -> Archive["/tmp/linky-exporter-${version}-${os}-${arch}"]
  -> File["${base_dir}/linky-exporter-${version}/linky-exporter-${version}-${os}-${arch}"]
  -> File["${bin_dir}/linky-exporter"]

  if $manage_user {
    ensure_resource('user', [ $user ], {
      ensure => 'present',
      system => true,
      groups => concat([$group], $extra_groups),
      shell  => $user_shell,
    })

    if $manage_group {
      Group[$group] -> User[$user]
    }
  }
  if $manage_group {
    ensure_resource('group', [ $group ], {
      ensure => 'present',
      system => true,
    })
  }
}
