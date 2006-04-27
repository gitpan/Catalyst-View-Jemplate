use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/lib";

use Test::More tests => 6;
use Catalyst::Test 'TestApp';

BEGIN {
    no warnings 'redefine';

    *Catalyst::Test::local_request = sub {
        my ( $class, $request ) = @_;

        require HTTP::Request::AsCGI;
        my $cgi = HTTP::Request::AsCGI->new( $request, %ENV )->setup;

        $class->handle_request;

        return $cgi->restore->response;
    };
}

my $entrypoint = "http://localhost/jemplate";

{
    my $request = HTTP::Request->new( GET => $entrypoint );

    ok( my $response = request($request), 'Request' );
    ok( $response->is_success, 'Response Successful 2xx' );
    is( $response->code, 200, 'Response Code' );

    is_deeply( [ $response->content_type ], [ 'text/javascript', 'charset=utf-8' ] );

    like $response->content, qr!//line 1 "foo\.tt"!;
    like $response->content, qr!//line 1 "bar\.tt"!;
}