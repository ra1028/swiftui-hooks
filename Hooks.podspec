Pod::Spec.new do |spec|
    spec.name = 'Hooks'
    spec.version  = `cat .version`
    spec.author = { 'ra1028' => 'r.fe51028.r@gmail.com' }
    spec.homepage = 'https://github.com/ra1028/SwiftUI-Hooks'
    spec.summary = 'A SwiftUI implementation of React Hooks.'
    spec.source = { :git => 'https://github.com/ra1028/SwiftUI-Hooks.git', :tag => spec.version.to_s }
    spec.license = { :type => 'MIT', :file => 'LICENSE' }

    spec.swift_versions = '5.3'
    spec.source_files = 'Sources/Hooks/**/*.swift'
    spec.frameworks = 'SwiftUI', 'Combine'

    spec.ios.deployment_target = '13.0'
    spec.osx.deployment_target = '10.15'
    spec.tvos.deployment_target = '13.0'
    spec.watchos.deployment_target = '6.0'

    spec.pod_target_xcconfig = {
        'APPLICATION_EXTENSION_API_ONLY' => 'YES',
        'BUILD_LIBRARY_FOR_DISTRIBUTION' => 'YES'
   }
end
