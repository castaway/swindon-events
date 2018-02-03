-- 
-- Created by SQL::Translator::Producer::MySQL
-- Created on Sat Feb  3 12:42:26 2018
-- 
SET foreign_key_checks=0;

DROP TABLE IF EXISTS acts;

--
-- Table: acts
--
CREATE TABLE acts (
  id integer NOT NULL auto_increment,
  name varchar(255) NOT NULL,
  description text NULL,
  PRIMARY KEY (id)
) ENGINE=InnoDB;

DROP TABLE IF EXISTS oscodes;

--
-- Table: oscodes
--
CREATE TABLE oscodes (
  code varchar(8) NOT NULL,
  latitude float NOT NULL,
  longitude float NOT NULL,
  PRIMARY KEY (code)
);

DROP TABLE IF EXISTS siteusers;

--
-- Table: siteusers
--
CREATE TABLE siteusers (
  id integer NOT NULL auto_increment,
  user_token varchar(36) NULL,
  user_name varchar(255) NOT NULL,
  display_name varchar(255) NOT NULL,
  description text NULL,
  preferences text NOT NULL DEFAULT '{}',
  created_on datetime NOT NULL,
  PRIMARY KEY (id),
  UNIQUE token (user_token)
) ENGINE=InnoDB;

DROP TABLE IF EXISTS venues;

--
-- Table: venues
--
CREATE TABLE venues (
  id varchar(255) NOT NULL,
  name varchar(255) NOT NULL,
  url_name varchar(255) NOT NULL,
  url text NULL,
  osm_type varchar(20) NOT NULL DEFAULT 'node',
  osm_id varchar(20) NULL,
  latitude float NULL,
  longitude float NULL,
  address text NULL,
  last_verified datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  has_live_music enum('0','1') NOT NULL DEFAULT '0',
  has_quiz enum('0','1') NOT NULL DEFAULT '0',
  has_tea_and_coffee enum('0','1') NOT NULL DEFAULT '0',
  has_sports_tv enum('0','1') NOT NULL DEFAULT '0',
  has_real_ale enum('0','1') NOT NULL DEFAULT '0',
  has_food enum('0','1') NOT NULL DEFAULT '0',
  has_wifi enum('0','1') NOT NULL DEFAULT '0',
  is_outside enum('0','1') NOT NULL DEFAULT '0',
  PRIMARY KEY (id),
  UNIQUE name (name),
  UNIQUE url_name (url_name)
) ENGINE=InnoDB;

DROP TABLE IF EXISTS events;

--
-- Table: events
--
CREATE TABLE events (
  id text NOT NULL,
  unique_id integer NOT NULL auto_increment,
  name varchar(255) NOT NULL,
  description text NULL,
  venue_id varchar(255) NULL,
  url text NULL,
  created_on datetime NULL,
  INDEX events_idx_venue_id (venue_id),
  PRIMARY KEY (unique_id),
  UNIQUE event_id (id),
  CONSTRAINT events_fk_venue_id FOREIGN KEY (venue_id) REFERENCES venues (id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

DROP TABLE IF EXISTS images;

--
-- Table: images
--
CREATE TABLE images (
  id varchar(255) NOT NULL,
  source varchar(255) NOT NULL,
  owner varchar(255) NOT NULL,
  description text NOT NULL,
  title varchar(255) NULL,
  original_date datetime NULL,
  tags varchar(255) NOT NULL,
  url_thumbnail text NULL,
  url_image text NOT NULL,
  url_linkback text NOT NULL,
  sign_text varchar(255) NULL,
  venue_id varchar(255) NULL,
  processed_on datetime NULL,
  verified_on datetime NULL,
  INDEX images_idx_venue_id (venue_id),
  PRIMARY KEY (id),
  UNIQUE url (url_linkback),
  CONSTRAINT images_fk_venue_id FOREIGN KEY (venue_id) REFERENCES venues (id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

DROP TABLE IF EXISTS social_users;

--
-- Table: social_users
--
CREATE TABLE social_users (
  user_id integer NOT NULL auto_increment,
  identity_token varchar(36) NOT NULL,
  user_name varchar(255) NULL,
  display_name varchar(255) NULL,
  provider varchar(255) NOT NULL,
  image_url text NULL,
  profile_url text NULL,
  linked_on datetime NOT NULL,
  INDEX social_users_idx_user_id (user_id),
  PRIMARY KEY (identity_token),
  CONSTRAINT social_users_fk_user_id FOREIGN KEY (user_id) REFERENCES siteusers (id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

DROP TABLE IF EXISTS event_categories;

--
-- Table: event_categories
--
CREATE TABLE event_categories (
  event_id integer NOT NULL,
  name varchar(255) NOT NULL,
  INDEX event_categories_idx_event_id (event_id),
  PRIMARY KEY (event_id, name),
  CONSTRAINT event_categories_fk_event_id FOREIGN KEY (event_id) REFERENCES events (unique_id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

DROP TABLE IF EXISTS times;

--
-- Table: times
--
CREATE TABLE times (
  event_id varchar(255) NOT NULL,
  time_key varchar(255) NOT NULL DEFAULT '_XX_',
  start_time datetime NOT NULL,
  end_time datetime NULL,
  all_day enum('0','1') NOT NULL DEFAULT '0',
  INDEX times_idx_event_id (event_id),
  PRIMARY KEY (event_id, start_time),
  UNIQUE time_key (time_key),
  CONSTRAINT times_fk_event_id FOREIGN KEY (event_id) REFERENCES events (id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

DROP TABLE IF EXISTS act_events;

--
-- Table: act_events
--
CREATE TABLE act_events (
  event_id varchar(255) NOT NULL,
  act_id integer NOT NULL,
  position integer NULL,
  INDEX act_events_idx_act_id (act_id),
  INDEX act_events_idx_event_id (event_id),
  PRIMARY KEY (event_id, act_id),
  CONSTRAINT act_events_fk_act_id FOREIGN KEY (act_id) REFERENCES acts (id) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT act_events_fk_event_id FOREIGN KEY (event_id) REFERENCES events (id)
) ENGINE=InnoDB;

DROP TABLE IF EXISTS starred_events;

--
-- Table: starred_events
--
CREATE TABLE starred_events (
  user_id integer NOT NULL auto_increment,
  event_id varchar(255) NOT NULL,
  notes text NULL,
  starred_on datetime NOT NULL,
  INDEX starred_events_idx_event_id (event_id),
  INDEX starred_events_idx_user_id (user_id),
  PRIMARY KEY (user_id, event_id),
  CONSTRAINT starred_events_fk_event_id FOREIGN KEY (event_id) REFERENCES times (time_key) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT starred_events_fk_user_id FOREIGN KEY (user_id) REFERENCES siteusers (id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

SET foreign_key_checks=1;


