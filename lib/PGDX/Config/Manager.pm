package PGDX::Config::Manager;

use Moose;
use Carp;
use Config::IniFiles;

use constant TRUE => 1;
use constant FALSE => 0;

has 'config_file' => (
    is       => 'rw',
    isa      => 'Str',
    writer   => 'setConfigFile',
    reader   => 'getConfigFile',
    required => FALSE    
    );

## Singleton support
my $instance;


sub BUILD {

    my $self = shift;

    $self->{_is_parsed} = FALSE;
}

sub getInstance {

    if (!defined($instance)){

        $instance = new PGDX::Config::Manager(@_);

        if (!defined($instance)){

            confess "Could not instantiate PGDX::Config::Manager";
        }
    }

    return $instance;
}

sub getLogLevel {

    my $self = shift;

    return $self->_getValue('log4perl', 'level');
}

sub getLogFormat {

    my $self = shift;

    return $self->_getValue('log4perl', 'format');
}

sub getSourceFileOrderedHeaderList {

    my $self = shift;
 
    return $self->_getValue('source_file', 'ordered_header_list');
}

sub getSourceFileEOL {

    my $self = shift;
 
    return $self->_getValue('source_file', 'end_of_line');
}

sub getTargetFileOrderedHeaderList {

    my $self = shift;
 
    return $self->_getValue('target_file', 'ordered_header_list');
}

sub getTargetFileNameExtension {

    my $self = shift;
 
    return $self->_getValue('target_file', 'extension');
}

sub getTargetFileEOL {

    my $self = shift;
 
    return $self->_getValue('target_file', 'end_of_line');
}

sub _isParsed {

    my $self = shift;

    return $self->{_is_parsed};
}

sub _getValue {

    my $self = shift;
    my ($section, $parameter) = @_;

    if (! $self->_isParsed(@_)){

        $self->_parseFile(@_);
    }

    my $value = $self->{_cfg}->val($section, $parameter);

    if ((defined($value)) && ($value ne '')){
        return $value;
    }
    else {
        return undef;
    }
}


sub _parseFile {

    my $self = shift;
    my $file = $self->_getConfigFile(@_);

    my $cfg = new Config::IniFiles(-file => $file);
    if (!defined($cfg)){
        confess "Could not instantiate Config::IniFiles";
    }

    $self->{_cfg} = $cfg;

    $self->{_is_parsed} = TRUE;
}

sub _getConfigFile {

    my $self = shift;
    my (%args) = @_;

    my $configFile = $self->getConfigFile();

    if (!defined($configFile)){

        if (( exists $args{_config_file})  && ( defined $args{_config_file})){
            $configFile = $args{_config_file};
        }
        elsif (( exists $self->{_config_file}) && ( defined $self->{_config_file})){
            $configFile = $self->{_config_file};
        }
        else {

            confess "config_file was not defined";
        }

        $self->setConfigFile($configFile);
    }

    return $configFile;
}


no Moose;
__PACKAGE__->meta->make_immutable;


__END__

=head1 NAME

 PGDX::Config::Manager

=head1 VERSION

 1.0

=head1 SYNOPSIS

 use PGDX::Config::Manager;

 my $cm = PGDX::Config::Manager::getInstance();

 $cm->getLogFormat();

=head1 AUTHOR

 Jaideep Sundaram

 Copyright Jaideep Sundaram

=head1 METHODS

 new
 _init
 DESTROY
 getInstance

=over 4

=cut
