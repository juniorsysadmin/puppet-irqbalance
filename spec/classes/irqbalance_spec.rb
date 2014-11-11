require 'spec_helper'

describe 'irqbalance', :type => :class do

  context 'when on a multiprocessor system' do
    let(:default_facts) { { :processorcount => '2', } }

    [ 6.0, 7.0, 10.04, 12.04, 14.04, ].each do |operatingsystemrelease|
      context "running Debian/Ubuntu release #{operatingsystemrelease}" do

        if operatingsystemrelease < 10.04
          provider = 'debian'
        else
          provider = 'upstart'
        end

        let :facts do
          default_facts.merge!({
            :operatingsystemrelease => operatingsystemrelease,
            :osfamily               => 'Debian',
          })
        end

        # Classes it should contain
        it { should contain_class('irqbalance::install') }
        it { should contain_class('irqbalance::config') }
        it { should contain_class('irqbalance::service') }
        it { should contain_class('irqbalance::initscripts') }

        # Service resource tests
        context 'with the irqbalance service managed and oneshot set to no' do
          let (:default_params) {{
            :service_manage => true,
            :oneshot => 'no',
          }}

          context 'and service_ensure parameter set to running' do
            let :params do
              default_params.merge!({
                :service_ensure => 'running',
              })
            end

            it 'the irqbalance service should be running' do
              should contain_service('irqbalance').with({
                'ensure'   => 'running',
              })
            end
          end

          context 'and service_ensure parameter set to stopped' do
            let :params do
              default_params.merge!({
                :service_ensure => 'stopped',
              })
            end

            it 'the irqbalance service should be stopped' do
              should contain_service('irqbalance').with({
                'ensure'   => 'stopped',
              })
            end
          end

        end

        context 'with the irqbalance service managed and oneshot set to yes' do
          let (:params) {{
            :service_manage => true,
            :oneshot => 'yes',
          }}

          it 'the running state of the irqbalance service is not managed' do
            should_not contain_service('irqbalance').with({
              'ensure'   => 'running',
            })
            should_not contain_service('irqbalance').with({
              'ensure'   => 'stopped',
            })
          end

        end

        context 'with the irqbalance service managed' do
          let (:default_params) {{
            :service_manage => true,
          }}

          context 'and service_enable parameter set to true' do
            let :params do
              default_params.merge!({
                :service_enable => true,
            })
            end

            it 'the irqbalance service should be started on startup' do
              should contain_service('irqbalance').with({
                'enable'   => true,
              })
            end
          end

          context 'and service_enable parameter set to false' do
            let :params do
              default_params.merge!({
                :service_enable => false,
              })
            end

            it 'the irqbalance service should not be started on startup' do
              should contain_service('irqbalance').with({
                'enable'   => false,
            })
            end
          end

          it 'the irqbalance service should be named irqbalance' do
            should contain_service('irqbalance').with({
              'name'   => 'irqbalance',
            })
          end

          it "the service provider should be #{provider}" do
            should contain_service('irqbalance').with({
              'provider' => provider,
            })
          end

        end

        context 'with the irqbalance service not managed' do
          let (:params) { { :service_manage => false,} }

          it 'the service resource irqbalance should not be in the catalog' do
            should_not contain_service('irqbalance')
          end

        end

        # Config file  tests
        context 'with service_enable parameter set to true' do
          let (:params) { { :service_enable => true,} }

          it 'the irqbalance config file should contain ENABLED=1' do
            should contain_file('/etc/default/irqbalance').with({
              'content' => /^ENABLED=1$/,
            })
          end
        end

        context 'with service_enable parameter set to false' do
          let (:params) { { :service_enable => false,} }

          it 'the irqbalance config file should contain ENABLED=0' do
            should contain_file('/etc/default/irqbalance').with({
              'content' => /^ENABLED=0$/,
            })
          end
        end

        context 'with oneshot parameter set to yes' do
          let (:params) { { :oneshot => 'yes', } }

          it 'the irqbalance config file should contain ONESHOT=1' do
            should contain_file('/etc/default/irqbalance').with({
              'content' => /^ONESHOT="1"$/,
            })
          end
        end

        context 'with oneshot parameter set to no' do
          let (:params) { { :oneshot => 'no', } }

          it 'the irqbalance config file should contain ONESHOT=0' do
            should contain_file('/etc/default/irqbalance').with({
              'content' => /^ONESHOT="0"$/,
            })
          end
        end

        context "with banned_interrupts parameter set to ['33', '03']" do
          let (:params) { { :banned_interrupts => ['33', '03'], } }

          if operatingsystemrelease < 14.04
            it 'the irqbalance config file should contain IRQBALANCE_BANNED_INTERRUPTS="33 03"' do
              should contain_file('/etc/default/irqbalance').with({
                'content' => /^IRQBALANCE_BANNED_INTERRUPTS="33 03"$/,
              })
            end
          else
            it 'the irqbalance config file should not contain IRQBALANCE_BANNED_INTERRUPTS' do
              should_not contain_file('/etc/default/irqbalance').with({
                'content' => /IRQBALANCE_BANNED_INTERRUPTS/,
              })
            end
          end
        end

        context 'with no banned_interrupts parameter provided' do
          # The default for this parameter is undef

          it 'the irqbalance config file should not contain IRQBALANCE_BANNED_INTERRUPTS' do
            should_not contain_file('/etc/default/irqbalance').with({
              'content' => /IRQBALANCE_BANNED_INTERRUPTS/,
            })
          end
        end

        context "with banned_cpus parameter set to ['fc3', '0000000']" do
          let (:params) { { :banned_cpus => ['fc3', '0000000'], } }

          it 'the irqbalance config file should contain IRQBALANCE_BANNED_CPUS="fc3,0000000"' do
            should contain_file('/etc/default/irqbalance').with({
              'content' => /^IRQBALANCE_BANNED_CPUS="fc3,0000000"$/,
            })
          end
        end

        context 'with no banned_cpus parameter provided' do
          # The default for this parameter is undef
 
          it 'the irqbalance config file should not contain IRQBALANCE_BANNED_CPUS' do
            should_not contain_file('/etc/default/irqbalance').with({
              'content' => /IRQBALANCE_BANNED_CPUS/,
          })
          end
        end

        context 'with args parameter set to "--args1 --args2"' do
          let (:params) { { :args => '--args1 --args2', } }

          it 'the irqbalance config file should contain OPTIONS="--args1 --args2"' do
            should contain_file('/etc/default/irqbalance').with({
              'content' => /^OPTIONS="--args1 --args2"$/,
            })
          end
        end

        context 'with no module parameters' do
          it 'the irqbalance config file should not contain OPTIONS' do
            should_not contain_file('/etc/default/irqbalance').with({
              'content' => /OPTIONS/,
            })
          end
        end

        context "with banirq parameter set to ['01', '03', '04']" do
          let (:params) { { :banirq => ['01', '03', '04'], } }

          if operatingsystemrelease < 14.04
            it 'the irqbalance config file should not contain --banirq' do
              should_not contain_file('/etc/default/irqbalance').with({
                'content' => /--banirq/,
              })
            end
          else
            it 'the irqbalance config file should contain --banirq=01 --banirq=03 --banirq=04"' do
              should contain_file('/etc/default/irqbalance').with({
                'content' => /--banirq=01 --banirq=03 --banirq=04/,
              })
            end
          end
        end

        context 'with no banirq parameter provided' do
          # The default for this parameter is undef
  
          it 'the irqbalance config file should not contain --banirq' do
            should_not contain_file('/etc/default/irqbalance').with({
              'content' => /--banirq/,
            })
          end
        end

        context 'with banscript parameter set to /path/to/banscript.sh' do
          let (:params) { { :banscript => '/path/to/banscript.sh', } }

          it 'the irqbalance config file should not contain --banscript' do
            should_not contain_file('/etc/default/irqbalance').with({
              'content' => /--banscript/,
            })
          end
        end

        context 'with no banscript parameter provided' do
          # The default for this parameter is undef

          it 'the irqbalance config file should not contain --banscript' do
            should_not contain_file('/etc/default/irqbalance').with({
              'content' => /--banscript/,
            })
          end
        end

        context 'with debug parameter set to true' do
          let (:params) { { :debug => true, } }

          if operatingsystemrelease < 14.04
            it 'the irqbalance config file should not contain --debug' do
              should_not contain_file('/etc/default/irqbalance').with({
                'content' => /--debug/,
              })
            end
          else
            it 'the irqbalance config file should contain --debug"' do
              should contain_file('/etc/default/irqbalance').with({
                'content' => /--debug/,
              })
            end
          end
        end

        context 'with debug parameter set to false' do
          let (:params) { { :debug => false, } }

          it 'the irqbalance config file should not contain --debug' do
            should_not contain_file('/etc/default/irqbalance').with({
              'content' => /--debug/,
            })
          end
        end

        context 'with deepestcache parameter set to 2' do
          let (:params) { { :deepestcache => '2', } }

          it 'the irqbalance config file should not contain --deepestcache' do
            should_not contain_file('/etc/default/irqbalance').with({
              'content' => /--deepestcache/,
            })
          end
        end

        context 'with no deepestcache parameter provided' do
          # The default for this parameter is undef

          it 'the irqbalance config file should not contain --deepestcache' do
            should_not contain_file('/etc/default/irqbalance').with({
              'content' => /--deepestcache/,
            })
          end
        end

        context 'with hintpolicy parameter set to exact' do
          let (:params) { { :hintpolicy => 'exact', } }

          if operatingsystemrelease < 14.04 and operatingsystemrelease != 7.0
            it 'the irqbalance config file should not contain --hintpolicy' do
              should_not contain_file('/etc/default/irqbalance').with({
                'content' => /--hintpolicy/,
              })
            end
          else
            it 'the irqbalance config file should contain --hintpolicy=exact' do
              should contain_file('/etc/default/irqbalance').with({
                'content' => /--hintpolicy=exact/,
              })
            end
          end
        end

        context 'with hintpolicy parameter set to subset' do
          let (:params) { { :hintpolicy => 'subset', } }

          if operatingsystemrelease < 14.04 and operatingsystemrelease != 7.0
            it 'the irqbalance config file should not contain --hintpolicy' do
              should_not contain_file('/etc/default/irqbalance').with({
                'content' => /--hintpolicy/,
              })
            end
          else
            it 'the irqbalance config file should contain --hintpolicy=subset' do
              should contain_file('/etc/default/irqbalance').with({
                'content' => /--hintpolicy=subset/,
              })
            end
          end
        end

        context 'with hintpolicy parameter set to ignore' do
          let (:params) { { :hintpolicy => 'ignore', } }

          if operatingsystemrelease < 14.04 and operatingsystemrelease !=7.0
            it 'the irqbalance config file should not contain --hintpolicy' do
              should_not contain_file('/etc/default/irqbalance').with({
                'content' => /--hintpolicy/,
              })
            end
          else
            it 'the irqbalance config file should contain --hintpolicy=ignore' do
              should contain_file('/etc/default/irqbalance').with({
                'content' => /--hintpolicy=ignore/,
              })
            end
          end
        end

        context 'with no hintpolicy parameter provided' do
          # The default for this parameter is undef

          it 'the irqbalance config file should not contain --hintpolicy' do
            should_not contain_file('/etc/default/irqbalance').with({
              'content' => /--hintpolicy/,
            })
          end
        end

        context 'with pid parameter set to /path/to/irqbalance.pid' do
          let (:params) { { :pid => '/path/to/irqbalance.pid', } }

          if operatingsystemrelease < 14.04
            it 'the irqbalance config file should not contain --pid' do
              should_not contain_file('/etc/default/irqbalance').with({
                'content' => /--pid/,
              })
            end
          else
            it 'the irqbalance config file should contain --pid=/path/to/irqbalance.pid' do
              should contain_file('/etc/default/irqbalance').with({
                'content' => /--pid=\/path\/to\/irqbalance\.pid/,
              })
            end
          end
        end

        context 'with no pid parameter provided' do
          # The default for this parameter is undef

          it 'the irqbalance config file should not contain --pid' do
            should_not contain_file('/etc/default/irqbalance').with({
              'content' => /--pid/,
            })
          end
        end

        context 'with policyscript parameter set to /path/to/policyscript' do
          let (:params) { { :policyscript => '/path/to/policyscript', } }

          if operatingsystemrelease < 14.04
            it 'the irqbalance config file should not contain --policyscript' do
              should_not contain_file('/etc/default/irqbalance').with({
                'content' => /--policyscript/,
              })
            end
          else
            it 'the irqbalance config file should contain --policyscript=/path/to/policyscript' do
              should contain_file('/etc/default/irqbalance').with({
                'content' => /--policyscript=\/path\/to\/policyscript/,
              })
            end
          end
        end

        context 'with no policyscript parameter provided' do
          # The default for this parameter is undef

          it 'the irqbalance config file should not contain --policyscript' do
            should_not contain_file('/etc/default/irqbalance').with({
              'content' => /--policyscript/,
            })
          end
        end

        context 'with powerthresh parameter set to 2' do
          let (:params) { { :powerthresh => '2', } }

          if operatingsystemrelease < 14.04 and operatingsystemrelease != 7.0
            it 'the irqbalance config file should not contain --powerthresh' do
              should_not contain_file('/etc/default/irqbalance').with({
                'content' => /--powerthresh/,
              })
            end
          else
            it 'the irqbalance config file should contain --powerthresh=2' do
              should contain_file('/etc/default/irqbalance').with({
                'content' => /--powerthresh=2/,
              })
            end
          end
        end

        context 'with no powerthresh parameter provided' do
          # The default for this parameter is undef

          it 'the irqbalance config file should not contain --powerthresh' do
            should_not contain_file('/etc/default/irqbalance').with({
              'content' => /--powerthresh/,
            })
          end
        end

        # Config file permissions
        context 'with default config file permissions and config_file_source parameter not set' do
          # The default for the config_file_source parameter is undef

          it 'the irqbalance config file should be owned by root' do
            should contain_file('/etc/default/irqbalance').with({
              'owner' => '0',
            })
          end

          it 'the irqbalance config file should be group root' do
            should contain_file('/etc/default/irqbalance').with({
              'group' => '0',
            })
          end

          it 'the irqbalance config file should be mode 0644' do
            should contain_file('/etc/default/irqbalance').with({
              'mode' => '0644',
            })
          end

        end

        context 'with config_file_owner parameter set to irqbalance' do
          let (:params) { { :config_file_owner => 'irqbalance', } }
          it { should contain_file('/etc/default/irqbalance').with_owner('irqbalance') }
        end

        context 'with config_file_group parameter set to irqbalancegroup' do
          let (:params) { { :config_file_group => 'irqbalancegroup', } }
          it { should contain_file('/etc/default/irqbalance').with_group('irqbalancegroup') }
        end

        context 'with config_file_mode parameter set to 0444' do
          let (:params) { { :config_file_mode => '0444', } }
          it { should contain_file('/etc/default/irqbalance').with_mode('0444') }
        end

        context 'with default config file permissions and config_file_source set to puppet:///modules/irqbalance/config/irq.conf' do
          let (:params) { { :config_file_source => 'puppet:///modules/irqbalance/config/irq.conf', } }

          it 'the irqbalance config file should be owned by root' do
            should contain_file('/etc/default/irqbalance').with({
              'owner' => '0',
            })
          end

          it 'the irqbalance config file should be group root' do
            should contain_file('/etc/default/irqbalance').with({
              'group' => '0',
            })
          end

          it 'the irqbalance config file should be mode 0644' do
            should contain_file('/etc/default/irqbalance').with({
              'mode' => '0644',
            })
          end

        end

        # Package resource tests
        context 'with the package_manage parameter set to true' do
          let (:default_params) { { :package_manage => true, } }

          context "and the package_ensure parameter set to 'installed'" do
            let :params do
              default_params.merge!({
                :package_ensure => 'installed',
              })
            end

            it 'the irqbalance package should be installed' do
              should contain_package('irqbalance').with({
                'ensure' => 'installed',
              })
            end
          end

          context "and the package_ensure parameter set to 'absent'" do
            let :params do
              default_params.merge!({
                :package_ensure => 'absent',
              })
            end

            it 'the irqbalance package should not be installed' do
              should contain_package('irqbalance').with({
                'ensure' => 'absent',
              })
            end
          end

          it 'the name of the package managed is irqbalance' do
            should contain_package('irqbalance').with({
              'name' => 'irqbalance',
            })
          end

        end

        context 'with the package_manage parameter set to false' do
          let (:params) { { :package_manage => false,} }

          it 'the package resource irqbalance should not be in the catalog' do
            should_not contain_package('irqbalance')
          end

        end

        # Init script resource tests

        context 'with the manage_init_script_file parameter set to true' do
          let (:default_params) { { :manage_init_script_file => true, } }

          context 'and sysv_init_script_file_source or upstart_init_script_file set' do
            let :params do
              default_params.merge!({
                :sysv_init_script_file_source => 'puppet://modules/irqbalance/sysv',
                :upstart_init_script_file_source => 'puppet://modules/irqbalance/upstart',
              })
            end

            it 'the init script group should be root' do
              if operatingsystemrelease < 10.04
                should contain_file('/etc/init.d/irqbalance').with({
                  'group' => '0',
                })
              else
                should contain_file('/etc/init/irqbalance.conf').with({
                  'group' => '0',
                })
              end
            end

            it 'the init script owner should be root' do
              if operatingsystemrelease < 10.04
                should contain_file('/etc/init.d/irqbalance').with({
                  'owner' => '0',
                })
              else
                should contain_file('/etc/init/irqbalance.conf').with({
                  'owner' => '0',
                })
              end
            end

            if operatingsystemrelease < 10.04
              it 'the init script file permissions should be 0755' do
                should contain_file('/etc/init.d/irqbalance').with({
                  'mode' => '0755',
                })
              end
            else
              it 'the init script file permissions should be 0644' do
                should contain_file('/etc/init/irqbalance.conf').with({
                  'mode' => '0644',
                })
              end
            end

          end

          context 'and *_init_script_file_source not set' do
            #The *_init_script_file_source parameters default to undef
            let (:params) { { :manage_init_script_file => true, } }
          
            it 'the init script group should be root' do
              if operatingsystemrelease < 10.04
                should contain_file('/etc/init.d/irqbalance').with({
                  'group' => '0',
                })
              else
                should contain_file('/etc/init/irqbalance.conf').with({
                  'group' => '0',
                })
              end
            end

            it 'the init script owner should be root' do
              if operatingsystemrelease < 10.04
                should contain_file('/etc/init.d/irqbalance').with({
                  'owner' => '0',
                })
              else
                should contain_file('/etc/init/irqbalance.conf').with({
                  'owner' => '0',
                })
              end
            end

            if operatingsystemrelease < 10.04
              it 'the init script file permissions should be 0755' do
                should contain_file('/etc/init.d/irqbalance').with({
                  'mode' => '0755',
                })
              end
            else
              it 'the init script file permissions should be 0644' do
                should contain_file('/etc/init/irqbalance.conf').with({
                  'mode' => '0644',
                })
              end
            end

            if operatingsystemrelease > 7.0 and operatingsystemrelease < 14.04
              it 'the init script file should contain expect fork' do
                should contain_file('/etc/init/irqbalance.conf').with({
                  'content' => /^expect fork$/,
                })
              end
            end

            if operatingsystemrelease > 12.04
              it 'the init script file should contain exec /sbin/irqbalance  $DOPTIONS $OPTIONS --foreground' do
                should contain_file('/etc/init/irqbalance.conf').with({
                  'content' => /^\texec \/usr\/sbin\/irqbalance  \$DOPTIONS \$OPTIONS --foreground$/
                })
              end
            end

          end

        end

        context 'with the manage_init_script file parameter set to false' do
          let (:params) { { :manage_init_script_file => false, } }

          it 'the init script file resource should not be in the catalog' do
            if operatingsystemrelease < 10.04
              should_not contain_file('/etc/init.d/irqbalance')
            else
              should_not contain_file('/etc/init/irqbalance.conf')
            end
          end
        end

      end
    end

    [ 5.9, 6.6, 7.0, 20.0].each do |operatingsystemrelease|
      context "running RHEL/Fedora release #{operatingsystemrelease}" do

        if operatingsystemrelease ==  20
          operatingsystem = 'Fedora'
        else
          operatingsystem = 'RedHat'
        end

        if operatingsystemrelease < 7.0
          provider = 'redhat'
        else
          provider = 'systemd'
        end

        let :facts do
          default_facts.merge!({
            :operatingsystem        => operatingsystem,
            :operatingsystemrelease => operatingsystemrelease,
            :osfamily               => 'RedHat',
          })
        end

        # Classes it should contain
        it { should contain_class('irqbalance::install') }
        it { should contain_class('irqbalance::config') }
        it { should contain_class('irqbalance::service') }
        it { should contain_class('irqbalance::initscripts') }

        # Service resource tests
        context 'with the irqbalance service managed and oneshot set to no' do
          let (:default_params) {{
            :service_manage => true,
            :oneshot => 'no',
          }}

          context 'and service_ensure parameter set to running' do
            let :params do
              default_params.merge!({
                :service_ensure => 'running',
              })
            end

            it 'the irqbalance service should be running' do
              should contain_service('irqbalance').with({
                'ensure'   => 'running',
              })
            end
          end

          context 'and service_ensure parameter set to stopped' do
            let :params do
              default_params.merge!({
                :service_ensure => 'stopped',
              })
            end

            it 'the irqbalance service should be stopped' do
              should contain_service('irqbalance').with({
                'ensure'   => 'stopped',
              })
            end
          end

        end

        context 'with the irqbalance service managed and oneshot set to yes' do
          let (:params) {{
            :service_manage => true,
            :oneshot => 'yes',
          }}

          it 'the running state of the irqbalance service is not managed' do
            should_not contain_service('irqbalance').with({
              'ensure'   => 'running',
            })
            should_not contain_service('irqbalance').with({
              'ensure'   => 'stopped',
            })
          end

        end

        context 'with the irqbalance service managed' do
          let (:default_params) {{
            :service_manage => true,
          }}

          context 'and service_enable parameter set to true' do
            let :params do
              default_params.merge!({
                :service_enable => true,
            })
            end

            it 'the irqbalance service should be started on startup' do
              should contain_service('irqbalance').with({
                'enable'   => true,
              })
            end
          end

          context 'and service_enable parameter set to false' do
            let :params do
              default_params.merge!({
                :service_enable => false,
              })
            end

            it 'the irqbalance service should not be started on startup' do
              should contain_service('irqbalance').with({
                'enable'   => false,
            })
            end
          end

          it 'the irqbalance service should be named irqbalance' do
            should contain_service('irqbalance').with({
              'name'   => 'irqbalance',
            })
          end

          it "the service provider should be #{provider}" do
            should contain_service('irqbalance').with({
              'provider' => provider,
            })
          end

        end

        context 'with the irqbalance service not managed' do
          let (:params) { { :service_manage => false,} }

          it 'the service resource irqbalance should not be in the catalog' do
            should_not contain_service('irqbalance')
          end

        end

        # Config file tests
        context 'with oneshot parameter set to yes' do
          let (:params) { { :oneshot => 'yes', } }

          if operatingsystemrelease == 5.9
            it 'the irqbalance config file should contain ONESHOT=yes' do
              should contain_file('/etc/sysconfig/irqbalance').with({
                'content' => /^ONESHOT=yes$/,
              })
            end
          else
            it 'the irqbalance config file should contain IRQBALANCE_ONESHOT=yes' do
              should contain_file('/etc/sysconfig/irqbalance').with({
                'content' => /^IRQBALANCE_ONESHOT=yes$/,
              })
            end
          end

        end

        context 'with oneshot parameter set to no' do
          let (:params) { { :oneshot => 'no', } }

          if operatingsystemrelease == 5.9
            it 'the irqbalance config file should contain #ONESHOT=' do
              should contain_file('/etc/sysconfig/irqbalance').with({
                'content' => /^#ONESHOT=$/,
              })
            end
          else
            it 'the irqbalance config file should contain #IRQBALANCE_ONESHOT' do
              should contain_file('/etc/sysconfig/irqbalance').with({
                'content' => /^#IRQBALANCE_ONESHOT=$/,
              })
            end
          end

        end

        context "with affinity_mask parameter set to ['ff000000', '0000000']" do
          let (:params) { { :affinity_mask => ['ff000000', '0000000'], } }

          if operatingsystemrelease == 5.9
            it 'the irqbalance config file should contain IRQ_AFFINITY_MASK="ff000000,0000000"' do
              should contain_file('/etc/sysconfig/irqbalance').with({
                'content' => /^IRQ_AFFINITY_MASK="ff000000,0000000"$/,
              })
            end
          else
            it 'the irqbalance config file should not contain IRQ_AFFINITY_MASK' do
              should_not contain_file('/etc/sysconfig/irqbalance').with({
                'content' => /IRQ_AFFINITY_MASK/,
              })
            end
          end
        end

        context 'with no affinity_mask parameter provided' do
          # The default for this parameter is undef

          if operatingsystemrelease == 5.9
            it 'the irqbalance config file should contain #IRQ_AFFINITY_MASK' do
              should contain_file('/etc/sysconfig/irqbalance').with({
                'content' => /^#IRQ_AFFINITY_MASK=$/,
              })
            end
          else
            it 'the irqbalance config file should not contain IRQ_AFFINITY_MASK' do
              should_not contain_file('/etc/sysconfig/irqbalance').with({
                'content' => /IRQ_AFFINITY_MASK/,
              })
            end
          end
        end

        context "with banned_interrupts parameter set to ['01', '03']" do
          let (:params) { { :banned_interrupts => ['01', '03'], } }

          if operatingsystemrelease == 5.9
            it 'the irqbalance config file should contain IRQBALANCE_BANNED_INTERRUPTS="01 03"' do
              should contain_file('/etc/sysconfig/irqbalance').with({
                'content' => /^IRQBALANCE_BANNED_INTERRUPTS="01 03"$/,
              })
            end
          else
            it 'the irqbalance config file should not contain IRQBALANCE_BANNED_INTERRUPTS' do
              should_not contain_file('/etc/sysconfig/irqbalance').with({
                'content' => /IRQBALANCE_BANNED_INTERRUPTS/,
              })
            end
          end
        end

        context 'with no banned_interrupts parameter provided' do
          # The default for this parameter is undef

          if operatingsystemrelease == 5.9
            it 'the irqbalance config file should contain #IRQBALANCE_BANNED_INTERRUPTS' do
              should contain_file('/etc/sysconfig/irqbalance').with({
                'content' => /^#IRQBALANCE_BANNED_INTERRUPTS=$/,
              })
            end
          else
            it 'the irqbalance config file should not contain IRQBALANCE_BANNED_INTERRUPTS' do
              should_not contain_file('/etc/sysconfig/irqbalance').with({
                'content' => /IRQBALANCE_BANNED_INTERRUPTS/,
              })
            end
          end
        end

        context "with banned_cpus parameter set to ['fc3', '0000001']" do
          let (:params) { { :banned_cpus => ['fc3', '0000001'], } }

          it 'the irqbalance config file should contain IRQBALANCE_BANNED_CPUS="fc3,0000001"' do
            should contain_file('/etc/sysconfig/irqbalance').with({
              'content' => /^IRQBALANCE_BANNED_CPUS="fc3,0000001"$/,
            })
          end
        end

        context 'with no banned_cpus parameter provided' do
          # The default for this parameter is undef

          it 'the irqbalance config file should contain #IRQBALANCE_BANNED_CPUS=' do
            should contain_file('/etc/sysconfig/irqbalance').with({
              'content' => /^#IRQBALANCE_BANNED_CPUS=/,
            })
          end
        end

        context 'with args parameter set to "--args1 --args2"' do
          let (:params) { { :args => '--args1 --args2', } }

          if operatingsystemrelease != 5.9
            it 'the irqbalance config file should contain IRQBALANCE_ARGS="--args1 --args2"' do
              should contain_file('/etc/sysconfig/irqbalance').with({
                'content' => /^IRQBALANCE_ARGS="--args1 --args2"$/,
              })
            end
          else
            it 'the irqbalance config file should not contain IRQBALANCE_ARGS' do
              should_not contain_file('/etc/sysconfig/irqbalance').with({
                'content' => /^IRQBALANCE_ARGS$/,
              })
            end
          end
        end

        context 'with no args parameter provided' do
          # The default for this parameter is undef

          if operatingsystemrelease != 5.9
            it 'the irqbalance config file should contain #IRQBALANCE_ARGS=' do
              should contain_file('/etc/sysconfig/irqbalance').with({
                'content' => /^#IRQBALANCE_ARGS=$/,
              })
            end
          else
            it 'the irqbalance config file should not contain IRQBALANCE_ARGS' do
              should_not contain_file('/etc/sysconfig/irqbalance').with({
                'content' => /^IRQBALANCE_ARGS$/,
              })
            end
          end
        end

        context "with banirq parameter set to ['01', '03', '04']" do
          let (:params) { { :banirq => ['01', '03', '04'], } }

          if operatingsystemrelease < 6.0
            it 'the irqbalance config file should not contain --banirq' do
              should_not contain_file('/etc/sysconfig/irqbalance').with({
                'content' => /--banirq/,
              })
            end
          else
            it 'the irqbalance config file should contain --banirq=01 --banirq=03 --banirq=04"' do
              should contain_file('/etc/sysconfig/irqbalance').with({
                'content' => /--banirq=01 --banirq=03 --banirq=04/,
              })
            end
          end
        end

        context 'with no banirq parameter not provided' do
          # The default for this parameter is undef

          it 'the irqbalance config file should not contain --banirq' do
            should_not contain_file('/etc/sysconfig/irqbalance').with({
              'content' => /--banirq/,
            })
          end
        end

        context 'with banscript parameter set to /path/to/banscript.sh' do
          let (:params) { { :banscript => '/path/to/banscript.sh', } }

          if operatingsystemrelease == 6.6
            it 'the irqbalance config file should contain --banscript=/path/to/banscript.sh' do
              should contain_file('/etc/sysconfig/irqbalance').with({
                'content' => /--banscript=\/path\/to\/banscript\.sh/,
              })
            end
          else
            it 'the irqbalance config file should not contain --banscript' do
              should_not contain_file('/etc/sysconfig/irqbalance').with({
                'content' => /--banscript/,
              })
            end
          end
        end

        context 'with no banscript parameter provided' do
          # The default for this parameter is undef

          it 'the irqbalance config file should not contain --banscript' do
            should_not contain_file('/etc/sysconfig/irqbalance').with({
              'content' => /--banscript/,
            })
          end
        end

        context 'with debug parameter set to true' do
          let (:params) { { :debug => true, } }

          if operatingsystemrelease < 7.0
            it 'the irqbalance config file should not contain --debug' do
              should_not contain_file('/etc/sysconfig/irqbalance').with({
                'content' => /--debug/,
              })
            end
          else
            it 'the irqbalance config file should contain --debug' do
              should contain_file('/etc/sysconfig/irqbalance').with({
                'content' => /--debug/,
              })
            end
          end
        end

        context 'with debug parameter set to false' do
          let (:params) { { :debug => false, } }

          it 'the irqbalance config file should not contain --debug' do
            should_not contain_file('/etc/sysconfig/irqbalance').with({
              'content' => /--debug/,
            })
          end
        end

        context 'with deepestcache parameter set to 2' do
          let (:params) { { :deepestcache => '2', } }

          if operatingsystemrelease > 19
            it 'the irqbalance config file should contain --deepestcache=2' do
              should contain_file('/etc/sysconfig/irqbalance').with({
                'content' => /--deepestcache=2/,
              })
            end
          else
            it 'the irqbalance config file should not contain --deepestcache' do
              should_not contain_file('/etc/sysconfig/irqbalance').with({
                'content' => /--deepestcache/,
              })
            end
          end
        end

        context 'with no deepestcache parameter provided' do
          # The default for this parameter is undef

          it 'the irqbalance config file should not contain --deepestcache' do
            should_not contain_file('/etc/sysconfig/irqbalance').with({
              'content' => /--deepestcache/,
            })
          end
        end

        context 'with hintpolicy parameter set to exact' do
          let (:params) { { :hintpolicy => 'exact', } }
  
          if operatingsystemrelease != 5.9
            it 'the irqbalance config file should contain --hintpolicy=exact' do
              should contain_file('/etc/sysconfig/irqbalance').with({
                'content' => /--hintpolicy=exact/,
              })
            end
          else
            it 'the irqbalance config file should not contain --hintpolicy' do
              should_not contain_file('/etc/sysconfig/irqbalance').with({
                'content' => /--hintpolicy/,
              })
            end
          end
        end

        context 'with hintpolicy parameter set to subset' do
          let (:params) { { :hintpolicy => 'subset', } }

          if operatingsystemrelease != 5.9
            it 'the irqbalance config file should contain --hintpolicy=subset' do
              should contain_file('/etc/sysconfig/irqbalance').with({
                'content' => /--hintpolicy=subset/,
              })
            end
          else
            it 'the irqbalance config file should not contain --hintpolicy' do
              should_not contain_file('/etc/sysconfig/irqbalance').with({
                'content' => /--hintpolicy/,
              })
            end
          end
        end

        context 'with hintpolicy parameter set to ignore' do
          let (:params) { { :hintpolicy => 'ignore', } }

          if operatingsystemrelease != 5.9
            it 'the irqbalance config file should contain --hintpolicy=ignore' do
              should contain_file('/etc/sysconfig/irqbalance').with({
                'content' => /--hintpolicy=ignore/,
              })
            end
          else
            it 'the irqbalance config file should not contain --hintpolicy' do
              should_not contain_file('/etc/sysconfig/irqbalance').with({
                'content' => /--hintpolicy/,
              })
            end
          end
        end

        context 'with no hintpolicy parameter provided' do
          # The default for this parameter is undef
  
          it 'the irqbalance config file should not contain --hintpolicy' do
            should_not contain_file('/etc/sysconfig/irqbalance').with({
              'content' => /--hintpolicy/,
            })
          end
        end

        context 'with pid parameter set to /path/to/irqbalance.pid' do
          let (:params) { { :pid => '/path/to/irqbalance.pid', } }

          if operatingsystemrelease < 7.0
            it 'the irqbalance config file should not contain --pid' do
              should_not contain_file('/etc/sysconfig/irqbalance').with({
                'content' => /--pid/,
              })
            end
          else
            it 'the irqbalance config file should contain --pid=/path/to/irqbalance.pid' do
              should contain_file('/etc/sysconfig/irqbalance').with({
                'content' => /--pid=\/path\/to\/irqbalance\.pid/,
              })
            end
          end
        end

        context 'with no pid parameter provided' do
          # The default for this parameter is undef

          it 'the irqbalance config file should not contain --pid' do
            should_not contain_file('/etc/sysconfig/irqbalance').with({
              'content' => /--pid/,
            })
          end
        end

        context 'with policyscript parameter set to /path/to/policyscript' do
          let (:params) { { :policyscript => '/path/to/policyscript', } }

          if operatingsystemrelease < 7.0
            it 'the irqbalance config file should not contain --policyscript' do
              should_not contain_file('/etc/sysconfig/irqbalance').with({
                'content' => /--policyscript/,
              })
            end
          else
            it 'the irqbalance config file should contain --policyscript=/path/to/policyscript' do
              should contain_file('/etc/sysconfig/irqbalance').with({
                'content' => /--policyscript=\/path\/to\/policyscript/,
              })
            end
          end
        end

        context 'with no policyscript parameter provided' do
          # The default for this parameter is undef

          it 'the irqbalance config file should not contain --policyscript' do
            should_not contain_file('/etc/sysconfig/irqbalance').with({
              'content' => /--policyscript/,
            })
          end
        end

        context 'with powerthresh parameter set to 2' do
          let (:params) { { :powerthresh => '2', } }

          if operatingsystemrelease < 6.0
            it 'the irqbalance config file should not contain --powerthresh' do
              should_not contain_file('/etc/sysconfig/irqbalance').with({
                'content' => /--powerthresh/,
              })
            end
          else
            it 'the irqbalance config file should contain --powerthresh=2' do
              should contain_file('/etc/sysconfig/irqbalance').with({
                'content' => /--powerthresh=2/,
              })
            end
          end
        end

        context 'with no powerthresh parameter provided' do
          # The default for this parameter is undef

          it 'the irqbalance config file should not contain --powerthresh' do
            should_not contain_file('/etc/sysconfig/irqbalance').with({
              'content' => /--powerthresh/,
            })
          end
        end

        # Config file permissions
        context 'with default config file permissions and config_file_source parameter not set' do
          # The default for the config_file_source parameter is undef

          it 'the irqbalance config file should be owned by root' do
            should contain_file('/etc/sysconfig/irqbalance').with({
              'owner' => '0',
            })
          end

          it 'the irqbalance config file should be group root' do
            should contain_file('/etc/sysconfig/irqbalance').with({
              'group' => '0',
            })
          end

          it 'the irqbalance config file should be mode 0644' do
            should contain_file('/etc/sysconfig/irqbalance').with({
              'mode' => '0644',
            })
          end

        end

        context 'with config_file_owner parameter set to irqbalance' do
          let (:params) { { :config_file_owner => 'irqbalance', } }
          it { should contain_file('/etc/sysconfig/irqbalance').with_owner('irqbalance') }
        end

        context 'with config_file_group parameter set to irqbalancegroup' do
          let (:params) { { :config_file_group => 'irqbalancegroup', } }
          it { should contain_file('/etc/sysconfig/irqbalance').with_group('irqbalancegroup') }
        end

        context 'with config_file_mode parameter set to 0444' do
          let (:params) { { :config_file_mode => '0444', } }
          it { should contain_file('/etc/sysconfig/irqbalance').with_mode('0444') }
        end

        context 'with default config file permissions and config_file_source set to puppet:///modules/irqbalance/config/irq.conf' do
          let (:params) { { :config_file_source => 'puppet:///modules/irqbalance/config/irq.conf', } }

          it 'the irqbalance config file should be owned by root' do
            should contain_file('/etc/sysconfig/irqbalance').with({
              'owner' => '0',
            })
          end

          it 'the irqbalance config file should be group root' do
            should contain_file('/etc/sysconfig/irqbalance').with({
              'group' => '0',
            })
          end

          it 'the irqbalance config file should be mode 0644' do
            should contain_file('/etc/sysconfig/irqbalance').with({
              'mode' => '0644',
            })
          end

        end

        # Package resource tests
        context 'with the package_manage parameter set to true' do
          let (:default_params) { { :package_manage => true, } }

          context "and the package_ensure parameter set to 'installed'" do
            let :params do
              default_params.merge!({
                :package_ensure => 'installed',
              })
            end

            it 'the irqbalance package should be installed' do
              should contain_package('irqbalance').with({
                'ensure' => 'installed',
              })
            end
          end

          context "and the package_ensure parameter set to 'absent'" do
            let :params do
              default_params.merge!({
                :package_ensure => 'absent',
              })
            end

            it 'the irqbalance package should not be installed' do
              should contain_package('irqbalance').with({
                'ensure' => 'absent',
              })
            end
          end

          it 'the name of the package managed is irqbalance' do
            should contain_package('irqbalance').with({
              'name' => 'irqbalance',
            })
          end

        end

        context 'with the package_manage parameter set to false' do
          let (:params) { { :package_manage => false,} }

          it 'the package resource irqbalance should not be in the catalog' do
            should_not contain_package('irqbalance')
          end

        end

        # Init script resource tests

        context 'with the manage_init_script_file parameter set to true' do
          let (:default_params) { { :manage_init_script_file => true, } }

          context 'and sysv_init_script_file_source  or systemd_init_script_file set' do
            let :params do
              default_params.merge!({
                :sysv_init_script_file_source => 'puppet://modules/irqbalance/sysv',
                :systemd_init_script_file_source => 'puppet://modules/irqbalance/systemd',
              })
            end

            it 'the init script group should be root' do
              if operatingsystemrelease < 7.0
                should contain_file('/etc/init.d/irqbalance').with({
                  'group' => '0',
                })
              else
                should contain_file('/usr/lib/systemd/system/irqbalance.service').with({
                  'group' => '0',
                })
              end
            end

            it 'the init script owner should be root' do
              if operatingsystemrelease < 7.0
                should contain_file('/etc/init.d/irqbalance').with({
                  'owner' => '0',
                })
              else
                should contain_file('/usr/lib/systemd/system/irqbalance.service').with({
                  'owner' => '0',
                })
              end
            end

            if operatingsystemrelease < 7.0
              it 'the init script file permissions should be 0755' do
                should contain_file('/etc/init.d/irqbalance').with({
                  'mode' => '0755',
                })
              end
            else
              it 'the init script file permissions should be 0644' do
                should contain_file('/usr/lib/systemd/system/irqbalance.service').with({
                  'mode' => '0644',
                })
              end
            end

          end

          context 'and *_init_script_file_source not set' do
            # The *_init_script_file_source parameters default to undef
            let (:params) { { :manage_init_script_file => true, } }
          
            it 'the init script group should be root' do
              if operatingsystemrelease < 7.0
                should contain_file('/etc/init.d/irqbalance').with({
                  'group' => '0',
                })
              else
                should contain_file('/usr/lib/systemd/system/irqbalance.service').with({
                  'group' => '0',
                })
              end
            end

            it 'the init script owner should be root' do
              if operatingsystemrelease < 7.0
                should contain_file('/etc/init.d/irqbalance').with({
                  'owner' => '0',
                })
              else
                should contain_file('/usr/lib/systemd/system/irqbalance.service').with({
                  'owner' => '0',
                })
              end
            end

            if operatingsystemrelease < 7.0
              it 'the init script file permissions should be 0755' do
                should contain_file('/etc/init.d/irqbalance').with({
                  'mode' => '0755',
                })
              end
            else
              it 'the init script file permissions should be 0644' do
                should contain_file('/usr/lib/systemd/system/irqbalance.service').with({
                  'mode' => '0644',
                })
              end
            end

          end

        end

        context 'with the manage_init_script file parameter set to false' do
          let (:params) { { :manage_init_script_file => false, } }

          it 'the init script file resource should not be in the catalog' do
            if operatingsystemrelease < 7.0
              should_not contain_file('/etc/init.d/irqbalance')
            else
              should_not contain_file('/etc/init/irqbalance.conf')
            end
          end
        end

      end
    end

    context 'running SLES 11' do
      let :facts do
        default_facts.merge!({
          :operatingsystem        => 'SLES',
          :operatingsystemrelease => '11',
          :osfamily               => 'Suse',
        })
      end

      # Classes it should contain
      it { should contain_class('irqbalance::install') }
      it { should contain_class('irqbalance::config') }
      it { should contain_class('irqbalance::service') }
      it { should contain_class('irqbalance::initscripts') }

      # Service resource tests
      context 'with the irqbalance service managed and oneshot set to no' do
        let (:default_params) {{
          :service_manage => true,
          :oneshot => 'no',
        }}

        context 'and service_ensure parameter set to running' do
          let :params do
            default_params.merge!({
              :service_ensure => 'running',
            })
          end

          it 'the irqbalance service should be running' do
            should contain_service('irqbalance').with({
              'ensure'   => 'running',
            })
          end
        end

        context 'and service_ensure parameter set to stopped' do
          let :params do
            default_params.merge!({
              :service_ensure => 'stopped',
            })
          end

          it 'the irqbalance service should be stopped' do
            should contain_service('irqbalance').with({
              'ensure'   => 'stopped',
            })
          end
        end

      end

      context 'with the irqbalance service managed and oneshot set to yes' do
        let (:params) {{
          :service_manage => true,
          :oneshot => 'yes',
        }}

        it 'the running state of the irqbalance service is not managed' do
          should_not contain_service('irqbalance').with({
            'ensure'   => 'running',
          })
          should_not contain_service('irqbalance').with({
            'ensure'   => 'stopped',
          })
        end

      end

      context 'with the irqbalance service managed' do
        let (:default_params) {{
          :service_manage => true,
        }}

        context 'and service_enable parameter set to true' do
          let :params do
            default_params.merge!({
              :service_enable => true,
          })
          end

          it 'the irqbalance service should be started on startup' do
            should contain_service('irqbalance').with({
              'enable'   => true,
            })
          end
        end

        context 'and service_enable parameter set to false' do
          let :params do
            default_params.merge!({
              :service_enable => false,
            })
          end

          it 'the irqbalance service should not be started on startup' do
            should contain_service('irqbalance').with({
              'enable'   => false,
          })
          end
        end

        it 'the irqbalance service should be named irq_balancer' do
          should contain_service('irqbalance').with({
            'name'   => 'irq_balancer',
          })
        end

        it 'the service provider should be redhat' do
          should contain_service('irqbalance').with({
            'provider' => 'redhat',
          })
        end

      end

      context 'with the irqbalance service not managed' do
        let (:params) { { :service_manage => false,} }

        it 'the service resource irqbalance should not be in the catalog' do
          should_not contain_service('irqbalance')
        end

      end

      # Config file tests
      context "with banned_cpus provided as ['fc3', '0000000']" do
        let (:params) { { :banned_cpus => ['fc3', '0000000'], } }

         it 'the irqbalance config file should contain IRQBALANCE_BANNED_CPUS="fc3,0000000"' do
           should contain_file('/etc/sysconfig/irqbalance').with({
             'content' => /^IRQBALANCE_BANNED_CPUS="fc3,0000000"$/,
           })
         end
       end       

       context 'with no banned_cpus parameter provided' do
         # The default for this parameter is undef

        it 'the irqbalance config file should contain IRQBALANCE_BANNED_CPUS=""' do
          should contain_file('/etc/sysconfig/irqbalance').with({
            'content' => /^IRQBALANCE_BANNED_CPUS=""$/,
          })
        end
      end

      context 'with oneshot parameter set to yes' do
        let (:params) { { :oneshot => 'yes', } }

        it 'the irqbalance config file should contain IRQBALANCE_ONESHOT=enabled' do
          should contain_file('/etc/sysconfig/irqbalance').with({
            'content' => /^IRQBALANCE_ONESHOT=enabled$/,
          })
        end
      end

      context 'with oneshot parameter set to no' do
        let (:params) { { :oneshot => 'no', } }

        it 'the irqbalance config file should contain IRQBALANCE_ONESHOT=auto' do
          should contain_file('/etc/sysconfig/irqbalance').with({
            'content' => /^IRQBALANCE_ONESHOT=auto$/,
          })
        end
      end

      context "with banned_interrupts parameter set to ['33', '03']" do
        let (:params) { { :banned_interrupts => ['33', '03'], } }

        it 'the irqbalance config file should contain IRQBALANCE_BANNED_INTERRUPTS="33 03"' do
          should contain_file('/etc/sysconfig/irqbalance').with({
            'content' => /^IRQBALANCE_BANNED_INTERRUPTS="33 03"$/,
          })
        end
      end

      context 'with no banned_interrupts parameter provided' do
        # The default for this parameter is undef

        it 'the irqbalance config file should contain IRQBALANCE_BANNED_INTERRUPTS=""' do
          should contain_file('/etc/sysconfig/irqbalance').with({
            'content' => /^IRQBALANCE_BANNED_INTERRUPTS=""$/,
          }) 
        end
      end

      # Config file permissions
      context 'with default config file permissions and config_file_source parameter not set' do
        # The default for the config_file_source parameter is undef

        it 'the irqbalance config file should be owned by root' do
          should contain_file('/etc/sysconfig/irqbalance').with({
            'owner' => '0',
          })
        end

        it 'the irqbalance config file should be group root' do
          should contain_file('/etc/sysconfig/irqbalance').with({
            'group' => '0',
          })
        end

        it 'the irqbalance config file should be mode 0644' do
          should contain_file('/etc/sysconfig/irqbalance').with({
            'mode' => '0644',
          })
        end

      end

      context 'with config_file_owner parameter set to irqbalance' do
        let (:params) { { :config_file_owner => 'irqbalance', } }
        it { should contain_file('/etc/sysconfig/irqbalance').with_owner('irqbalance') }
      end

      context 'with config_file_group parameter set to irqbalancegroup' do
        let (:params) { { :config_file_group => 'irqbalancegroup', } }
        it { should contain_file('/etc/sysconfig/irqbalance').with_group('irqbalancegroup') }
      end

      context 'with config_file_mode parameter set to 0444' do
        let (:params) { { :config_file_mode => '0444', } }
        it { should contain_file('/etc/sysconfig/irqbalance').with_mode('0444') }
      end

      context 'with default config file permissions and config_file_source set to puppet:///modules/irqbalance/config/irq.conf' do
        let (:params) { { :config_file_source => 'puppet:///modules/irqbalance/config/irq.conf', } }

        it 'the irqbalance config file should be owned by root' do
          should contain_file('/etc/sysconfig/irqbalance').with({
            'owner' => '0',
          })
        end

        it 'the irqbalance config file should be group root' do
          should contain_file('/etc/sysconfig/irqbalance').with({
            'group' => '0',
          })
        end

        it 'the irqbalance config file should be mode 0644' do
          should contain_file('/etc/sysconfig/irqbalance').with({
            'mode' => '0644',
          })
        end

      end

      # Package resource tests
      context 'with the package_manage parameter set to true' do
        let (:default_params) { { :package_manage => true, } }

        context "and the package_ensure parameter set to 'installed'" do
          let :params do
            default_params.merge!({
              :package_ensure => 'installed',
            })
          end

          it 'the irqbalance package should be installed' do
            should contain_package('irqbalance').with({
              'ensure' => 'installed',
            })
          end
        end

        context "and the package_ensure parameter set to 'absent'" do
          let :params do
            default_params.merge!({
              :package_ensure => 'absent',
            })
          end

          it 'the irqbalance package should not be installed' do
            should contain_package('irqbalance').with({
              'ensure' => 'absent',
            })
          end
        end

        it 'the name of the package managed is irqbalance' do
          should contain_package('irqbalance').with({
            'name' => 'irqbalance',
          })
        end

      end

      context 'with the package_manage parameter set to false' do
        let (:params) { { :package_manage => false,} }

        it 'the package resource irqbalance should not be in the catalog' do
          should_not contain_package('irqbalance')
        end

      end

      # Init script resource tests

      context 'with the manage_init_script_file parameter set to true' do
        let (:default_params) { { :manage_init_script_file => true, } }

        context 'and sysv_init_script_file_source set' do
          let :params do
            default_params.merge!({
              :sysv_init_script_file_source => 'puppet://modules/irqbalance/sysv',
            })
          end

          it 'the init script group should be root' do
            should contain_file('/etc/init.d/irq_balancer').with({
              'group' => '0',
            })
          end

          it 'the init script owner should be root' do
            should contain_file('/etc/init.d/irq_balancer').with({
              'owner' => '0',
            })
          end

          it 'the init script file permissions should be 0755' do
            should contain_file('/etc/init.d/irq_balancer').with({
              'mode' => '0755',
            })
          end

        end

        context 'and *_init_script_file_source not set' do
          # The *_init_script_file_source parameters default to undef
          let (:params) { { :manage_init_script_file => true, } }
          
          it 'the init script group should be root' do
            should contain_file('/etc/init.d/irq_balancer').with({
              'group' => '0',
            })
          end

          it 'the init script owner should be root' do
            should contain_file('/etc/init.d/irq_balancer').with({
              'owner' => '0',
            })
          end

          it 'the init script file permissions should be 0755' do
            should contain_file('/etc/init.d/irq_balancer').with({
              'mode' => '0755',
            })
          end

        end

      end

      context 'with the manage_init_script file parameter set to false' do
        let (:params) { { :manage_init_script_file => false, } }

        it 'the init script file resource should not be in the catalog' do
          should_not contain_file('/etc/init.d/irq_balancer')
        end

      end

    end

  end

  context 'when on a single processor system' do
    let(:facts) {{
      :operatingsystemrelease => '6.0',
      :osfamily               => 'RedHat',
      :processorcount         => '1',
    }}

    context 'with the irqbalance service managed' do
      let (:params) { { :service_manage => true, } }

      it 'the running state of the irqbalance service is not managed' do
        should_not contain_service('irqbalance').with({
          'ensure' => 'running',
        })
        should_not contain_service('irqbalance').with({
         'ensure' => 'stopped',
       })
      end

    end

  end

end

