package Event::Scraper::Manual;
use strictures 1;
use DateTime;
use Data::Dump::Streamer 'Dump';

use base 'Event::Scraper::Website::Swindon';

## Manually added events from single websites:

sub get_events {

    ## http://www.visitwiltshire.co.uk/whats-on/swindon-pride-festival-p461513 
    ## http://www.nj-allstars.com/dates
    ## Add (more) contact info?
    ## should probably sort by start_time after!
    return [
        {
            event_genre => 'Sport',
            event_desc => "Street Athletics\n Registration 12-1pm, Races 1-3pm",
            event_name => 'Street Athletics',
            event_url => 'http://www.streetathletics.co.uk/StreetAthletics/swindon-2014/',
            start_time => DateTime->new(year => 2014, month => 6, day => 14, hour => 12, minute => 0),
            end_time => DateTime->new(year => 2014, month => 6, day => 14, hour => 3, minute => 0),
            venue => __PACKAGE__->venues()->{'Wharf Green'},
        },
        {
            event_genre => 'Festival',
            event_desc => q{Welcome to "The 1st Awesome Swindon Chilli Fiesta 2014" planned to be a awesome day of chilli mayhem. Don't expect hot bogs, chips or even burgers, we are about chilli, so if you want go from one part of the universe to another on chilli power thats is exactly what will happen.},
            event_name => 'Chilli Fiesta',
            event_url => 'http://www.chillifest.net/swindon-chilli-fiesta/4581651818',
            start_time => DateTime->new(year => 2014, month => 7, day => 19, hour => 10, minute => 30),
            end_time => DateTime->new(year => 2014, month => 7, day => 19, hour => 5, minute => 30),
            venue => __PACKAGE__->venues()->{'Wharf Green'},
        },
        {
            event_genre => 'Sport',
            event_desc => q{The Swindon Sports Forum is fortunate enough to be able to deliver a Clubs Showcase event at Wharf Green, Swindon, during the Commonwealth Games 2014. This has been made possible due to funding the Swindon Sports Forum has been granted. Times TBC.},
            event_name => 'Commonwealth Games - Opening Ceremony',
            event_url => 'http://www.vas-swindon.org.uk/news/1031/22/Commonwealth-Games-Club-Showcase/',
            start_time => DateTime->new(year => 2014, month => 7, day => 23, hour => 10, minute => 00),
            venue => __PACKAGE__->venues()->{'Wharf Green'},
        },
        {
            event_genre => 'Sport',
            event_desc => q{The Swindon Sports Forum is fortunate enough to be able to deliver a Clubs Showcase event at Wharf Green, Swindon, during the Commonwealth Games 2014. This has been made possible due to funding the Swindon Sports Forum has been granted. Times TBC.},
            event_name => 'Commonwealth Games - Showcase',
            event_url => 'http://www.vas-swindon.org.uk/news/1031/22/Commonwealth-Games-Club-Showcase/',
            start_time => DateTime->new(year => 2014, month => 7, day => 24, hour => 0, minute => 0),
            end_time => DateTime->new(year => 2014, month => 8, day => 2, hour => 23, minute => 0),
            venue => __PACKAGE__->venues()->{'Wharf Green'},
        },
        {
            event_genre => 'Sport',
            event_desc => q{The Swindon Sports Forum is fortunate enough to be able to deliver a Clubs Showcase event at Wharf Green, Swindon, during the Commonwealth Games 2014. This has been made possible due to funding the Swindon Sports Forum has been granted. Times TBC.},
            event_name => 'Commonwealth Games - Closing Ceremony',
            event_url => 'http://www.vas-swindon.org.uk/news/1031/22/Commonwealth-Games-Club-Showcase/',
            start_time => DateTime->new(year => 2014, month => 8, day => 3, hour => 10, minute => 0),
            venue => __PACKAGE__->venues()->{'Wharf Green'},
        },
        # {
        #     event_genre => 'Music',
        #     event_desc => q{Placeholder! No idea if this is running in Swindon this year. Please send info if you know anything.},
        #     event_name => 'Our Big Gig',
        #     event_url => 'http://www.superact.org.uk/ourbiggig/our-big-gig-2014',
        #     start_time => DateTime->new(year => 2014, month => 7, day => 11, hour => 10, minute => 0),
        #     end_time => DateTime->new(year => 2014, month => 7, day => 13, hour => 10, minute => 0),
        #     venue => __PACKAGE__->venues()->{'Wharf Green'},
        # },
        {
            event_genre => 'Music',
            event_desc => q{Our Big Gig - Savernake Street Social Hall},
            event_name => 'Our Big Gig - Savenake Street',
            event_url => 'http://www.superact.org.uk/ourbiggig/component/obg_events/173?view=obgevent&Itemid=483',
            start_time => DateTime->new(year => 2014, month => 7, day => 13, hour => 12, minute => 0),
            end_time => DateTime->new(year => 2014, month => 7, day => 13, hour => 17, minute => 0),
            venue => __PACKAGE__->venues()->{'Savernake Street Social Hall'},
        },
        {
            event_genre => 'Music',
            event_desc => q{Our Big Gig - Highworth Community Centre\n0 - 1pm Instrument Creation Workshop (Junk Percussion!),

11 - 12.30 Electronic Musical Instrument Discovery (Tablets, soundbeam etc…),

1pm - 2pm Drum Circle,

2 - 5pm Jamming,

2 - 5pm Jigs and reels with Monday Evening Session Society,

2 - 5pm Open Band rehearsals,

2 - 6pm Circus skills, slack-lining and other skills based physical activities outside, 

2 - 5pm Fire sculpture creation (to be lit as the audience leaves the venue).
},
            event_name => 'Our Big Gig',
            event_url => 'http://www.superact.org.uk/ourbiggig/component/obg_events/326?view=obgevent&Itemid=483',
            start_time => DateTime->new(year => 2014, month => 7, day => 12, hour => 10, minute => 0),
            end_time => DateTime->new(year => 2014, month => 7, day => 12, hour => 21, minute => 0),
            venue => __PACKAGE__->venues()->{'Highworth Community Centre'},
        },
        {
            event_genre => 'Roadshow',
            event_desc => q{Diabetes UK Roadshow},
            event_name => 'Diabetes UK Roadshow',
            event_url => 'http://www.diabetes.org.uk/Events_in_full/Roadshows/Roadshow---South-West/?print=2',
            start_time => DateTime->new(year => 2014, month => 7, day => 10, hour => 9, minute => 0),
            end_time => DateTime->new(year => 2014, month => 7, day => 10, hour => 17, minute => 0),
            venue => __PACKAGE__->venues()->{'Wharf Green'},
        },
        {
            event_genre => 'Roadshow',
            event_desc => q{Diabetes UK Roadshow},
            event_name => 'Diabetes UK Roadshow',
            event_url => 'http://www.diabetes.org.uk/Events_in_full/Roadshows/Roadshow---South-West/?print=2',
            start_time => DateTime->new(year => 2014, month => 7, day => 11, hour => 9, minute => 0),
            end_time => DateTime->new(year => 2014, month => 7, day => 11, hour => 16, minute => 30),
            venue => __PACKAGE__->venues()->{'Wharf Green'},
        },
        ];
}

1;
