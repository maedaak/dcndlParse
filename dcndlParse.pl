#!/usr/bin/perl

use XML::Simple;

binmode(STDOUT, ":utf8");

local($/) = undef;
my $content = <>;
my $data = XMLin($content);

my $records = $data->{"ListRecords"}{"record"};
foreach my $record (@$records) {
    my $dc = $record->{"metadata"}{"dcndl_simple:dc"};
    my $parsed = parse_dc($dc);
    if (defined $parsed->{ISBN}[0] && defined $parsed->{"NDLC"}) {
        print "title:\t",     $parsed->{"title"}, "\n";
        print "creator:\t",   join "\t", @{$parsed->{"creator"}}, "\n";
        print "publisher:\t", join "\t", @{$parsed->{"publisher"}}, "\n";
        print "ISBN:\t",      join "\t", @{$parsed->{"ISBN"}}, "\n";
        #print "price:\t",     $parsed->{"price"}, "\n";
        print "NDLC:\t",      $parsed->{"NDLC"}, "\n";
        print "NDC9:\t",      $parsed->{"NDC9"}, "\n";
        print "\n";
    }
}

sub parse_dc {
    my $dc = shift;
    my %parse_dc;

    # Title
    $parse_dc{"title"} = $dc->{"dc:title"};

    # Creator
    $parse_dc{"creator"} = [];
    if (ref $dc->{"dc:creator"} eq "ARRAY") {
         $parse_dc{"creator"} = $dc->{"dc:creator"};
    }
    else {
         push @{$parse_dc{"creator"}}, $dc->{"dc:creator"};
    }

    # Publisher
    $parse_dc{"publisher"} = [];
    if (ref $dc->{"dc:publisher"} eq "ARRAY") {
        $parse_dc{"publisher"} = $dc->{"dc:publisher"};
    }
    else {
        push @{$parse_dc{"publisher"}}, $dc->{"dc:publisher"};
    }

    # Price
    $parse_dc = $dc->{"dcndl:price"};

    # ISBN
    $parse_dc{"ISBN"} = [];
    foreach $indentifer (@{$dc->{"dc:identifier"}}) {
        if ($indentifer->{"xsi:type"} eq "dcndl:ISBN") {
            push @{$parse_dc{"ISBN"}}, $indentifer->{"content"};
        }
    }

    # Subject
    $parse_dc{"subject"} = [];
    if (ref $dc->{"dc:subject"} eq "ARRAY"){
        foreach $indentifer (@{$dc->{"dc:subject"}}) {
            $parse_dc{"NDLC"}  = $indentifer->{"content"}
                if $indentifer->{"xsi:type"} eq "dcndl:NDLC";
            $parse_dc{"NDC9"}  = $indentifer->{"content"}
                if $indentifer->{"xsi:type"} eq "dcndl:NDC9";
        }
    }
    else {
        my $identifer = $dc->{"dc:subject"};
        $parse_dc{"NDLC"}  = $indentifer->{"content"}
             if $indentifer->{"xsi:type"} eq "dcndl:NDLC";
        $parse_dc{"NDC9"}  = $indentifer->{"content"}
            if $indentifer->{"xsi:type"} eq "dcndl:NDC9";
    }
    return \%parse_dc;
}