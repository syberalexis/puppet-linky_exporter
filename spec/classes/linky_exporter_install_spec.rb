require 'spec_helper'

describe 'linky_exporter::install' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      arch = os.split('-').last
      let(:facts) do
        os_facts.merge('os' => { 'architecture' => arch })
      end

      case arch
      when 'aarch64'
        real_arch = 'arm64'
      when 'armv6l'
        real_arch = 'armv6'
      else
        real_arch = 'amd64'
      end

      [
        {
          version: '1.0.0',
          os: 'linux',
          arch: real_arch,
          base_dir: '/opt',
          bin_dir: '/usr/local/bin',
          download_url: 'https://github.com/Kylapaallikko/linky_exporter/archive/master.tar.gz',
          extract_command: 'ls',
          manage_user: true,
          manage_group: true,
          user: 'root',
          group: 'root',
          user_shell: '/bin/false',
          extra_groups: [],
        },
      ].each do |parameters|
        context "with parameters #{parameters}" do
          let(:params) do
            parameters
          end

          s_version = parameters[:version]
          s_os = parameters[:os]
          s_arch = parameters[:arch]
          s_base_dir = parameters[:base_dir]
          s_bin_dir = parameters[:bin_dir]
          s_download_url = parameters[:download_url]
          s_extract_command = parameters[:extract_command]
          s_manage_user = parameters[:manage_user]
          s_manage_group = parameters[:manage_group]
          s_user = parameters[:user]
          s_group = parameters[:group]
          s_user_shell = parameters[:user_shell]
          s_extra_groups = parameters[:extra_groups]

          # Compilation
          it {
            is_expected.to compile
          }

          # Install
          it {
            is_expected.to contain_archive("/tmp/linky-exporter-#{s_version}-#{s_os}-#{s_arch}").with(
              'ensure'          => 'present',
              'extract'         => true,
              'extract_path'    => s_base_dir,
              'source'          => s_download_url,
              'checksum_verify' => false,
              'creates'         => "/opt/linky-exporter-#{s_version}/linky-exporter-#{s_version}-#{s_os}-#{s_arch}",
              'cleanup'         => true,
              'extract_command' => s_extract_command,
            )
            is_expected.to contain_file("#{s_base_dir}/linky-exporter-#{s_version}").with(
              'ensure' => 'directory'
            )
            is_expected.to contain_file("#{s_base_dir}/linky-exporter-#{s_version}/linky-exporter-#{s_version}-#{s_os}-#{s_arch}").with(
              'owner'  => 'root',
              'group'  => '0',
              'mode'   => '0555',
            )
            is_expected.to contain_file("#{s_bin_dir}/linky-exporter").with(
              'ensure' => 'link',
              'target' => "#{s_base_dir}/linky-exporter-#{s_version}/linky-exporter-#{s_version}-#{s_os}-#{s_arch}",
            )

            # User
            if s_manage_user
              is_expected.to contain_user(s_user).with(
                'ensure' => 'present',
                'system' => true,
                'groups' => [s_group] + s_extra_groups,
                'shell'  => s_user_shell,
              )
            else
              is_expected.not_to contain_user(s_user)
            end
            # Group
            if s_manage_group
              is_expected.to contain_group(s_group).with(
                'ensure' => 'present',
                'system' => true,
              )
            else
              is_expected.not_to contain_group(s_group)
            end
          }
        end
      end
    end
  end
end
