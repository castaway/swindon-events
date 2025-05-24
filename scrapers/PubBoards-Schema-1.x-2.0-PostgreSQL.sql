-- Convert schema './PubBoards-Schema-1.x-PostgreSQL.sql' to './PubBoards-Schema-2.0-PostgreSQL.sql':;

BEGIN;

CREATE TABLE "oscodes" (
  "code" character varying(8) NOT NULL,
  "latitude" numeric NOT NULL,
  "longitude" numeric NOT NULL,
  PRIMARY KEY ("code")
);


COMMIT;


