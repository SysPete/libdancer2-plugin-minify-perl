use strictures;

package Dancer2::Plugin::Minify;

# ABSTRACT: Minify HTML, JavaScript and CSS

use Dancer2::Plugin;

use HTML::Packer;
use JavaScript::Packer;
use CSS::Packer;

# VERSION

=head1 SYNOPSIS

    use Dancer2;
    use Dancer::Plugin::Minify;

    get '/index.html' => sub {
        minify(html => '<bloated>HTML</bloated>');
    }

    get '/index.js' => sub {
        minify(js => 'function bloated() {  }');
    }

    get '/index.css' => sub {
        minify(css => 'bloated { display: none; }');
    }

=head1 DESCRIPTION

This Dancer2 plugin is a wrapper for L<HTML::Packer>, L<JavaScript::Packer> and L<CSS::Packer>.

=cut

has html => (
    is => 'lazy',
    builder => sub { HTML::Packer->init },
);

has js => (
    is => 'lazy',
    builder => sub { JavaScript::Packer->init },
);

has css => (
    is => 'lazy',
    builder => sub { CSS::Packer->init },
);


=func minify

B<Synopsis:> C<<< minify( $type, $text, $args ) >>>

Minifies the content of C<$text> and returns it.

    $html = minify(html => $html, {  });

Hint: C<$args> is a HashRef.

C<$type> must be one of:

=over 4

=cut

register minify => sub {
    my ($dsl, $what, $text, $args) = @_;
    return unless defined $text;
    $args //= {};
    return $dsl->_minify_js  ($text, $args) if $what eq 'js';
    return $dsl->_minify_css ($text, $args) if $what eq 'css';
    return $dsl->_minify_html($text, $args) if $what eq 'html';
    $dsl->error("unknown engine: $what");
}, { is_global => 1 };


=item * html

Minifies HTML. Allowed options for C<$args>:

=over 4

=item * remove_comments

Remove all HTML comments. Defaults to true.

=item * remove_newlines

Remove ALL newlines. Defaults to true.

=item * js_compress

Compress level for JavaScript. Defaults to I<best>.

=item * css_compress

Compress level for CSS. Defaults to I<minify>.

=back

See also L<HTML::Packer>.

=cut

sub _minify_html {
    my ($dsl, $html, $args) = @_;
    my $cfg = plugin_setting;
    my $remove_comments = $cfg->{remove_comments} // $args->{remove_comments} // 1;
    my $remove_newlines = $cfg->{remove_newlines} // $args->{remove_newlines} // 1;
    my $js_compress = $cfg->{js_compress} // $args->{js_compress} // 'best';
    my $css_compress = $cfg->{css_compress} // $args->{css_compress} // 'minify';
    my $html5 = $cfg->{html5} // $args->{html5} // 1;
    $dsl->html->minify(\$html, {
        remove_comments => $remove_comments,
        remove_newlines => $remove_newlines,
        do_javascript => $js_compress,
        do_stylesheet => $css_compress,
        html5 => 1,
    });
    return $html;
}

=item * js

Minifies JavaScript. Allowed options for C<$args>:

=over 4

=item * compress

Compress level. Defaults to I<best>.

Hint: the global keyword in the plugin settings is named I<js_compress>.

=back

See also L<JavaScript::Packer>.

=cut

sub _minify_js {
    my ($dsl, $js, $args) = @_;
    my $cfg = plugin_setting;
    my $comress = $cfg->{js_compress} // $args->{compress} // 'best';
    $dsl->js->minify(\$js, {
        compress => $comress,
    });
    return $js;
}

=item * js

Minifies CSS. Allowed options for C<$args>:

=over 4

=item * compress

Compress level. Defaults to I<minify>.

Hint: the global keyword in the plugin settings is named I<css_compress>.

=back

See also L<CSS::Packer>.

=cut

sub _minify_css {
    my ($dsl, $css, $args) = @_;
    my $cfg = plugin_setting;
    my $comress = $cfg->{css_compress} // $args->{compress} // 'minify';
    $dsl->css->minify(\$css, {
        compress => $comress,
    });
    return $css;
}

=back

All mentioned keywords above also apply to the plugin settings in your Dancer2 environment.

=cut

register_plugin;

1;
