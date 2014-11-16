Pod::Spec.new do |spec|
	spec.name                = 'deHTML'
	spec.version             = '0.1'
	spec.license             = { :type => 'MIT' }
	spec.homepage            = 'https://github.com/byss/' + spec.name
	spec.authors             = { 'Kirill byss Bystrov' => 'kirrbyss@gmail.com' }
	spec.summary             = 'Tiny library containing just one effective function that decodes HTML entities in UTF-8 string.'
	spec.source              = { :git => spec.homepage + '.git', :tag => 'v' + spec.version.to_s }
	spec.source_files        = 'dehtml.{h,c}', 'NSString+deHTML.{h,m}'
	spec.prepare_command     = 'make dehtml.c'
	spec.requires_arc        = true
end
