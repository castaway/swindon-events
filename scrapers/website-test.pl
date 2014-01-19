#!/usr/bin/perl
use strictures 1;
use Data::Dump::Streamer 'Dump', 'Dumper';
use lib 'lib';
use Event::Scraper::Website;


print Dumper(Event::Scraper::Website->get_events({
                                                  name => 'Beehive',
                                                  type => 'Venue',
                                                  plugin => 'Website',
                                                  format => 'Beehive',
                                                  page => "http://www.bee-hive.co.uk/pfs.mhtml?eng_no=0&override=true&mode=search&count-num=110376",
                                                 }));
