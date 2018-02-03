-- Convert schema './PubBoards-Schema-1.x-MySQL.sql' to 'PubBoards::Schema v2.0':;

BEGIN;

SET foreign_key_checks=0;

CREATE TABLE oscodes (
  code varchar(8) NOT NULL,
  latitude float NOT NULL,
  longitude float NOT NULL,
  PRIMARY KEY (code)
);

SET foreign_key_checks=1;

ALTER TABLE events CHANGE COLUMN id id text NOT NULL,
                   CHANGE COLUMN url url text NULL;

ALTER TABLE images CHANGE COLUMN description description text NOT NULL,
                   CHANGE COLUMN url_thumbnail url_thumbnail text NULL,
                   CHANGE COLUMN url_image url_image text NOT NULL,
                   CHANGE COLUMN url_linkback url_linkback text NOT NULL;

ALTER TABLE siteusers CHANGE COLUMN preferences preferences text NOT NULL DEFAULT '{}';

ALTER TABLE social_users CHANGE COLUMN image_url image_url text NULL,
                         CHANGE COLUMN profile_url profile_url text NULL;

ALTER TABLE times CHANGE COLUMN all_day all_day enum('0','1') NOT NULL DEFAULT '0';

ALTER TABLE venues CHANGE COLUMN url url text NULL,
                   CHANGE COLUMN has_live_music has_live_music enum('0','1') NOT NULL DEFAULT '0',
                   CHANGE COLUMN has_quiz has_quiz enum('0','1') NOT NULL DEFAULT '0',
                   CHANGE COLUMN has_tea_and_coffee has_tea_and_coffee enum('0','1') NOT NULL DEFAULT '0',
                   CHANGE COLUMN has_sports_tv has_sports_tv enum('0','1') NOT NULL DEFAULT '0',
                   CHANGE COLUMN has_real_ale has_real_ale enum('0','1') NOT NULL DEFAULT '0',
                   CHANGE COLUMN has_food has_food enum('0','1') NOT NULL DEFAULT '0',
                   CHANGE COLUMN has_wifi has_wifi enum('0','1') NOT NULL DEFAULT '0',
                   CHANGE COLUMN is_outside is_outside enum('0','1') NOT NULL DEFAULT '0';


COMMIT;


