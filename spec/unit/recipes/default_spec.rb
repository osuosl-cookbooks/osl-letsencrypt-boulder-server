require_relative '../../spec_helper'

describe 'osl-letsencrypt-boulder-server::default' do
  ALL_PLATFORMS.each do |p|
    context "#{p[:platform]} #{p[:version]}" do
      cached(:chef_run) do
        ChefSpec::SoloRunner.new(p) do |node|
          node.set['boulder']['host_aliases'] = %w(example.com foo.org)
        end.converge(described_recipe)
      end
      before do
        stub_command('/usr/local/bin/docker-compose ps -q | wc -l | grep 0').and_return(true)
        stub_command('/usr/local/go/bin/go version | grep "go1.8 "')
        stub_command('screen -list boulder | /bin/grep 1\ Socket\ in')
      end
      it 'converges successfully' do
        expect { chef_run }.to_not raise_error
      end
      it do
        expect(chef_run).to install_package('dnsmasq')
      end
      it do
        expect(chef_run).to create_template('/etc/dnsmasq.conf').with(source: 'dnsmasq.erb')
      end
      %w(example.com foo.org).each do |host|
        it do
          expect(chef_run).to render_file('/etc/dnsmasq.conf').with_content(%r{^address=/#{host}/10.0.0.2$})
        end
      end
      it do
        expect(chef_run.template('/etc/dnsmasq.conf')).to notify('service[dnsmasq]').to(:restart).immediately
      end
      it do
        expect(chef_run).to start_service('dnsmasq')
      end
      it do
        expect(chef_run).to enable_service('dnsmasq')
      end
      it do
        expect(chef_run).to install_chef_gem('rest-client').with(compile_time: false)
      end
      [
        /^domain example.org$/,
        /^search example.org$/,
        /^nameserver 127.0.0.1$/,
      ].each do |line|
        it do
          expect(chef_run).to render_file('/etc/resolv.conf').with_content(line)
        end
      end
      case p
      when CENTOS_7
        %w(boulder boulder-rabbitmq boulder-mysql).each do |host|
          it do
            expect(chef_run).to_not render_file('/etc/dnsmasq.conf').with_content(%r{^address=/#{host}/127.0.0.1$})
          end
        end
        it do
          expect(chef_run).to create_directory('/opt/boulder')
        end
        it do
          expect(chef_run).to checkout_git('/opt/boulder')
            .with(
              repository: 'https://github.com/letsencrypt/boulder',
              revision: 'release-2018-02-13'
            )
        end
        it do
          expect(chef_run).to create_docker_service('default').with(misc_opts: '--live-restore')
        end
        %w(boulder_config boulder_limit boulder_dns wait_for_bootstrap).each do |rb|
          it do
            expect(chef_run).to run_ruby_block(rb)
          end
        end
        it do
          expect(chef_run).to run_execute('/usr/local/bin/docker-compose up -d')
            .with(
              live_stream: true,
              cwd: '/opt/boulder'
            )
        end
      when CENTOS_6
        %w(boulder boulder-rabbitmq boulder-mysql).each do |host|
          it do
            expect(chef_run).to render_file('/etc/dnsmasq.conf').with_content(%r{^address=/#{host}/127.0.0.1$})
          end
        end
        it do
          expect(chef_run).to create_directory('/opt/go/src/github.com/letsencrypt/boulder')
        end
        it do
          expect(chef_run).to checkout_git('/opt/go/src/github.com/letsencrypt/boulder')
            .with(
              repository: 'https://github.com/letsencrypt/boulder',
              revision: '2d33a9900cafe82993744fe73bd341fe47df2171'
            )
        end
        it do
          expect(chef_run).to install_package(%w(screen initscripts logrotate tar wget libtool-ltdl-devel))
        end
        it do
          expect(chef_run).to install_python_runtime('2.7')
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
              code: 'source /etc/profile.d/golang.sh && GO15VENDOREXPERIMENT=1 ' \
										'./test/setup.sh 2>&1 && touch setup.done',
              creates: '/opt/go/src/github.com/letsencrypt/boulder/setup.done'
            )
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
      end
    end
  end
end
