# Encoding: UTF-8
#
# Cookbook Name:: chef-dk
# Spec:: resource/chef_dk
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
require_relative '../../libraries/resource/chef_dk'

describe Chef::Resource::ChefDk do
  let(:version) { nil }
  let(:resource) do
    Chef::Resource::ChefDk.new('my_chef_dk', nil) do
      version(version)
    end
  end

  describe '#initialize' do
    it 'defaults to the latest version' do
      expect(resource.instance_variable_get(:@version)).to eq('latest')
    end

    it 'defaults the state to uninstalled' do
      expect(resource.installed?).to eq(false)
    end
  end

  describe '#version' do
    it 'defaults to the latest version' do
      expect(resource.version).to eq('latest')
    end
  end
end
