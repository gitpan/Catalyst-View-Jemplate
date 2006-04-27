package Catalyst::View::Jemplate;

use strict;
our $VERSION = '0.02';

use base qw( Catalyst::View );
use File::Find::Rule;
use Jemplate;
use NEXT;

__PACKAGE__->mk_accessors(qw( jemplate_dir jemplate_ext encoding ));

sub new {
    my($class, $c, $arguments) = @_;
    my $self = $class->NEXT::new($c);

    $self->jemplate_dir($arguments->{jemplate_dir});
    $self->jemplate_ext($arguments->{jemplate_ext} || '.tt');
    $self->encoding($arguments->{encoding} || 'utf-8');

    my $dir = $self->jemplate_dir
        or Catalyst::Exception->throw("jemplate_dir needed");

    unless (-e $dir && -d _) {
        Catalyst::Exception->throw("$dir: $!");
    }

    $self;
}

sub process {
    my($self, $c) = @_;

    my @files = File::Find::Rule->file
                                ->name( '*' . $self->jemplate_ext )
                                ->in( $self->jemplate_dir );

    # xxx error handling?
    my $js = Jemplate->compile_template_files(@files);

    my $encoding = $self->encoding || 'utf-8';
    if (($c->req->user_agent || '') =~ /Opera/) {
        $c->res->content_type("application/x-javascript; charset=$encoding");
    } else {
        $c->res->content_type("text/javascript; charset=$encoding");
    }

    $c->res->output($js);
}

1;
__END__

=head1 NAME

Catalyst::View::Jemplate - Jemplate files server

=head1 SYNOPSIS

  package MyApp::View::Jemplate;
  use base qw( Catalyst::View::Jemplate );

  package MyApp;

  MyApp->config(
      'View::Jemplate' => {
          jemplate_dir => MyApp->path_to('root', 'jemplate'),
          jemplate_ext => '.tt',
      },
  );

  sub jemplate : Global {
      my($self, $c) = @_;
      $c->forward('View::Jemplate');
  }

=head1 DESCRIPTION

Catalyst::View::Jemplate is a Catalyst View plugin to automatically
compile TT files into JavaScript, using ingy's Jemplate.

Instead of creating the compiled javascript files by-hand, you can
include the file via Catalyst app like:

  <script src="js/Jemplate.js" type="text/javascript"></script>
  <script src="/jemplate/all.js" type="text/javascript"></script>

=head1 TODO

=over 4

=item *

Yeah, we definitely need a cache. For now it compiles templates in
every request, which is not very efficient.

=item *

Right now all the template files under C<jemplate_dir> is compiled
into a single JavaScript file and served. Probably we need a path
option to limit the directory.

=cut

=head1 AUTHOR

Tatsuhiko Miyagawa E<lt>miyagawa@bulknews.netE<gt>

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

L<>

=cut
