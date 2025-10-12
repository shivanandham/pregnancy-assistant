-- CreateTable
CREATE TABLE "pregnancy_tips" (
    "id" TEXT NOT NULL,
    "week" INTEGER NOT NULL,
    "tip" TEXT NOT NULL,
    "category" TEXT NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "expires_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "pregnancy_tips_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "checklist_completions" (
    "id" TEXT NOT NULL,
    "checklist_item_id" TEXT NOT NULL,
    "completed_at" TIMESTAMP(3) NOT NULL,
    "date" TIMESTAMP(3) NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "checklist_completions_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "pregnancy_tips_week_idx" ON "pregnancy_tips"("week");

-- CreateIndex
CREATE INDEX "pregnancy_tips_expires_at_idx" ON "pregnancy_tips"("expires_at");

-- CreateIndex
CREATE INDEX "checklist_completions_date_idx" ON "checklist_completions"("date");

-- CreateIndex
CREATE INDEX "checklist_completions_checklist_item_id_idx" ON "checklist_completions"("checklist_item_id");

-- CreateIndex
CREATE UNIQUE INDEX "checklistItemId_date" ON "checklist_completions"("checklist_item_id", "date");
