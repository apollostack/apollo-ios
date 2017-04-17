Pod::Spec.new do |s|
  s.name         = 'Apollo'
  s.version      = `scripts/get-version.sh`
  s.author       = 'Meteor Development Group'
  s.homepage     = 'https://github.com/apollographql/apollo-ios'
  s.license      = { :type => 'MIT', :file => 'LICENSE' }

  s.summary      = "A GraphQL client for iOS, written in Swift."

  s.source       = { :git => 'https://github.com/apollographql/apollo-ios.git', :tag => s.version }

  s.requires_arc = true

  s.subspec 'Core' do |ss|
    ss.ios.deployment_target = '8.0'
    ss.osx.deployment_target = '10.10'
    ss.tvos.deployment_target = '9.0'
    ss.source_files = 'Sources/*.swift'
    ss.resource = 'scripts/check-and-run-apollo-codegen.sh'
  end

  s.subspec 'SQLite' do |ss|
    ss.ios.deployment_target = '8.0'
    ss.osx.deployment_target = '10.10'
    ss.source_files = "ApolloSQLite/*.swift"
    ss.dependency 'SQLite.swift', '0.11.2' # 0.11.3 doesn't support iOS < 9
  end
end
