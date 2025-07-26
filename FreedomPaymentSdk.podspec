Pod::Spec.new do |s|
  # ---- Basic metadata ------------------------------------------------------
  s.name         = 'FreedomPaymentSdk'
  s.version      = '1.0.0'
  s.summary      = 'Binary SDK for Freedom Payments.'
  s.description  = <<-DESC
    The Payment SDK is a library that simplifies interaction with the Freedom Pay API.
  DESC

  s.homepage     = 'https://github.com/freedompay-global/merchant-sdk-ios'
  s.license      = { :type => 'Proprietary', :text => 'All rights reserved.' }
  s.author       = { 'Freedom Pay Team' => 'support@freedompay.kz' }

  s.source       = {
    :git => 'https://github.com/freedompay-global/merchant-sdk-ios.git',
    :tag => s.version.to_s
  }
  s.vendored_frameworks = 'FreedomPaymentSdk.xcframework'
  s.static_framework = true
  s.platform      = :ios, '15.0'
  s.swift_version = '6.1.2'
end
