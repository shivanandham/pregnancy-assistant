-- CreateTable
CREATE TABLE "daily_checklist_items" (
    "id" TEXT NOT NULL,
    "user_id" TEXT NOT NULL,
    "task" TEXT NOT NULL,
    "category" TEXT NOT NULL,
    "week" INTEGER,
    "trimester" INTEGER,
    "frequency" TEXT NOT NULL DEFAULT 'daily',
    "important" BOOLEAN NOT NULL DEFAULT false,
    "personalized" BOOLEAN NOT NULL DEFAULT false,
    "date" TIMESTAMP(3) NOT NULL,
    "expires_at" TIMESTAMP(3) NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "daily_checklist_items_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "daily_checklist_items_user_id_idx" ON "daily_checklist_items"("user_id");

-- CreateIndex
CREATE INDEX "daily_checklist_items_date_idx" ON "daily_checklist_items"("date");

-- CreateIndex
CREATE INDEX "daily_checklist_items_expires_at_idx" ON "daily_checklist_items"("expires_at");

-- CreateIndex
CREATE UNIQUE INDEX "daily_checklist_items_user_id_date_task_key" ON "daily_checklist_items"("user_id", "date", "task");

-- AddForeignKey
ALTER TABLE "daily_checklist_items" ADD CONSTRAINT "daily_checklist_items_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;
