-- 
-- Created by SQL::Translator::Producer::PostgreSQL
-- Created on Tue Apr 25 19:05:58 2017
-- 
--
-- Table: acts
--
DROP TABLE acts CASCADE;
CREATE TABLE acts (
  id serial NOT NULL,
  name character varying(255) NOT NULL,
  description text,
  PRIMARY KEY (id)
);

--
-- Table: siteusers
--
DROP TABLE siteusers CASCADE;
CREATE TABLE siteusers (
  id serial NOT NULL,
  user_token character varying(36),
  user_name character varying(255) NOT NULL,
  display_name character varying(255) NOT NULL,
  description text,
  preferences character varying(3096) DEFAULT '{}' NOT NULL,
  created_on timestamp NOT NULL,
  PRIMARY KEY (id),
  CONSTRAINT token UNIQUE (user_token)
);

--
-- Table: venues
--
DROP TABLE venues CASCADE;
CREATE TABLE venues (
  id character varying(255) NOT NULL,
  name character varying(255) NOT NULL,
  url_name character varying(255) NOT NULL,
  url character varying(1024),
  osm_type character varying(20) DEFAULT 'node' NOT NULL,
  osm_id character varying(20),
  latitude numeric,
  longitude numeric,
  address text,
  last_verified timestamp DEFAULT CURRENT_TIMESTAMP NOT NULL,
  has_live_music boolean DEFAULT '0' NOT NULL,
  has_quiz boolean DEFAULT '0' NOT NULL,
  has_tea_and_coffee boolean DEFAULT '0' NOT NULL,
  has_sports_tv boolean DEFAULT '0' NOT NULL,
  has_real_ale boolean DEFAULT '0' NOT NULL,
  has_food boolean DEFAULT '0' NOT NULL,
  has_wifi boolean DEFAULT '0' NOT NULL,
  is_outside boolean DEFAULT '0' NOT NULL,
  PRIMARY KEY (id),
  CONSTRAINT name UNIQUE (name),
  CONSTRAINT url_name UNIQUE (url_name)
);

--
-- Table: events
--
DROP TABLE events CASCADE;
CREATE TABLE events (
  id character varying(1024) NOT NULL,
  unique_id serial NOT NULL,
  name character varying(255) NOT NULL,
  description text,
  venue_id character varying(255),
  url character varying(1024),
  created_on timestamp,
  PRIMARY KEY (unique_id),
  CONSTRAINT event_id UNIQUE (id)
);
CREATE INDEX events_idx_venue_id on events (venue_id);

--
-- Table: images
--
DROP TABLE images CASCADE;
CREATE TABLE images (
  id character varying(255) NOT NULL,
  source character varying(255) NOT NULL,
  owner character varying(255) NOT NULL,
  description character varying(1024) NOT NULL,
  title character varying(255),
  original_date timestamp,
  tags character varying(255) NOT NULL,
  url_thumbnail character varying(1024),
  url_image character varying(1024) NOT NULL,
  url_linkback character varying(1024) NOT NULL,
  sign_text character varying(255),
  venue_id character varying(255),
  processed_on timestamp,
  verified_on timestamp,
  PRIMARY KEY (id),
  CONSTRAINT url UNIQUE (url_linkback)
);
CREATE INDEX images_idx_venue_id on images (venue_id);

--
-- Table: social_users
--
DROP TABLE social_users CASCADE;
CREATE TABLE social_users (
  user_id serial NOT NULL,
  identity_token character varying(36) NOT NULL,
  user_name character varying(255),
  display_name character varying(255),
  provider character varying(255) NOT NULL,
  image_url character varying(1024),
  profile_url character varying(1024),
  linked_on timestamp NOT NULL,
  PRIMARY KEY (identity_token)
);
CREATE INDEX social_users_idx_user_id on social_users (user_id);

--
-- Table: event_categories
--
DROP TABLE event_categories CASCADE;
CREATE TABLE event_categories (
  event_id integer NOT NULL,
  name character varying(255) NOT NULL,
  PRIMARY KEY (event_id, name)
);
CREATE INDEX event_categories_idx_event_id on event_categories (event_id);

--
-- Table: times
--
DROP TABLE times CASCADE;
CREATE TABLE times (
  event_id character varying(255) NOT NULL,
  time_key character varying(255) DEFAULT '_XX_' NOT NULL,
  start_time timestamp NOT NULL,
  end_time timestamp,
  all_day boolean DEFAULT '0' NOT NULL,
  PRIMARY KEY (event_id, start_time),
  CONSTRAINT time_key UNIQUE (time_key)
);
CREATE INDEX times_idx_event_id on times (event_id);

--
-- Table: act_events
--
DROP TABLE act_events CASCADE;
CREATE TABLE act_events (
  event_id character varying(255) NOT NULL,
  act_id integer NOT NULL,
  position integer,
  PRIMARY KEY (event_id, act_id)
);
CREATE INDEX act_events_idx_act_id on act_events (act_id);
CREATE INDEX act_events_idx_event_id on act_events (event_id);

--
-- Table: starred_events
--
DROP TABLE starred_events CASCADE;
CREATE TABLE starred_events (
  user_id serial NOT NULL,
  event_id character varying(255) NOT NULL,
  notes text,
  starred_on timestamp NOT NULL,
  PRIMARY KEY (user_id, event_id)
);
CREATE INDEX starred_events_idx_event_id on starred_events (event_id);
CREATE INDEX starred_events_idx_user_id on starred_events (user_id);

--
-- Foreign Key Definitions
--

ALTER TABLE events ADD CONSTRAINT events_fk_venue_id FOREIGN KEY (venue_id)
  REFERENCES venues (id) ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

ALTER TABLE images ADD CONSTRAINT images_fk_venue_id FOREIGN KEY (venue_id)
  REFERENCES venues (id) ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

ALTER TABLE social_users ADD CONSTRAINT social_users_fk_user_id FOREIGN KEY (user_id)
  REFERENCES siteusers (id) ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

ALTER TABLE event_categories ADD CONSTRAINT event_categories_fk_event_id FOREIGN KEY (event_id)
  REFERENCES events (unique_id) ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

ALTER TABLE times ADD CONSTRAINT times_fk_event_id FOREIGN KEY (event_id)
  REFERENCES events (id) ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

ALTER TABLE act_events ADD CONSTRAINT act_events_fk_act_id FOREIGN KEY (act_id)
  REFERENCES acts (id) ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

ALTER TABLE act_events ADD CONSTRAINT act_events_fk_event_id FOREIGN KEY (event_id)
  REFERENCES events (id) DEFERRABLE;

ALTER TABLE starred_events ADD CONSTRAINT starred_events_fk_event_id FOREIGN KEY (event_id)
  REFERENCES times (time_key) ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

ALTER TABLE starred_events ADD CONSTRAINT starred_events_fk_user_id FOREIGN KEY (user_id)
  REFERENCES siteusers (id) ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;


