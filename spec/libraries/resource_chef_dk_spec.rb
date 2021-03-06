# Encoding: UTF-8
#
# Cookbook Name:: chef-dk
# Spec:: resource_chef_dk
#
# Copyright (C) 2014, Jonathan Hartman
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require_relative '../spec_helper'
require_relative '../../libraries/resource_chef_dk'

describe Chef::Resource::ChefDk do
  let(:platform) { { platform: 'ubuntu', version: '14.04' } }
  [
    :version, :prerelease, :nightlies, :package_url, :global_shell_init
  ].each do |i|
    let(i) { nil }
  end
  let(:resource) do
    r = described_class.new('my_chef_dk', nil)
    [
      :version, :prerelease, :nightlies, :package_url, :global_shell_init
    ].each do |i|
      r.send(i, send(i))
    end
    r
  end

  before(:each) do
    allow_any_instance_of(described_class).to receive(:node).and_return(
      Fauxhai.mock(platform).data
    )
  end

  shared_examples_for 'an invalid configuration' do
    it 'raises an exception' do
      expect { resource }.to raise_error(Chef::Exceptions::ValidationFailed)
    end
  end

  describe '#initialize' do
    before(:each) do
      allow_any_instance_of(described_class).to receive(:determine_provider)
        .and_return(Chef::Provider)
    end

    it 'defaults the state to uninstalled' do
      expect(resource.installed?).to eq(false)
    end

    it 'sets the provider correctly' do
      expected = Chef::Provider
      expect(resource.instance_variable_get(:@provider)).to eq(expected)
    end
  end

  describe '#version' do
    context 'no override provided' do
      it 'defaults to the latest version' do
        expect(resource.version).to eq('latest')
      end
    end

    context 'a valid override provided' do
      let(:version) { '1.2.3-4' }

      it 'returns the override' do
        expect(resource.version).to eq(version)
      end
    end

    context 'an invalid override provided' do
      let(:version) { 'x.y.z' }

      it_behaves_like 'an invalid configuration'
    end

    context 'a version AND package_url provided' do
      let(:version) { '1.2.3-4' }
      let(:package_url) { 'http://example.com/pkg.pkg' }

      it_behaves_like 'an invalid configuration'
    end
  end

  describe '#prerelease' do
    context 'no override provided' do
      it 'defaults to false' do
        expect(resource.prerelease).to eq(false)
      end
    end

    context 'a valid override provided' do
      let(:prerelease) { true }

      it 'returns the override' do
        expect(resource.prerelease).to eq(true)
      end
    end

    context 'an invalid override provided' do
      let(:prerelease) { 'monkeys' }

      it_behaves_like 'an invalid configuration'
    end
  end

  describe '#nightlies' do
    context 'no override provided' do
      it 'defaults to false' do
        expect(resource.nightlies).to eq(false)
      end
    end

    context 'a valid override provided' do
      let(:nightlies) { true }

      it 'returns the override' do
        expect(resource.nightlies).to eq(true)
      end
    end

    context 'an invalid override provided' do
      let(:nightlies) { 'monkeys' }

      it_behaves_like 'an invalid configuration'
    end
  end

  describe '#package_url' do
    context 'no override provided' do
      it 'defaults to nil to let the provider calculate a URL' do
        expect(resource.package_url).to eq(nil)
      end
    end

    context 'a valid override provided' do
      let(:package_url) { 'http://example.com/pkg.pkg' }

      it 'returns the override' do
        expect(resource.package_url).to eq(package_url)
      end
    end

    context 'an invalid override provided' do
      let(:package_url) { :thing }

      it_behaves_like 'an invalid configuration'
    end

    context 'a package_url AND version override provided' do
      let(:package_url) { 'http://example.com/pkg.pkg' }
      let(:version) { '1.2.3-4' }

      it_behaves_like 'an invalid configuration'
    end
  end

  describe '#global_shell_init' do
    context 'no override provided' do
      it 'defaults to false' do
        expect(resource.global_shell_init).to eq(false)
      end
    end

    context 'a valid override provided' do
      let(:global_shell_init) { true }

      it 'returns the override' do
        expect(resource.global_shell_init).to eq(true)
      end
    end

    context 'an invalid override provided' do
      let(:global_shell_init) { 'wiggles' }

      it_behaves_like 'an invalid configuration'
    end
  end

  describe '#determine_provider' do
    [
      {
        platform: 'ubuntu',
        version: '12.04',
        expected: Chef::Provider::ChefDk::Debian
      },
      {
        platform: 'centos',
        version: '6.5',
        expected: Chef::Provider::ChefDk::Rhel
      },
      {
        platform: 'mac_os_x',
        version: '10.9.2',
        expected: Chef::Provider::ChefDk::MacOsX
      },
      {
        platform: 'windows',
        version: '2012',
        expected: Chef::Provider::ChefDk::Windows
      }
    ].each do |p|
      context "a #{p[:platform]}-#{p[:version]} node" do
        let(:platform) { { platform: p[:platform], version: p[:version] } }

        it "uses #{p[:expected]} as the provider" do
          expect(resource.send(:determine_provider)).to eq(p[:expected])
        end
      end
    end
  end

  describe '#valid_version?' do
    context 'a "latest" version' do
      let(:res) { resource.send(:valid_version?, 'latest') }

      it 'returns true' do
        expect(res).to eq(true)
      end
    end

    context 'a valid version' do
      let(:res) { resource.send(:valid_version?, '1.2.3') }

      it 'returns true' do
        expect(res).to eq(true)
      end
    end

    context 'a valid version + build' do
      let(:res) { resource.send(:valid_version?, '1.2.3-12') }

      it 'returns true' do
        expect(res).to eq(true)
      end
    end

    context 'an invalid version' do
      let(:res) { resource.send(:valid_version?, 'x.y.z') }

      it 'returns false' do
        expect(res).to eq(false)
      end
    end
  end
end
