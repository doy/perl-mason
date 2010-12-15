package Mason::t::Plugins;
use strict;
use warnings;
use Capture::Tiny qw(capture_merged);
use Test::Most;
use base qw(Mason::Test::Class);

sub test_plugins : Test(7) {
    my $self = shift;

    $self->{interp} = $self->create_interp( plugins => ['+Mason::Test::Plugins::Notify'] );
    $self->add_comp( path => '/test_plugin_support.mi', component => 'hi' );
    my $output = capture_merged {
        $self->test_comp(
            path      => '/test_plugin.m',
            component => '<& test_plugin_support.mi &>',
            expect    => 'hi'
        );
    };
    my $like = sub { my $regex = shift; like( $output, $regex, $regex ) };
    $like->(qr/starting interp run/);
    $like->(qr/starting request run - \/test_plugin/);
    $like->(qr/starting request comp - test_plugin_support.mi/);
    $like->(qr/starting component render - \/test_plugin.m/);
    $like->(qr/starting compiler compile - \/test_plugin.m/);
    $like->(qr/starting compilation compile - \/test_plugin.m/);
}

1;