-- migrate:up
-- With this we can customize the id of the migration in Electric
CALL electric.migration_version('20230924100310');

CREATE TABLE "todolist" (
    "id" TEXT NOT NULL,
    "filter" TEXT,
    "editing" TEXT,
    PRIMARY KEY ("id")
);

ALTER TABLE todolist ENABLE ELECTRIC;

-- migrate:down