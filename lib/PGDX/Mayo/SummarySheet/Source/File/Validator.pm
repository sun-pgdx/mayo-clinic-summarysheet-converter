package PGDX::Mayo::SummarySheet::Source::File::Validator;

use Moose;

extends 'PGDX::File::Validator';

use constant TRUE  => 1;

use constant FALSE => 0;

use constant DEFAULT_VERBOSE => TRUE;


sub BUILD {

    my $self = shift;

    $self->_initLogger(@_);

    $self->_initConfigManager(@_);

    $self->{_logger}->info("Instantiated ". __PACKAGE__);
}

sub _initConfigManager {

    my $self = shift;
    
    my $config_manager = PGDX::Config::Manager::getInstance();
    if (!defined($config_manager)){
        $self->{_logger}->logconfess("Could not instantiate PGDX::Config::Manager");
    }

    $self->{_config_manager} = $config_manager;
}

no Moose;
__PACKAGE__->meta->make_immutable;

__END__

=head1 NAME

 PGDX::Mayo::SummarySheet::Source::File::Validator
 
=head1 VERSION

 1.0

=head1 SYNOPSIS

 use PGDX::Mayo::SummarySheet::Source::File::Validator;
 my $validator = new PGDX::Mayo::SummarySheet::Source::File::Validator(infile => $infile);
 if (!$validator->isValid()){
    print "file '$infile' is not valid\n";
 }

=head1 AUTHOR

 Jaideep Sundaram

 Copyright Jaideep Sundaram

=head1 METHODS

=over 4

=cut