use ExtUtils::MakeMaker;
WriteMakefile(
	'NAME'          => 'PXR',
	'VERSION_FROM'  => 'PXR.pm',
	'PREREQ_PM'     =>  {
	
		'POE::Filter::XML'  => 0,
		'IO::File'			=> 0,
	}
);
