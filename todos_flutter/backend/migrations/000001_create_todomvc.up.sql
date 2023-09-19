CREATE TABLE "todolist" (
    "id" TEXT NOT NULL,
    "filter" TEXT,
    "editing" TEXT,
    PRIMARY KEY ("id")
);

CREATE TABLE "todo" (
    "id" TEXT NOT NULL,
    "listid" TEXT,
    "text" TEXT,
    "edited_at" TIMESTAMPTZ NOT NULL,
    "completed" INTEGER DEFAULT 0 NOT NULL,
    PRIMARY KEY ("id")
  );
