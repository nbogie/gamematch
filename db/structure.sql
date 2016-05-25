CREATE TABLE "games" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "name" text, "game_id" integer, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL);
CREATE UNIQUE INDEX "index_games_on_game_id" ON "games" ("game_id");
CREATE TABLE "players" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "bgg_username" text, "bgg_user_id" text, "meetup_username" text, "meetup_link" text, "meetup_status" text, "meetup_joined" text, "meetup_user_id" integer, "meetup_bio" text, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL, "last_collection_request_time" datetime);
CREATE UNIQUE INDEX "index_players_on_meetup_user_id" ON "players" ("meetup_user_id");
CREATE TABLE "schema_migrations" ("version" varchar NOT NULL);
CREATE UNIQUE INDEX "unique_schema_migrations" ON "schema_migrations" ("version");
CREATE TABLE "ownerships" ("game_id" integer, "meetup_user_id" integer, "text" varchar, "created_at" datetime, "updated_at" datetime);
CREATE TABLE "play_wishes" ("game_id" integer, "meetup_user_id" integer, "text" varchar, "created_at" datetime, "updated_at" datetime);
INSERT INTO schema_migrations (version) VALUES ('20160524180403');

INSERT INTO schema_migrations (version) VALUES ('20160524180603');

INSERT INTO schema_migrations (version) VALUES ('20160525005508');

INSERT INTO schema_migrations (version) VALUES ('20160525020724');

INSERT INTO schema_migrations (version) VALUES ('20160525031548');

