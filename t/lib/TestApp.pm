package TestApp;

use strict;
use warnings;

use Catalyst;

our $VERSION = '0.01';
__PACKAGE__->config({
    name => 'TestApp',
    'View::Jemplate' => {
        jemplate_dir => TestApp->path_to('root'),
    },
});

__PACKAGE__->setup;

sub jemplate : Global {
    my ( $self, $c ) = @_;
    $c->forward('View::Jemplate');
}

sub finalize_error {
    my $c = shift;
    $c->res->header('X-Error' => $c->error->[0]);
    $c->NEXT::finalize_error;
}

1;
