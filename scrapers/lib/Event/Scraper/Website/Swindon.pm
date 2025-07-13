package Event::Scraper::Website::Swindon;

use strict;
use warnings;

use Text::Unidecode;
## For those moments when an apostrophe turns out to be U+2019 RIGHT
## SINGLE QUOTATION MARK ...
sub venues {
    my $known_venues = {
        '<unknown>' => {
            name => 'Unknown',
            street => '<Missing>',
            city => 'Swindon',
            zip => '<Missing>',
            country => 'United Kingdom',
            other_names => [],
        },
        'Moulden Hill Country Park' => {
            name => 'Moulden Hill Country Park',
            street => '<Missing>',
            city => 'Swindon',
            zip => '<Missing>',
            country => 'United Kingdom',
            other_names => ['Moulden Hill','Mouldon Hill'],
            latitude => '51.587585',
            longitude => '-1.831494',
            flags => {
                is_outside => 1,
            },
        },
        'County Ground' => {
            name => 'Swindon Town Football Club',
            street => 'County Road',
            city => 'Swindon',
            zip => 'SN1 2ED',
            country => 'United Kingdom',
            latitude => '51.564488',
            longitude => '-1.771077',
        },
        'Civic Offices' => {
            name => 'Civic Offices',
            street => 'Euclid Street',
            city => 'Swindon',
            zip => 'SN1 2JH',
            country => 'United Kingdom',
            latitude => '51.5595345',
            longitude => '-1.7791844',
        },
        'Barbury Castle' => {
            name => 'Barbury Castle',
            street => 'The Ridgeway Trail',
            city => 'Swindon',
            zip => 'SN4 0QT',
            country => 'United Kingdom',
#            other_names => [],
            flags => {
                is_outside => 1,
                has_food => 1,
                has_tea_and_coffee => 1,
            },
            latitude => '51.485014',
            longitude => '-1.786294',
        },
        "Queen's Park" => {
            name => "Queen's Park",
            street => 'Drove Road',
            city => 'Swindon',
            zip => 'SN1',
            country => 'United Kingdom',
#            other_names => [],
            flags => {
                is_outside => 1,
            },
            latitude => '51.557146',
            longitude => '-1.776072',
        },
        'Arts Centre' => {
            name => 'Swindon Arts Centre',
            latitude => 51.551723,
            longitude => -1.777257,
            street => 'Devizes Road',
            city => 'Swindon',
            zip => 'SN1 4BJ',
            country => 'United Kingdom',
            flags => {
                has_food => 1,
                has_tea_and_coffee => 1,
                has_wifi => 1,
            },
        },
        'Town Gardens Bandstand' => {
            name => 'Old Town Gardens Bandstand',
            latitude => 51.55105,
            longitude => -1.78219,
            street => 'Quarry Road',
            city => 'Swindon',
            zip => 'SN1 4PP',
            country => 'United Kingdom',
            other_names => ['Town Gardens Band Stand', 'Town Gardens Bandstand'],
            flags => {
                is_outside => 1,
            },
        },
        'Town Gardens' => {
            name => 'Old Town Gardens Bowl',
            latitude => 51.55105,
            longitude => -1.78219,
            street => 'Quarry Road',
            city => 'Swindon',
            zip => 'SN1 4PP',
            country => 'United Kingdom',
            flags => {
                is_outside => 1,
            },
            other_names => ['Town Gardens Bowl', 'Old Town Bowl, Swindon'],
        },
        'Central Library' => {
            name => 'Swindon Central Library',
            latitude => 51.55859,
            longitude => -1.78129,
            street => 'Regent Street',
            city => 'Swindon',
            zip => 'SN1 1QG',
            country => 'United Kingdom',
            flags => {
                has_food => 1,
                has_tea_and_coffee => 1,
                has_wifi => 1,
            },
        },
        'Swindon Museum and Art Gallery' => {
            name => 'Swindon Museum and Art Gallery',
            latitude => 51.5527232,
            longitude => -1.7776537,
            street => 'Bath Road',
            city => 'Swindon',
            zip => 'SN1 4BA',
            country => 'United Kingdom',
            other_names => ['Museum & Art Gallery', 'smag'],
        },
        'Steam - Museum of the Great Western Railway' => {
            name => 'Steam - Museum of the Great Western Railway',
            latitude => 51.56286,
            longitude => -1.79493,
            street => 'Kemble Drive',
            city => 'Swindon',
            zip => 'SN2 2TA',
            country => 'United Kingdom',
            other_names => ['STEAM', 'The Steam Museum', 'STEAM Museum'],
            flags => {
                has_food => 1,
                has_tea_and_coffee => 1,
            },
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
            other_names => ['Lydiard House', 'Lydiard Park', 'Lydiard Park Open Air Theatre'],
            flags => {
                has_food => 1,
                has_tea_and_coffee => 1,
                is_outside => 1,
            },
        },
        'Lydiard Conference Centre' => {
            name => 'Lydiard Conference Centre',
	    # Given lat/lon is of the house proper
            latitude => 51.56138,
            longitude => -1.85164,
            street => 'Lydiard Tregoze',
            city => 'Swindon',
            zip => 'SN5 3PA',
            country => 'United Kingdom',
            other_names => ['Lydiard Park Conference Centre'],
            flags => {
                has_food => 1,
                has_tea_and_coffee => 1,
                is_outside => 1,
            },
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
            flags => {
                has_food => 1,
                has_tea_and_coffee => 1,
                is_outside => 1,
            },
            other_names => ['Coate Water'],
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
            other_names => ['Croft Sports Centre'],
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
            flags => {
                is_outside => 1,
            },
            other_names => ['The Lawns'],
        },
        'Lower Shaw Farm' => {
            latitude => 51.56972,
            longitude => -1.83593,
            name => 'Lower Shaw Farm',
            street => 'Old Shaw Lane',
            city => 'Swindon',
            zip => 'SN5 5PJ',
            country => 'United Kingdom',
        },
        'Richard Jefferies Museum' => {
            # Richard Jefferies Museum, Marlborough Road, Coate. Swindon SN3 6AA
            latitude => 51.54472,
            longitude => -1.74388,
            street => 'Marlborough Road',
            name => 'Richard Jefferies Museum',
            city => 'Swindon',
            zip => 'SN3 6AA',
            country => 'United Kingdom',
            flags => {
                has_food => 1,
                has_tea_and_coffee => 1,
            },
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
            flags => {
                has_food => 1,
                has_tea_and_coffee => 1,
                has_wifi => 1,
            },
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
        'The Theatre, Swindon Dance' => {
            # The Theatre, Swindon Dance, Regent Circus, Swindon, SN1 1QF
            latitude => 51.5585746,
            longitude => -1.7814805,
            street => 'Regent Circus',
            name => 'Swindon Dance Theatre',
            city => 'Swindon',
            zip => 'SN1 1QF',
            country => 'United Kingdom',
            other_names => ['Swindon Dance'],
        },
        'Stanton Park' => {
            latitude => 51.6075954,
            longitude => -1.7442645,
            street => 'The Ave, Stanton Fitzwarren',
            name => 'Stanton Country Park',
            city => 'Swindon',
            zip => 'SN6 7SD',
            country => 'United Kingdom',
            other_names => ['Stanton Park'],
            url => 'http://www.swindon.gov.uk/lc/lc-parks/lc-parks-list/pages/lc-parks-list-stanton.aspx',
            flags => {
                has_food => 1,
                has_tea_and_coffee => 1,
                is_outside => 1,
            },
        },
        'Wharf Green' => {
            latitude => 51.560091,
            longitude => -1.787403,
            street => 'Canal Walk',
            name => 'Wharf Green',
            city => 'Swindon',
            zip => 'SN1 1RZ', ## or 1LD ?
            country => 'United Kingdom',
            other_names => ['Big Screen'],
            #url => '',
            flags => {
                is_outside => 1,
            },
        },
        'Savernake Street Social Hall' => {
#            latitude => 51.560091,
#            longitude => -1.787403,
            street => 'Savernake Street',
            name => 'Savernake Street Social Hall',
            city => 'Swindon',
            zip => 'SN1 3LZ',
            country => 'United Kingdom',
            #other_names => [''],
            #url => '',
        },
        'Highworth Community Centre' => {
#            latitude => 51.560091,
#            longitude => -1.787403,
            street => 'The Dormers',
            name => 'Highworth Community Centre',
            city => 'Swindon',
            zip => 'SN6 7PQ',
            country => 'United Kingdom',
            #other_names => [''],
            #url => '',
        },
        'Highworth Recreation Centre' => {
#            latitude => 51.560091,
#            longitude => -1.787403,
            street => 'The Elms',
            name => 'Highworth Recreation Centre',
            city => 'Swindon',
            zip => 'SN6 7DD',
            country => 'United Kingdom',
            other_names => ['Lower rec'],
            url => 'http://highworthrec.co.uk',
        },
        'Artsite & the Post Modern' => {
# Artsite & the Post Modern     Theatre Square    Swindon    SN1 1QN
            street => 'Theatre Square',
            name => 'Artsite & the Post Modern',
            city => 'Swindon',
            zip  => 'SN1 1QN',
            country => 'United Kingdom',
            other_names => ['Artsite', 'Post Modern'],
            latitude => '51.559342',
            longitude => -1.781091,
        },
        'Artsite at Number Nine Gallery' => {
# Artsite & the Post Modern     Theatre Square    Swindon    SN1 1QN
            street => 'Theatre Square',
            name => 'Artsite at Number Nine Gallery',
            city => 'Swindon',
            zip  => 'SN1 1QN',
            country => 'United Kingdom',
            other_names => ['Number Nine'],
        },
        'Wyvern Theatre' => {
            name => 'Wyvern Theatre',
            street => 'Theatre Square',
            city => 'Swindon',
            zip => 'SN1 1QN',
            country => 'United Kingdom',
            other_names => ['Wyvern Theatre Main Auditorium', 'Wyvern Main Auditorium', 'https://www.swindontheatres.co.uk'],
            url => 'http://www.swindontheatres.co.uk',
            latitude => 51.559758,
            longitude => -1.781163,
        },
        'Wyvern Restaurant' => {
            name => 'Wyvern Restaurant, Wyvern Threatre',
            street => 'Theatre Square',
            city => 'Swindon',
            zip => 'SN1 1QN',
            country => 'United Kingdom',
#            other_names => ['Wyvern Theatre Main Auditorium', 'https://www.swindontheatres.co.uk', 'Wyvern Restaurant'],
            url => 'http://www.swindontheatres.co.uk',
            latitude => 51.559758,
            longitude => -1.781163,
        },
        'The Spotlight Room' => {
            name => 'The Spotlight Room, Wyvern Threatre',
            street => 'Theatre Square',
            city => 'Swindon',
            zip => 'SN1 1QN',
            country => 'United Kingdom',
#            other_names => ['Wyvern Theatre Main Auditorium', 'https://www.swindontheatres.co.uk', 'Wyvern Restaurant'],
            url => 'http://www.swindontheatres.co.uk',
            latitude => 51.559758,
            longitude => -1.781163,
        },
        'Vu:Du' => {
            name => 'Vu:Du',
            street => 'Victoria road',
            city => 'Swindon',
            zip => 'SN1 3BD',
            country => 'United Kingdom',
#            other_names => [],
            latitude => 51.556414,
            longitude => -1.778827,
        },
        'TWIGS Community Gardens' => {
            name => 'TWIGS Community Gardens',
            street => 'Cheney Manor Road',
            city => 'Swindon',
            zip => 'SN2 2QJ',
            country => 'United Kingdom',
            url => '',
            latitude => 51.577012,
            longitude => -1.80248,
        },
        'Commonweal School' => { 
            name => 'Commonweal School',
            street => 'The Mall',
            city => 'Swindon',
            zip => 'SN1 4JE',
            country => 'United Kingdom',
            url => 'http://commonweal.co.uk',
            latitude => '51.549815',
            longitude => '-1.789458',
        },
        'Phoenix Theatre' => {
            name => 'Phoenix Theatre',
            street => 'New College Drive, Queen\'s Drive',
            city => 'Swindon',
            zip => 'SN3 1AH',
            country => 'United Kingdom',
            url => 'http://www.newcollege.ac.uk/wp/venue-hire/venue/business-phoenix-theatre/',
            other_names => ['The Phoenix Theatre at New College'],
            latitude => 51.557614,
            longitude => -1.758239,
        },
        'Oasis Leisure Centre' => {
            name => 'Oasis Leisure Centre',
            street => 'North Star Avenue',
            city => 'Swindon',
            zip => 'SN2 1EP',
            country => 'United Kingdom',
            url => 'http://www.better.org.uk/leisure/oasis-leisure-centre-swindon',
            other_names => ['Oasis'],
            latitude => 51.567322,
            longitude => -1.790742,
        },
        "St Joseph's Catholic College" => {
            name => "St Joseph's Catholic College",
            street => 'Octal Way',
            city => 'Swindon',
            zip => 'SN3 3LR',
            country => 'United Kingdom',
            url => 'http://www.stjosephs.swindon.sch.uk/',
            latitude => 51.564541,
            longitude => -1.764799,
        },
        'Grange Drive Community Centre' => {
            name => 'Grange Drive Community Centre',
            street => 'Grange Drive',
            city => 'Swindon',
            zip => 'SN3 4JY',
            country => 'United Kingdom',
            latitude => 51.5792471,
            longitude => -1.7457461,
            other_names => ['Grange Leisure Centre Recreation Ground']
        },
        'Rat Trap' => {
            name => 'Rat Trap',
            street => 'Highworth Road',
            city => 'Swindon',
            zip => 'SN3 4QS',
            country => 'United Kingdom',
            latitude => 51.588719,
            longitude => -1.748462,
        },
        'Savernake Forest' => {
            name => 'Savernake Forest',
            street => '',
            city => 'Marlborough',
            zip => 'SN8',
            country => 'United Kingdom',
            latitude => 51.3974998,
            longitude => -1.6942036,
        },
        'The Rolleston' => {
            name => 'The Rolleston',
            street => '73 Commercial Road',
            city => 'Swindon',
            zip => 'SN1 5NX',
            country => 'United Kingdom',
        },
        'Kingshill Landing Stage' => {
            name => 'Kingshill Landing Stage',
            street => 'Behind Esso Garage',
            city => 'Swindon',
            zip => 'SN1 4NG',
            country => 'United Kingdom',
            url => 'http://www.wbct.org.uk/boat-trips/locations/873',
            other_names => ['Kingshill'],
        },
        'Waitrose, Swindon' => {
            name => 'Waitrose, Swindon',
            street => 'Mill Lane',
            city => 'Swindon',
            zip => 'SN1 7BX',
            country => 'United Kingdom',
            url => 'http://waitrose.com',
            other_names => ['Waitrose'],
        },
        'Lotmead Farm' => {
            name => 'Lotmead Farm',
            street => '',
            city => 'Swindon',
            zip => 'SN4 0SN',
            country => 'United Kingdom',
            url => 'http://www.lotmeadfarm.co.uk',
            other_names => ['Lotmead'],
        },
        'Swindon Rugby Football Club' => {
            name => 'Swindon Rugby Football Club',
            street => 'Greenbridge Road',
            city => 'Swindon',
            zip => 'SN3 3LA',
            country => 'United Kingdom',
            url => 'www.pitchero.com/clubs/swindonrfc/',
            other_names => ['Swindon RFC'],
        },
        'East Wichel Community Centre' => {
            name => 'East Wichel Community Centre',
            street => 'Staldone Road',
            city => 'Swindon',
            zip => '',
            country => 'United Kingdom',
            url => 'thestoweaway.org.uk/',
            other_names => ['StoweAway'],
        },
        'Swindon and Cricklade Heritage Railway' => {
            name => 'Swindon and Cricklade Heritage Railway',
            street => 'Tadpole Lane',
            zip => 'SN25 2DA',
            city => 'Swindon',
            country => 'United Kingdom',
            url => 'http://www.swindon-cricklade-railway.org/',
            other_names => ['Swindon and Cricklade Railway'],
        },
        'The Beehive' => {
            name => 'The Beehive',
            street => '55 Prospect Hill',
            zip => 'SN1 3JS',
            city => 'Swindon',
            country => 'United Kingdom',
            url => 'http://www.bee-hive.co.uk',
            other_names => ['Beehive'],
        },
        'The Platform' => {
            name => 'The Platform',
            street => 'Faringdon Road',
            zip => 'SN1 5BJ',
            city => 'Swindon',
            country => 'United Kingdom',
        },
        'The Sun Inn' => {
            name => 'The Sun Inn',
            street => 'Faringdon Road',
            zip => 'SN3 6AA',
            city => 'Coate',
            country => 'United Kingdom',
            other_names => ['Sun Inn'],
        },
        'Twigs' => {
            name => 'Twigs Community Gardens',
            street => 'Cheney Manor',
            zip => 'SN2 2QJ',
            city => 'Swindon',
            country => 'United Kingdom',
            other_names => ['Twigs'],
        },
        'Even Swindon Community Centre', => {
            name => 'Even Swindon Community Centre',
            street => 'Summers Street',
            zip => 'SN2 2HA',
            city => 'Swindon',
            country => 'United Kingdom',
        },
        'Cineworld Regent Circus' => {
            name => 'Cineworld Regent Circus',
            street => 'Victoria Road',
            zip => 'SN1 1FA',
            city => 'Swindon',
            country => 'United Kingdom',
        },
        'Empire Greenbridge' => {
            name => 'Empire Greenbridge',
            street => 'Greenbridge Retail Park, Drakes Way',
            zip => 'SN3 3EY',
            city => 'Swindon',
            country => 'United Kingdom',
        },
        'Cineworld Shaw Ridge' => {
            name => 'Cineworld Shaw Ridge',
            street => 'Shaw Ridge Leisure Park, Whitehill Way',
            zip => 'SN5 7DN',
            city => 'Swindon',
            country => 'United Kingdom',
        },
        'Shoebox Theatre' => {
            name => 'Shoebox Theatre',
            street => 'Theatre Square',
            zip => 'SN1 1QN',
            city => 'Swindon',
            country => 'United Kingdom',
            other_names => ['Shoe Box Theatre'],
        },
        'The Palladium' => {
            name => 'The Palladium',
            street => 'Jennings Street',
            zip => 'SN2 2BD',
            city => 'Swindon',
            country => 'United Kingdom',
            other_names => ['Bohemian Balcony'],
        },
        'Central Community Centre' => {
            name => 'Central Community Centre',
            street => 'Emlyn Square',
            zip => 'SN1 5BP',
            city => 'Swindon',
            country => 'United Kingdom',
        },
        'The Tuppenny' => {
            name => 'The Tuppenny',
            street => 'Devizes Road',
            zip => 'SN1 4BD',
            city => 'Swindon',
            country => 'United Kingdom',
        },
        'West Swindon Library' => {
            name => 'West Swindon Library',
            street => 'Whitehill Way',
            zip => 'SN5 7DL',
            city => 'Swindon',
            country => 'United Kingdom',
        },
        'The Hop Inn' => {
            name => 'The Hop Inn',
            street => '8 Devizes Road',
            zip => 'SN1 4BH',
            city => 'Swindon',
            country => 'United Kingdom',
        },
        'Create Studios' => {
            name => 'Create Studios',
            street => 'London Street',
            # street => '10 Carriage Works, London Street',
            zip => 'SN1 5FB',
            city => 'Swindon',
            country => 'United Kingdom',
        },
            # Meadowcroft Community Centre
            # St. Marks Recreation Ground, Whitehouse Rd, Swindon SN2 1DB
            # St Marks Tennis Courts
            # The Tawny Owl Swindon
            # 88 Victoria Road, SN1 3BD Swindon, United Kingdom (the victoria?)
            # The Castle Old Town Swindon
            # 54 Godwin Court, SN1 4BB Swindon, United Kingdom (Bert's books?)
            # Immanuel United Reformed Church
            # High Street, Swindon, SN6 7, United Kingdom
     };

    return $known_venues;
}

## Given a set of strings which may be a venue name, find/return the
## matching venue hashref

sub find_venue {
    my ($class, @strings) = @_;

    my $venues = venues();
    foreach my $name (sort { length($b) <=> length($a) } keys %$venues) {
        foreach my $str (@strings) {
            next if !$str;
            $str = unidecode($str);
            if(($venues->{$name}{other_names} && 
                  grep { $str =~ /$_/i} @{$venues->{$name}{other_names}}) 
               || $str =~ /$name/i) {
                return $venues->{$name};
            }
        }
    }
    return undef;
}

## Given a chunk of text which may or may not contain a venue
## name/url, find/return the matching venue hashref
sub extract_venue {
    my ($class, $desc) = @_;;

    ## Get all venue names/urls, sort by longest first:
    my %all_names = (map { 
        my $ven = $_; ($ven->{name} => $ven, 
                       ( $ven->{url} ? ($ven->{url} => $ven) : () ),
                       map { $_ => $ven } (@{ $ven->{other_names} || [] }) ) }
                     values (%{ venues() }) );
    $all_names{$_} = venues()->{$_} for keys (%{ venues() });
    foreach my $name (sort { length($b) <=> length($a) } keys %all_names) {
        return $all_names{$name} if($desc =~ /$name/i);
    }

    return undef;
}
1;
