Pod::Spec.new do |spec|
	spec.name                = 'deHTML'
	spec.version             = '0.5.2'
	spec.license             = { :type => 'MIT' }
	spec.homepage            = "https://github.com/byss/#{spec.name}"
	spec.authors             = { 'Kirill byss Bystrov' => 'kirrbyss@gmail.com' }
	spec.summary             = 'Tiny library containing just one effective function that decodes HTML entities in UTF-8/UTF-16 string.'
	spec.source              = { :git => "#{spec.homepage}.git", :tag => "v#{spec.version}" }
	spec.source_files        = 'dehtml.{h,c}', 'NSString+deHTML.{h,m}'
	spec.prepare_command     = 'make dehtml.c'
	spec.requires_arc        = true

	spec.ios.deployment_target     = '4.0'
	spec.osx.deployment_target     = '10.6'
	spec.tvos.deployment_target    = '9.0'
	spec.watchos.deployment_target = '2.0'
	spec.frameworks = 'Foundation'
end
