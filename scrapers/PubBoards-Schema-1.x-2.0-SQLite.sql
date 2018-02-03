-- Convert schema './PubBoards-Schema-1.x-SQLite.sql' to './PubBoards-Schema-2.0-SQLite.sql':;

BEGIN;

CREATE TABLE "oscodes" (
  "code" varchar(8) NOT NULL,
  "latitude" float NOT NULL,
  "longitude" float NOT NULL,
  PRIMARY KEY ("code")
);


COMMIT;


