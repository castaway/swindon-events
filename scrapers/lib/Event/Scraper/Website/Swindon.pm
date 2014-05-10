package Event::Scraper::Website::Swindon;

use strict;
use warnings;

sub venues {
    my $known_venues = {
        '<unknown>' => {
            name => 'Unknown',
            street => '<Missing>',
            city => 'Swindon',
            zip => '<Missing>',
            country => 'United Kingdom',
        },
        'Arts Centre' => {
            name => 'Swindon Arts Centre',
            latitude => 51.551723,
            longitude => -1.777257,
            street => 'Devizes Road',
            city => 'Swindon',
            zip => 'SN1 4BJ',
            country => 'United Kingdom',
        },
        'Town Gardens' => {
            name => 'Old Town Gardens Bowl',
            latitude => 51.55105,
            longitude => -1.78219,
            street => 'Quarry Road',
            city => 'Swindon',
            zip => 'SN1 4PP',
            country => 'United Kingdom',
        },
        'Central Library' => {
            name => 'Swindon Central Library',
            latitude => 51.55859,
            longitude => -1.78129,
            street => 'Regent Street',
            city => 'Swindon',
            zip => 'SN1 1QG',
            country => 'United Kingdom',
        },
        'Swindon Museum and Art Gallery' => {
            name => 'Swindon Museum and Art Gallery',
            latitude => 51.5527232,
            longitude => -1.7776537,
            street => 'Bath Road',
            city => 'Swindon',
            zip => 'SN1 4BA',
            country => 'United Kingdom',
            other_names => ['Museum & Art Gallery'],
        },
        'STEAM Museum' => {
            name => 'STEAM Museum',
            latitude => 51.56286,
            longitude => -1.79493,
            street => 'Kemble Drive',
            city => 'Swindon',
            zip => 'SN2 2TA',
            country => 'United Kingdom',
            other_names => ['STEAM'],
        },
        'Lydiard House and Park' => {
            name => 'Lydiard House and Park',
	    # Given lat/lon is of the house proper
            latitude => 51.56138,
            longitude => -1.85164,
            street => 'Lydiard Tregoze',
            city => 'Swindon',
            zip => 'SN5 3PA',
            country => 'United Kingdom',
            other_names => ['Lydiard House'],
        },
        'Coate Water' => {
            name => 'Coate Water Country Park',
	    # The main car park
            latitude => 51.54299,
            longitude => -1.74620,
            street => 'Marlborough Road',
            city => 'Swindon',
            zip => 'SN3 6AA',
            country => 'United Kingdom',
        },
        'Croft Leisure Centre' => {
            name => 'Croft Leisure Centre',
            # The main car park.
            latitude => 51.54610,
            longitude => -1.77496,
            street => 'Marlborough Lane',
            city => 'Swindon',
            zip => 'SN3 1RA',
            country => 'United Kingdom',
        },
        'Lawn Woods' => {
            # Lawn Woods, High Street Old Town SN1 3EN
            # The entrance to the park on High Street
            latitude => 51.5519251,
            longitude => -1.7739015,
            street => 'High Street',
            name => 'Lawn Woods',
            city => 'Swindon',
            zip => 'SN1 3EN',
            country => 'United Kingdom',
        },
        'Lower Shaw Farm' => {
            latitude => 51.56972,
            longitude => -1.83593,
            name => 'Lower Shaw Farm',
            street => 'Old Shaw Lane',
            city => 'Swindon',
            zip => ' SN5 5PJ',
            country => 'United Kingdom',
        },
        'Richard Jefferies Museum' => {
            # Richard Jefferies Museum, Marlborough Road, Coate. Swindon SN3 6AA
            latitude => 51.54472,
            longitude => -1.74388,
            street => 'Marlborough Road',
            name => 'Lower Shaw Farm',
            city => 'Swindon',
            zip => 'SN3 6AA',
            country => 'United Kingdom',
        },
        'Highworth Library' => {
            # Highworth Library Brewery Street SN6 7AJ
            latitude => 51.6297414,
            longitude => -1.7097024,
            name => 'Highworth Library',
            street => 'Brewery Street',
            city => 'Swindon',
            zip => 'SN6 7AJ',
            country => 'United Kingdom',
        },
        'Cakes & Ale' => {
            # Cakes & Ale, Café Bar, 1–3 Devizes Road SN1 4BJ
            latitude => 51.552201,
            longitude => -1.777019,
            street => 'Devizes Road',
            name => 'Cakes & Ale',
            city => 'Swindon',
            zip => 'SN1 4BJ',
            country => 'United Kingdom',
            other_names => ['Cakes and Ale'],
        },
        'Wroughton Library' => {
            # Wroughton Library, Ellendune Centre SN4 9LT
            latitude => 51.52397,
            longitude => -1.79149,
            street => 'Devizes Road',
            name => 'Wroughton Library',
            city => 'Swindon',
            zip => 'SN4 9LT',
            country => 'United Kingdom',
        },
        'Swindon Town Hall' => {
            # Town Hall, Regent Circus SN1 1QG
            latitude => 51.5585746,
            longitude => -1.7814805,
            street => 'Regent Circus',
            name => 'Swindon Town Hall',
            city => 'Swindon',
            zip => 'SN1 1QG',
            country => 'United Kingdom',
            other_names => ['Town Hall'],
        },
    };

    return $known_venues;
}

sub find_venue {
    my ($class, $str) = @_;

    my $venues = venues();
    foreach my $name (keys %$venues) {
        if(($venues->{$name}{other_names} && 
            grep { $str =~ /$_/i} @{$venues->{$name}{other_names}}) 
           || $str =~ /$name/) {
            return $venues->{$name};
        }
    }
    return undef;
}

1;
