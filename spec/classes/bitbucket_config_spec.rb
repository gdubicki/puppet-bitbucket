require 'spec_helper'

describe 'bitbucket' do
  describe 'bitbucket::config' do
    context 'supported operating systems' do
      on_supported_os.each do |os, facts|
        context "on #{os} #{facts}" do
          let(:facts) do
            facts
          end

          context 'default params' do
            let(:params) do
              { :javahome    => '/opt/java',
                :version     => '3.7.0',
                :tomcat_port => '7990',
              }
            end
            it do
              should contain_file('/opt/bitbucket/atlassian-bitbucket-3.7.0/bin/setenv.sh') \
                .with_content(%r{JAVA_HOME=\/opt\/java})
                .with_content(/^JVM_MINIMUM_MEMORY="256m"/)
                .with_content(/^JVM_MAXIMUM_MEMORY="1024m"/)
            end
            it { should contain_file('/opt/bitbucket/atlassian-bitbucket-3.7.0/bin/user.sh') }
            it do
              should contain_file('/opt/bitbucket/atlassian-bitbucket-3.7.0/conf/server.xml')
                .with_content(/<Connector port="7990"/)
                .with_content(/path=""/)
                .without_content(/proxyName/)
                .without_content(/proxyPort/)
                .without_content(/scheme/)
            end

            it do
              should contain_file('/home/bitbucket/shared/bitbucket.properties')
                .with_content(/jdbc\.driver=org\.postgresql\.Driver/)
                .with_content(%r{jdbc\.url=jdbc:postgresql://localhost:5432/bitbucket})
                .with_content(/jdbc\.user=bitbucket/)
                .with_content(/jdbc\.password=password/)
            end

            it do
              should contain_ini_setting('bitbucket_httpport').with('value' => '7990',)
            end
          end

          context 'bitbucket 3.8.1' do
            let(:params) do
              { :version => '3.8.1' }
            end

            it do
              should contain_file('/home/bitbucket/shared/bitbucket.properties')
                .with_content(/setup\.displayName=bitbucket/)
                .with_content(%r{setup\.baseUrl=https://foo.example.com})
                .with_content(/setup\.sysadmin\.username=admin/)
                .with_content(/setup\.sysadmin\.password=bitbucket/)
                .with_content(/setup\.sysadmin\.displayName=Bitbucket Admin/)
                .with_content(/setup\.sysadmin\.emailAddress=/)
            end
          end

          context 'bitbucket 3.8.1 with additional bitbucket.properties values' do
            let(:params) do
              { :version => '3.8.1',
                :config_properties => {
                  'aaaa'   => 'bbbb',
                  'cccc'   => 'dddd',
                },
              }
            end

            it do
              should contain_file('/home/bitbucket/shared/bitbucket.properties')
                .with_content(/^aaaa=bbbb$/)
                .with_content(/^cccc=dddd$/)
            end
          end

          context 'bitbucket 3.7.0 with additional bitbucket.properties values' do
            let(:params) do
              { :version => '3.7.0',
                :config_properties => {
                  'aaaa'   => 'bbbb',
                  'cccc'   => 'dddd',
                },
              }
            end

            it do
              should_not contain_file('/home/bitbucket/shared/bitbucket.properties')
                .with_content(/^aaaa=bbbb$/)
                .with_content(/^cccc=dddd$/)
            end
          end

          context 'proxy settings ' do
            let(:params) do
              { :version => '3.7.0',
                :proxy   => {
                  'scheme'    => 'https',
                  'proxyName' => 'bitbucket.example.co.za',
                  'proxyPort' => '443',
                },
              }
            end
            it do
              should contain_file('/opt/bitbucket/atlassian-bitbucket-3.7.0/conf/server.xml') \
                .with_content(/proxyName = \'bitbucket\.example\.co\.za\'/)
                .with_content(/proxyPort = \'443\'/)
                .with_content(/scheme = \'https\'/)
            end
          end

          context 'bitbucket 3.8.0' do
            let(:params) do
              { :version => '3.8.0' }
            end
            it do
              should_not contain_file('/opt/bitbucket/atlassian-bitbucket-3.7.0/conf/server.xml')
              should contain_file('/home/bitbucket/shared/server.xml')
            end
          end

          context 'jvm_xms => 1G' do
            let(:params) do
              { :version => '3.7.0',
                :jvm_xms => '1G',
              }
            end
            it do
              should contain_file('/opt/bitbucket/atlassian-bitbucket-3.7.0/bin/setenv.sh')
                .with_content(/^JVM_MINIMUM_MEMORY="1G"/)
            end
          end

          context 'jvm_xmx => 4G' do
            let(:params) do
              { :version => '3.7.0',
                :jvm_xmx => '4G',
              }
            end
            it do
              should contain_file('/opt/bitbucket/atlassian-bitbucket-3.7.0/bin/setenv.sh')
                .with_content(/^JVM_MAXIMUM_MEMORY="4G"/)
            end
          end

          context 'java_opts => "-Dhttp.proxyHost=proxy.example.co.za -Dhttp.proxyPort=8080"' do
            let(:params) do
              { :version   => '3.7.0',
                :java_opts => '-Dhttp.proxyHost=proxy.example.co.za -Dhttp.proxyPort=8080',
              }
            end
            it do
              should contain_file('/opt/bitbucket/atlassian-bitbucket-3.7.0/bin/setenv.sh')
                .with_content(/JAVA_OPTS="-Dhttp\.proxyHost=proxy\.example\.co\.za -Dhttp\.proxyPort=8080/)
            end
          end

          context 'context_path => "bitbucket"' do
            let(:params) do
              { :version      => '3.7.0',
                :context_path => '/bitbucket',
              }
            end
            it do
              should contain_file('/opt/bitbucket/atlassian-bitbucket-3.7.0/conf/server.xml')
                .with_content(%r{path="/bitbucket"})
            end
          end

          context 'tomcat_port => "7991"' do
            let(:params) do
              { :version     => '3.7.0',
                :tomcat_port => '7991',
              }
            end
            it do
              should contain_file('/opt/bitbucket/atlassian-bitbucket-3.7.0/conf/server.xml')
                .with_content(/<Connector port="7991"/)
            end

            it do
              should contain_ini_setting('bitbucket_httpport').with('value' => '7991',)
            end
          end
        end
      end
    end
  end
end
