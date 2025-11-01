-- CreateTable
CREATE TABLE "weekly_content" (
    "id" TEXT NOT NULL,
    "user_id" TEXT NOT NULL,
    "week" INTEGER NOT NULL,
    "title" TEXT,
    "highlights" JSONB,
    "facts" JSONB,
    "thingsToDo" JSONB,
    "content" JSONB,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "expires_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "weekly_content_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "weekly_content_user_id_idx" ON "weekly_content"("user_id");

-- CreateIndex
CREATE INDEX "weekly_content_week_idx" ON "weekly_content"("week");

-- CreateIndex
CREATE INDEX "weekly_content_expires_at_idx" ON "weekly_content"("expires_at");

-- CreateIndex
CREATE UNIQUE INDEX "weekly_content_user_id_week_key" ON "weekly_content"("user_id", "week");

-- AddForeignKey
ALTER TABLE "weekly_content" ADD CONSTRAINT "weekly_content_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;
