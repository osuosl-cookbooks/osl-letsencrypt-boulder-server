require_relative '../../spec_helper'

describe 'osl-letsencrypt-boulder-server::default' do
  ALL_PLATFORMS.each do |p|
    context "#{p[:platform]} #{p[:version]}" do
      cached(:chef_run) do
        ChefSpec::SoloRunner.new(p).converge(described_recipe)
      end
      before do
        stub_command('/usr/local/go/bin/go version | grep "go1.7 "')
        stub_command('screen -list boulder | /bin/grep 1\ Socket\ in')
      end
      it 'converges successfully' do
        expect { chef_run }.to_not raise_error
      end
      %w(
        git
        screen
        initscripts
        logrotate
        tar
        wget
        libtool-ltdl-devel
      ).each do |pkg|
        it do
          expect(chef_run).to install_package(pkg)
        end
      end
      it do
        expect(chef_run).to install_chef_gem('rest-client').with(compile_time: false)
      end
      it do
        expect(chef_run).to create_hostsfile_entry('127.0.0.1')
          .with(
            hostname: 'localhost',
            aliases: %w(boulder boulder-rabbitmq boulder-mysql)
          )
      end
      context 'Set host_aliases' do
        cached(:chef_run) do
          ChefSpec::SoloRunner.new(p) do |node|
            node.set['boulder']['host_aliases'] = %w(foo.example.org bar.example.org)
          end.converge(described_recipe)
        end
        it do
          expect(chef_run).to create_hostsfile_entry('127.0.0.1')
            .with(
              hostname: 'localhost',
              aliases: %w(boulder boulder-rabbitmq boulder-mysql foo.example.org bar.example.org)
            )
        end
      end
      it do
        expect(chef_run).to create_directory('/opt/go/src/github.com/letsencrypt')
          .with(recursive: true)
      end
      it do
        expect(chef_run).to checkout_git('/opt/go/src/github.com/letsencrypt/boulder')
          .with(
            repository: 'https://github.com/letsencrypt/boulder',
            revision: '2d33a9900cafe82993744fe73bd341fe47df2171'
          )
      end
      it do
        expect(chef_run).to create_cookbook_file('/opt/go/src/github.com/letsencrypt/boulder/test/setup.sh')
          .with(mode: 0755)
      end
      %w(boulder_config boulder_limit wait_for_bootstrap).each do |rb|
        it do
          expect(chef_run).to run_ruby_block(rb)
        end
      end
      it do
        expect(chef_run).to run_bash('boulder_setup')
          .with(
            live_stream: true,
            cwd: '/opt/go/src/github.com/letsencrypt/boulder',
            code: 'source /etc/profile.d/golang.sh && GO15VENDOREXPERIMENT=1 ./test/setup.sh 2>&1 && touch setup.done',
            creates: '/opt/go/src/github.com/letsencrypt/boulder/setup.done'
          )
      end
      case p
      when CENTOS_6
        it do
          expect(chef_run).to install_python_runtime('2.7')
        end
        it do
          expect(chef_run).to run_bash('run_boulder')
            .with(
              live_stream: true,
              cwd: '/opt/go/src/github.com/letsencrypt/boulder',
              code: 'source /etc/profile.d/golang.sh && GO15VENDOREXPERIMENT=1 screen -LdmS boulder ' \
                    'scl enable python27 ./start.py'
            )
        end
      when CENTOS_7
        it do
          expect(chef_run).to_not install_python_runtime('2.7')
        end
        it do
          expect(chef_run).to run_bash('run_boulder')
            .with(
              live_stream: true,
              cwd: '/opt/go/src/github.com/letsencrypt/boulder',
              code: 'source /etc/profile.d/golang.sh && GO15VENDOREXPERIMENT=1 screen -LdmS boulder  ./start.py'
            )
        end
      end
    end
  end
end
