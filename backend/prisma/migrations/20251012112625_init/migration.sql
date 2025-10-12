-- CreateTable
CREATE TABLE "user_profiles" (
    "id" TEXT NOT NULL,
    "height" DOUBLE PRECISION,
    "weight" DOUBLE PRECISION,
    "pre_pregnancy_weight" DOUBLE PRECISION,
    "age" INTEGER,
    "gender" TEXT NOT NULL DEFAULT 'female',
    "locality" TEXT,
    "timezone" TEXT,
    "medical_history" JSONB,
    "allergies" JSONB,
    "medications" JSONB,
    "lifestyle" JSONB,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "user_profiles_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "chat_sessions" (
    "id" TEXT NOT NULL,
    "title" TEXT NOT NULL DEFAULT 'New Chat',
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "message_count" INTEGER NOT NULL DEFAULT 0,
    "is_active" BOOLEAN NOT NULL DEFAULT false,

    CONSTRAINT "chat_sessions_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "pregnancy_data" (
    "id" TEXT NOT NULL,
    "due_date" TIMESTAMP(3) NOT NULL,
    "last_menstrual_period" TIMESTAMP(3) NOT NULL,
    "notes" TEXT,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "pregnancy_data_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "symptoms" (
    "id" TEXT NOT NULL,
    "type" TEXT NOT NULL,
    "severity" TEXT NOT NULL,
    "date_time" TIMESTAMP(3) NOT NULL,
    "notes" TEXT,
    "custom_type" TEXT,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "symptoms_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "appointments" (
    "id" TEXT NOT NULL,
    "title" TEXT NOT NULL,
    "type" TEXT NOT NULL,
    "date_time" TIMESTAMP(3) NOT NULL,
    "location" TEXT,
    "doctor" TEXT,
    "notes" TEXT,
    "is_completed" BOOLEAN NOT NULL DEFAULT false,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "appointments_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "weight_entries" (
    "id" TEXT NOT NULL,
    "weight" DOUBLE PRECISION NOT NULL,
    "date_time" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "notes" TEXT,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "weight_entries_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "chat_messages" (
    "id" TEXT NOT NULL,
    "content" TEXT NOT NULL,
    "type" TEXT NOT NULL,
    "timestamp" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "context" TEXT,
    "is_error" BOOLEAN NOT NULL DEFAULT false,
    "is_diagnostic" BOOLEAN NOT NULL DEFAULT false,
    "diagnostic_questions" JSONB,
    "diagnostic_answers" JSONB,
    "parent_message_id" TEXT,
    "session_id" TEXT,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "chat_messages_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "knowledge_facts" (
    "id" TEXT NOT NULL,
    "category" TEXT NOT NULL,
    "fact_text" TEXT NOT NULL,
    "source_message_id" TEXT,
    "week_number" INTEGER,
    "date_recorded" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "metadata" JSONB,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "knowledge_facts_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "conversation_chunks" (
    "id" TEXT NOT NULL,
    "content" TEXT NOT NULL,
    "week_number" INTEGER,
    "timestamp" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "keywords" TEXT,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "conversation_chunks_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "symptoms_date_time_idx" ON "symptoms"("date_time");

-- CreateIndex
CREATE INDEX "appointments_date_time_idx" ON "appointments"("date_time");

-- CreateIndex
CREATE INDEX "weight_entries_date_time_idx" ON "weight_entries"("date_time");

-- CreateIndex
CREATE INDEX "chat_messages_timestamp_idx" ON "chat_messages"("timestamp");

-- CreateIndex
CREATE INDEX "chat_messages_session_id_idx" ON "chat_messages"("session_id");

-- CreateIndex
CREATE INDEX "knowledge_facts_category_idx" ON "knowledge_facts"("category");

-- CreateIndex
CREATE INDEX "knowledge_facts_week_number_idx" ON "knowledge_facts"("week_number");

-- CreateIndex
CREATE INDEX "conversation_chunks_week_number_idx" ON "conversation_chunks"("week_number");

-- AddForeignKey
ALTER TABLE "chat_messages" ADD CONSTRAINT "chat_messages_session_id_fkey" FOREIGN KEY ("session_id") REFERENCES "chat_sessions"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "chat_messages" ADD CONSTRAINT "chat_messages_parent_message_id_fkey" FOREIGN KEY ("parent_message_id") REFERENCES "chat_messages"("id") ON DELETE SET NULL ON UPDATE CASCADE;
