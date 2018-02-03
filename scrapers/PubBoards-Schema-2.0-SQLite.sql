-- 
-- Created by SQL::Translator::Producer::SQLite
-- Created on Sat Feb  3 12:42:27 2018
-- 

BEGIN TRANSACTION;

--
-- Table: acts
--
DROP TABLE acts;

CREATE TABLE acts (
  id INTEGER PRIMARY KEY NOT NULL,
  name varchar(255) NOT NULL,
  description text
);

--
-- Table: oscodes
--
DROP TABLE oscodes;

CREATE TABLE oscodes (
  code varchar(8) NOT NULL,
  latitude float NOT NULL,
  longitude float NOT NULL,
  PRIMARY KEY (code)
);

--
-- Table: siteusers
--
DROP TABLE siteusers;

CREATE TABLE siteusers (
  id INTEGER PRIMARY KEY NOT NULL,
  user_token varchar(36),
  user_name varchar(255) NOT NULL,
  display_name varchar(255) NOT NULL,
  description text,
  preferences varchar(3096) NOT NULL DEFAULT '{}',
  created_on datetime NOT NULL
);

CREATE UNIQUE INDEX token ON siteusers (user_token);

--
-- Table: venues
--
DROP TABLE venues;

CREATE TABLE venues (
  id varchar(255) NOT NULL,
  name varchar(255) NOT NULL,
  url_name varchar(255) NOT NULL,
  url varchar(1024),
  osm_type varchar(20) NOT NULL DEFAULT 'node',
  osm_id varchar(20),
  latitude float,
  longitude float,
  address text,
  last_verified datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  has_live_music boolean NOT NULL DEFAULT 0,
  has_quiz boolean NOT NULL DEFAULT 0,
  has_tea_and_coffee boolean NOT NULL DEFAULT 0,
  has_sports_tv boolean NOT NULL DEFAULT 0,
  has_real_ale boolean NOT NULL DEFAULT 0,
  has_food boolean NOT NULL DEFAULT 0,
  has_wifi boolean NOT NULL DEFAULT 0,
  is_outside boolean NOT NULL DEFAULT 0,
  PRIMARY KEY (id)
);

CREATE UNIQUE INDEX name ON venues (name);

CREATE UNIQUE INDEX url_name ON venues (url_name);

--
-- Table: events
--
DROP TABLE events;

CREATE TABLE events (
  id varchar(1024) NOT NULL,
  unique_id INTEGER PRIMARY KEY NOT NULL,
  name varchar(255) NOT NULL,
  description text,
  venue_id varchar(255),
  url varchar(1024),
  created_on datetime,
  FOREIGN KEY (venue_id) REFERENCES venues(id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE INDEX events_idx_venue_id ON events (venue_id);

CREATE UNIQUE INDEX event_id ON events (id);

--
-- Table: images
--
DROP TABLE images;

CREATE TABLE images (
  id varchar(255) NOT NULL,
  source varchar(255) NOT NULL,
  owner varchar(255) NOT NULL,
  description varchar(1024) NOT NULL,
  title varchar(255),
  original_date datetime,
  tags varchar(255) NOT NULL,
  url_thumbnail varchar(1024),
  url_image varchar(1024) NOT NULL,
  url_linkback varchar(1024) NOT NULL,
  sign_text varchar(255),
  venue_id varchar(255),
  processed_on datetime,
  verified_on datetime,
  PRIMARY KEY (id),
  FOREIGN KEY (venue_id) REFERENCES venues(id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE INDEX images_idx_venue_id ON images (venue_id);

CREATE UNIQUE INDEX url ON images (url_linkback);

--
-- Table: social_users
--
DROP TABLE social_users;

CREATE TABLE social_users (
  user_id integer NOT NULL,
  identity_token varchar(36) NOT NULL,
  user_name varchar(255),
  display_name varchar(255),
  provider varchar(255) NOT NULL,
  image_url varchar(1024),
  profile_url varchar(1024),
  linked_on datetime NOT NULL,
  PRIMARY KEY (identity_token),
  FOREIGN KEY (user_id) REFERENCES siteusers(id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE INDEX social_users_idx_user_id ON social_users (user_id);

--
-- Table: event_categories
--
DROP TABLE event_categories;

CREATE TABLE event_categories (
  event_id integer NOT NULL,
  name varchar(255) NOT NULL,
  PRIMARY KEY (event_id, name),
  FOREIGN KEY (event_id) REFERENCES events(unique_id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE INDEX event_categories_idx_event_id ON event_categories (event_id);

--
-- Table: times
--
DROP TABLE times;

CREATE TABLE times (
  event_id varchar(255) NOT NULL,
  time_key varchar(255) NOT NULL DEFAULT '_XX_',
  start_time datetime NOT NULL,
  end_time datetime,
  all_day boolean NOT NULL DEFAULT 0,
  PRIMARY KEY (event_id, start_time),
  FOREIGN KEY (event_id) REFERENCES events(id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE INDEX times_idx_event_id ON times (event_id);

CREATE UNIQUE INDEX time_key ON times (time_key);

--
-- Table: act_events
--
DROP TABLE act_events;

CREATE TABLE act_events (
  event_id varchar(255) NOT NULL,
  act_id integer NOT NULL,
  position integer,
  PRIMARY KEY (event_id, act_id),
  FOREIGN KEY (act_id) REFERENCES acts(id) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (event_id) REFERENCES events(id)
);

CREATE INDEX act_events_idx_act_id ON act_events (act_id);

CREATE INDEX act_events_idx_event_id ON act_events (event_id);

--
-- Table: starred_events
--
DROP TABLE starred_events;

CREATE TABLE starred_events (
  user_id integer NOT NULL,
  event_id varchar(255) NOT NULL,
  notes text,
  starred_on datetime NOT NULL,
  PRIMARY KEY (user_id, event_id),
  FOREIGN KEY (event_id) REFERENCES times(time_key) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (user_id) REFERENCES siteusers(id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE INDEX starred_events_idx_event_id ON starred_events (event_id);

CREATE INDEX starred_events_idx_user_id ON starred_events (user_id);

COMMIT;

