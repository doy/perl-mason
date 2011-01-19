package Mason::Plugin::AdvancedPageResolution;
use Moose;
with 'Mason::Plugin';

1;

# ABSTRACT: advanced resolution of request paths to page components
__END__

=head1 DESCRIPTION

This plugin enhances the way that top-level paths are mapped to page
components. It provides default file extensions for REST-style URLs and
provides various ways to handle entire path hierarchies with a single
component.

It is intended for those using Mason as the main controller in a web
application, rather than as just a view layer.

=head1 DETERMINING THE PAGE COMPONENT

Given a top-level request path, Mason generates a number of candidate component
paths, searching in order until one is found:

=over

=item *

The requested path itself, suffixed with ".pm" or ".m"

=item *

"index.pm" or "index.m" under the requested path

=item *

"dhandler.pm" or "dhandler.m" under the requested path

=back

If it cannot find any of these, then Mason scans backwards through the path,
checking each directory upwards for the same set of files B<except> for
"index.*". In this case it sets $m->path_info to the unmatched latter part of
the path.

For example, given the path

    /news/sports/hockey

Mason searches for the following components in order, setting $m->path_info as
noted.

    /news/sports/hockey.{pm,m}
    /news/sports/hockey/index.{pm,m}
    /news/sports/hockey/dhandler.{pm,m}
    /news/sports.{pm,m}           # $m->path_info = hockey
    /news/sports/dhandler.{pm,m}  # $m->path_info = hockey
    /news.{pm,m}                  # $m->path_info = sports/hockey
    /news/dhandler.{pm,m}         # $m->path_info = sports/hockey
    /dhandler.{pm,m}              # $m->path_info = news/sports/hockey

A component or dhandler that does not want to handle a particular request may
defer control to the next dhandler by calling L</decline>.

Note that the bare request path itself (in this case C<< /news/sports/hockey
>>) is not one of the components searched for. You can add the empty string
("") to L</page_extensions> to change this.

=head1 ADDITIONAL INTERP PARAMETERS

=over

=item dhandler_names

Array reference of dhandler file names to check in order when resolving a
top-level path. Default is C<< ["dhandler.pm", "dhandler.m"] >>. See
L<Mason::Manual/Determining the page component>.

=item index_names

Array reference of index file names to check in order when resolving a
top-level path (only in the bottom-most directory). Default is C<< ["index.pm",
"index.m"] >>. See L<Mason::Manual/Determining the page component>.

=item page_extensions

Array reference of filename extensions to try when generating page component
paths. Default is C<< [".pm", ".m"] >>.

You can add the empty string ("") to this list if you want Mason to use the
request path itself as a page component candidate.

=back

=head1 ADDITIONAL REQUEST METHODS

=over

=item decline

Clears the output buffer and issues the current request again, but acting as if
the previously chosen page component(s) do not exist.

For example, if the following components exist:

    /news/sports.m
    /news/dhandler.m
    /dhandler.m

then a request for path C</news/sports> will initially resolve to
C</news/sports.m>.  A call to C<< $m->decline >> would restart the request and
resolve to C</news/dhandler.m>, a second C<< $m->decline >> would resolve to
C</dhandler.m>, and a third would throw a "not found" error.

=back