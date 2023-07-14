require 'beaker-hostgenerator/data'
require 'beaker-hostgenerator/hypervisor'
require 'deep_merge/rails_compat'

module BeakerHostGenerator
  module Hypervisor
    class Docker < BeakerHostGenerator::Hypervisor::Interface
      include BeakerHostGenerator::Data

      def generate_node(node_info, base_config, bhg_version)
        base_config['docker_cmd'] = ['/sbin/init']

        ostype = node_info['ostype']

        if (commands = image_commands(ostype))
          base_config['docker_image_commands'] = commands
        end

        base_config['image'] = image(ostype)
        base_config['image'].prepend('amd64/') if node_info['bits'] == '64'

        base_generate_node(node_info, base_config, bhg_version, :docker)
      end

      private

      def image(ostype)
        image = ostype.sub(/(\d)/, ':\1')

        case ostype
        when /^oracle/
          image.sub!(/\w+/, 'oraclelinux')
        when /^opensuse/
          image.sub!(/(\w+)/, '\1/leap')
        when /^ubuntu/
          image.sub!(/(\d{2})/, '\1.')
        when /^rocky/
          image.sub!(/(\w+)/, 'rockylinux')
        when /^alma/
          image.sub!(/(\w+)/, 'almalinux')
        end

        image
      end

      def image_commands(ostype)
        case ostype
        when /^ubuntu/
          [
            'cp /bin/true /sbin/agetty',
            'apt-get install -y net-tools wget locales iproute2 gnupg',
            'locale-gen en_US.UTF-8',
            'echo LANG=en_US.UTF-8 > /etc/default/locale',
          ]
        end
      end
    end
  end
end
