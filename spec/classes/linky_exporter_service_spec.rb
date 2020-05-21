require 'spec_helper'

describe 'linky_exporter::service' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      arch = os.split('-').last
      let(:facts) do
        os_facts.merge('os' => { 'architecture' => arch })
      end

      [
        {
          bin_dir: '/usr/local/bin',
          user: 'root',
          group: 'root',
          ensure: 'running',
          listen_address: '0.0.0.0',
          listen_port: 9_180,
          serial_device: '/dev/serial0',
          baud_rate: 1200,
        },
      ].each do |parameters|
        context "with parameters #{parameters}" do
          let(:params) do
            parameters
          end

          s_bin_dir = parameters[:bin_dir]
          s_user = parameters[:user]
          s_group = parameters[:group]
          s_ensure = parameters[:ensure]
          s_listen_address = parameters[:listen_address]
          s_listen_port = parameters[:listen_port]
          s_serial_device = parameters[:serial_device]
          s_baud_rate = parameters[:baud_rate]

          case s_ensure
          when 'running'
            s_file_ensure = 'file'
            s_service_ensure = 'running'
          when 'stopped'
            s_file_ensure = 'file'
            s_service_ensure = 'stopped'
          else
            s_file_ensure = 'absent'
            s_service_ensure = 'stopped'
          end

          # Compilation
          it {
            is_expected.to compile
          }

          # Service
          it {
            is_expected.to contain_file('/lib/systemd/system/linky-exporter.service').with(
              'ensure' => s_file_ensure,
            ).with_content(
              "# THIS FILE IS MANAGED BY PUPPET
[Unit]
Description=Linky Exporter service
Wants=network-online.target
After=network-online.target

[Service]
User=#{s_user}
Group=#{s_group}
Type=simple
ExecStart=#{s_bin_dir}/linky-exporter --address #{s_listen_address} --port #{s_listen_port} --device #{s_serial_device} --baud #{s_baud_rate}
Restart=on-failure
RestartSec=5s

[Install]
WantedBy=multi-user.target
",
            ).that_notifies('Service[linky-exporter]')

            is_expected.to contain_service('linky-exporter').with(
              'ensure' => s_service_ensure,
              'enable' => true,
            )
          }
        end
      end
    end
  end
end
