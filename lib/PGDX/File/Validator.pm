package PGDX::File::Validator;

use Moose;

use PGDX::Logger;

use constant TRUE  => 1;

use constant FALSE => 0;

use constant DEFAULT_VERBOSE => FALSE;

has 'infile' => (
    is       => 'rw',
    isa      => 'Str',
    writer   => 'setInfile',
    reader   => 'getInfile',
    required => FALSE
    );

has 'verbose' => (
    is       => 'rw',
    isa      => 'Bool',
    writer   => 'setVerbose',
    reader   => 'getVerbose',
    required => FALSE,
    default  => DEFAULT_VERBOSE
    );


## Singleton support
my $instance;

sub BUILD {

    my $self = shift;

    $self->_initLogger(@_);

    $self->_initConfigManager(@_);

    $self->{_logger}->info("Instantiated ". __PACKAGE__);
}

sub _initLogger {

    my $self = shift;

    my $logger = Log::Log4perl->get_logger(__PACKAGE__);

    if (!defined($logger)){
        confess "logger was not defined";
    }

    $self->{_logger} = $logger;
}

sub hasNonPrintableChar {

    my $self = shift;
    my ($val) = @_;

    if (!defined($val)){
        $self->{_logger}->logconfess("val was not defined");
    }

    if ($val =~ /[^[:print:]]/){
        $self->{_logger}->warn("val '$val' contains a non-printable character");
        return TRUE;
    }

    return FALSE;
}

sub hasNonAsciiChar {

    my $self = shift;
    my ($val) = @_;

    if (!defined($val)){
        $self->{_logger}->logconfess("val was not defined");
    }

    if ($val =~ /[^[:ascii:]]/){
        $self->{_logger}->warn("val '$val' contains a non-ascii character");
        return TRUE;
    }

    return FALSE;
}


no Moose;
__PACKAGE__->meta->make_immutable;

__END__


=head1 NAME

 PGDX::File::Validator
 

=head1 VERSION

 1.0

=head1 SYNOPSIS

 use PGDX::File::Validator;
 my $validator = PGDX::File::Validator::getInstance();
 if ($validator->hasNonPrintableChar($val)){
    print("val '$val' has a non-printable character in it!");
 }

=head1 AUTHOR

 Jaideep Sundaram

 Copyright Jaideep Sundaram

=head1 METHODS

=over 4

=cut