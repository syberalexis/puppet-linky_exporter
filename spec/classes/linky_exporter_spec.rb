require 'spec_helper'

describe 'linky_exporter' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      arch = os.split('-').last
      let(:facts) do
        os_facts.merge('os' => { 'architecture' => arch })
      end

      [
        {
          version: '1.0.0',
        },
      ].each do |parameters|
        context "with parameters #{parameters}" do
          let(:params) do
            parameters
          end

          # Compilation
          it {
            is_expected.to compile
          }

          # Implementation
          it {
            is_expected.to contain_class('linky_exporter::install')
            is_expected.to contain_class('linky_exporter::service')
          }
        end
      end
    end
  end
end
