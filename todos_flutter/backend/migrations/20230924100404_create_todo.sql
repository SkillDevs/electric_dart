-- migrate:up
-- With this we can customize the id of the migration in Electric
CALL electric.migration_version('20230924100404');

CREATE TABLE "todo" (
    "id" TEXT NOT NULL,
    "listid" TEXT,
    "text" TEXT,
    "completed" INTEGER NOT NULL,
    "edited_at" TIMESTAMPTZ NOT NULL,
    PRIMARY KEY ("id")
);

ALTER TABLE todo ENABLE ELECTRIC;

-- migrate:down
