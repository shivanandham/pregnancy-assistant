--
-- PostgreSQL database dump
--

-- Dumped from database version 14.17 (Homebrew)
-- Dumped by pg_dump version 14.17 (Homebrew)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: _prisma_migrations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public._prisma_migrations (
    id character varying(36) NOT NULL,
    checksum character varying(64) NOT NULL,
    finished_at timestamp with time zone,
    migration_name character varying(255) NOT NULL,
    logs text,
    rolled_back_at timestamp with time zone,
    started_at timestamp with time zone DEFAULT now() NOT NULL,
    applied_steps_count integer DEFAULT 0 NOT NULL
);


ALTER TABLE public._prisma_migrations OWNER TO postgres;

--
-- Name: appointments; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.appointments (
    id text NOT NULL,
    user_id text NOT NULL,
    title text NOT NULL,
    type text NOT NULL,
    date_time timestamp(3) without time zone NOT NULL,
    location text,
    doctor text,
    notes text,
    is_completed boolean DEFAULT false NOT NULL,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL
);


ALTER TABLE public.appointments OWNER TO postgres;

--
-- Name: chat_messages; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.chat_messages (
    id text NOT NULL,
    content text NOT NULL,
    type text NOT NULL,
    "timestamp" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    context text,
    is_error boolean DEFAULT false NOT NULL,
    is_diagnostic boolean DEFAULT false NOT NULL,
    diagnostic_questions jsonb,
    diagnostic_answers jsonb,
    parent_message_id text,
    session_id text,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.chat_messages OWNER TO postgres;

--
-- Name: chat_sessions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.chat_sessions (
    id text NOT NULL,
    user_id text NOT NULL,
    title text DEFAULT 'New Chat'::text NOT NULL,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL,
    message_count integer DEFAULT 0 NOT NULL,
    is_active boolean DEFAULT false NOT NULL
);


ALTER TABLE public.chat_sessions OWNER TO postgres;

--
-- Name: checklist_completions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.checklist_completions (
    id text NOT NULL,
    checklist_item_id text NOT NULL,
    completed_at timestamp(3) without time zone NOT NULL,
    date timestamp(3) without time zone NOT NULL,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL
);


ALTER TABLE public.checklist_completions OWNER TO postgres;

--
-- Name: conversation_chunks; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.conversation_chunks (
    id text NOT NULL,
    content text NOT NULL,
    week_number integer,
    "timestamp" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    keywords text,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.conversation_chunks OWNER TO postgres;

--
-- Name: knowledge_facts; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.knowledge_facts (
    id text NOT NULL,
    category text NOT NULL,
    fact_text text NOT NULL,
    source_message_id text,
    week_number integer,
    date_recorded timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    metadata jsonb,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.knowledge_facts OWNER TO postgres;

--
-- Name: pregnancy_data; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.pregnancy_data (
    id text NOT NULL,
    user_id text NOT NULL,
    due_date timestamp(3) without time zone NOT NULL,
    last_menstrual_period timestamp(3) without time zone NOT NULL,
    notes text,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL
);


ALTER TABLE public.pregnancy_data OWNER TO postgres;

--
-- Name: pregnancy_tips; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.pregnancy_tips (
    id text NOT NULL,
    week integer NOT NULL,
    tip text NOT NULL,
    category text NOT NULL,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    expires_at timestamp(3) without time zone NOT NULL
);


ALTER TABLE public.pregnancy_tips OWNER TO postgres;

--
-- Name: symptoms; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.symptoms (
    id text NOT NULL,
    user_id text NOT NULL,
    type text NOT NULL,
    severity text NOT NULL,
    date_time timestamp(3) without time zone NOT NULL,
    notes text,
    custom_type text,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.symptoms OWNER TO postgres;

--
-- Name: user_profiles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_profiles (
    id text NOT NULL,
    user_id text NOT NULL,
    height double precision,
    weight double precision,
    pre_pregnancy_weight double precision,
    age integer,
    gender text DEFAULT 'female'::text NOT NULL,
    locality text,
    timezone text,
    medical_history jsonb,
    allergies jsonb,
    medications jsonb,
    lifestyle jsonb,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL
);


ALTER TABLE public.user_profiles OWNER TO postgres;

--
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    id text NOT NULL,
    firebase_uid text NOT NULL,
    email text NOT NULL,
    display_name text,
    photo_url text,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL
);


ALTER TABLE public.users OWNER TO postgres;

--
-- Name: weight_entries; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.weight_entries (
    id text NOT NULL,
    user_id text NOT NULL,
    weight double precision NOT NULL,
    date_time timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    notes text,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.weight_entries OWNER TO postgres;

--
-- Data for Name: _prisma_migrations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public._prisma_migrations (id, checksum, finished_at, migration_name, logs, rolled_back_at, started_at, applied_steps_count) FROM stdin;
339551e2-1d64-4a27-a506-ba874ef48883	80e1f013910b9f38da99938d8d8e1e4403eb19afcf827e848c0e0452ec5e60a0	2025-11-01 12:37:12.338476+05:30	20251101123543_init		\N	2025-11-01 12:37:12.338476+05:30	0
\.


--
-- Data for Name: appointments; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.appointments (id, user_id, title, type, date_time, location, doctor, notes, is_completed, created_at, updated_at) FROM stdin;
dbf51100-cefa-4676-80c9-fd009f608bee	257f38ba-274d-4d6c-a29b-5109f84ae9d8	ajj	prenatal	2025-10-22 09:43:00	\N	\N	\N	f	2025-10-20 09:43:51.683	2025-10-20 09:43:51.683
\.


--
-- Data for Name: chat_messages; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.chat_messages (id, content, type, "timestamp", context, is_error, is_diagnostic, diagnostic_questions, diagnostic_answers, parent_message_id, session_id, created_at) FROM stdin;
2420c0cd-0cda-44df-861b-79cdccb79f71	hi	user	2025-10-20 09:31:09.142	Week 8	f	f	\N	\N	\N	880120f7-afb3-4ce8-9f03-a020cbacf4e6	2025-10-20 09:31:09.142
14d648c1-8318-4bfc-b01d-6755a6912ba4	hi	user	2025-10-20 09:34:48.118	Week 8	f	f	\N	\N	\N	880120f7-afb3-4ce8-9f03-a020cbacf4e6	2025-10-20 09:34:48.118
045fe699-576d-4050-9a73-e94b86656363	To better help you, I'd like to ask a few questions:\n\n1. Hello! How can I help you today?\n\nPlease answer these questions so I can provide you with the most helpful advice.	assistant	2025-10-20 09:34:53	Week 7	f	t	["Hello! How can I help you today?"]	\N	14d648c1-8318-4bfc-b01d-6755a6912ba4	880120f7-afb3-4ce8-9f03-a020cbacf4e6	2025-10-20 09:34:53.001
57f864eb-f781-4daa-8aad-23abe104a8fe	Sorry, I encountered an error. Please try again later.	assistant	2025-10-20 09:34:53.008	\N	t	f	\N	\N	\N	880120f7-afb3-4ce8-9f03-a020cbacf4e6	2025-10-20 09:34:53.008
35d92fb5-9b82-4efc-862c-d34c54402159	vomit	user	2025-10-20 09:36:56.913	Week 8	f	f	\N	\N	\N	01cb5680-2f5c-4857-bf0a-1dc08abc6ed1	2025-10-20 09:36:56.913
8818558d-c17a-4761-aea5-20ce3b29dbce	To better help you, I'd like to ask a few questions:\n\n1. I'm sorry to hear you're feeling unwell. Can you tell me a bit more about your vomiting? How often are you vomiting, and when did it start?\n2. Are you able to keep any fluids or food down, or does everything come back up?\n3. Are you experiencing any other symptoms along with the vomiting, such as dizziness, fever, or abdominal pain?\n\nPlease answer these questions so I can provide you with the most helpful advice.	assistant	2025-10-20 09:37:03.378	Week 7	f	t	["I'm sorry to hear you're feeling unwell. Can you tell me a bit more about your vomiting? How often are you vomiting, and when did it start?", "Are you able to keep any fluids or food down, or does everything come back up?", "Are you experiencing any other symptoms along with the vomiting, such as dizziness, fever, or abdominal pain?"]	\N	35d92fb5-9b82-4efc-862c-d34c54402159	01cb5680-2f5c-4857-bf0a-1dc08abc6ed1	2025-10-20 09:37:03.38
d53af406-88d9-4d80-af3a-8f219737efb6	Sorry, I encountered an error. Please try again later.	assistant	2025-10-20 09:37:03.396	\N	t	f	\N	\N	\N	01cb5680-2f5c-4857-bf0a-1dc08abc6ed1	2025-10-20 09:37:03.396
cf3724d4-4178-4e09-aefe-bac21eea0fbb	hi	user	2025-10-20 09:40:56.722	Week 8	f	f	\N	\N	\N	9c2dc641-ce91-42ca-b5e1-6773dbbac971	2025-10-20 09:40:56.722
797b72ac-9005-42fb-9fae-007c3bf116c2	To better help you, I'd like to ask a few questions:\n\n1. Welcome back! You previously mentioned you were experiencing vomiting. To help me understand better, could you please tell me: How often are you vomiting, and when did it start?\n2. Are you able to keep any fluids or food down, or does everything come back up?\n3. Are you experiencing any other symptoms along with the vomiting, such as dizziness, fever, or abdominal pain?\n\nPlease answer these questions so I can provide you with the most helpful advice.	assistant	2025-10-20 09:41:02.752	Week 7	f	t	["Welcome back! You previously mentioned you were experiencing vomiting. To help me understand better, could you please tell me: How often are you vomiting, and when did it start?", "Are you able to keep any fluids or food down, or does everything come back up?", "Are you experiencing any other symptoms along with the vomiting, such as dizziness, fever, or abdominal pain?"]	\N	cf3724d4-4178-4e09-aefe-bac21eea0fbb	9c2dc641-ce91-42ca-b5e1-6773dbbac971	2025-10-20 09:41:02.754
7d9cd4d3-c11b-4d46-a6e3-c6de9ee181e7	headache	user	2025-10-20 09:43:20.651	Week 8	f	f	\N	\N	\N	9c2dc641-ce91-42ca-b5e1-6773dbbac971	2025-10-20 09:43:20.651
b26538a8-19f5-41d0-b399-0339a2fddedb	To better help you, I'd like to ask a few questions:\n\n1. To help me understand better, can you describe your headache? For example, is it a dull ache, throbbing, or a sharp pain? Where is the pain located?\n2. How severe is the pain on a scale of 1 to 10, where 1 is very mild and 10 is the worst pain you've ever experienced?\n3. How long have you had this headache, and are you experiencing any other symptoms along with it, such as changes in vision, dizziness, or fever?\n\nPlease answer these questions so I can provide you with the most helpful advice.	assistant	2025-10-20 09:43:25.816	Week 7	f	t	["To help me understand better, can you describe your headache? For example, is it a dull ache, throbbing, or a sharp pain? Where is the pain located?", "How severe is the pain on a scale of 1 to 10, where 1 is very mild and 10 is the worst pain you've ever experienced?", "How long have you had this headache, and are you experiencing any other symptoms along with it, such as changes in vision, dizziness, or fever?"]	\N	7d9cd4d3-c11b-4d46-a6e3-c6de9ee181e7	9c2dc641-ce91-42ca-b5e1-6773dbbac971	2025-10-20 09:43:25.817
\.


--
-- Data for Name: chat_sessions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.chat_sessions (id, user_id, title, created_at, updated_at, message_count, is_active) FROM stdin;
880120f7-afb3-4ce8-9f03-a020cbacf4e6	257f38ba-274d-4d6c-a29b-5109f84ae9d8	New Chat	2025-10-20 09:31:09.139	2025-10-20 09:41:49.64	3	f
01cb5680-2f5c-4857-bf0a-1dc08abc6ed1	257f38ba-274d-4d6c-a29b-5109f84ae9d8	Vomit	2025-10-20 09:36:51.569	2025-10-20 09:41:49.64	2	f
9c2dc641-ce91-42ca-b5e1-6773dbbac971	257f38ba-274d-4d6c-a29b-5109f84ae9d8	Headache	2025-10-20 09:40:44.485	2025-10-20 09:43:25.821	4	t
\.


--
-- Data for Name: checklist_completions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.checklist_completions (id, checklist_item_id, completed_at, date, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: conversation_chunks; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.conversation_chunks (id, content, week_number, "timestamp", keywords, created_at) FROM stdin;
bc70a007-7b11-45e1-9363-c6011d1958d2	User: hi\n\nAssistant: To better help you, I'd like to ask a few questions:\n\n1. Hello! How can I help you today?\n\nPlease answer these questions so I can provide you with the most helpful advice.	7	2025-10-20 09:34:53.004	better, help, like, ask, few, questions, hello, how, today, please	2025-10-20 09:34:53.004
30cbf28d-c996-4b95-a65e-c11ece63063b	User: vomit\n\nAssistant: To better help you, I'd like to ask a few questions:\n\n1. I'm sorry to hear you're feeling unwell. Can you tell me a bit more about your vomiting? How often are you vomiting, and when did it start?\n2. Are you able to keep any fluids or food down, or does everything come back up?\n3. Are you experiencing any other symptoms along with the vomiting, such as dizziness, fever, or abdominal pain?\n\nPlease answer these questions so I can provide you with the most helpful advice.	7	2025-10-20 09:37:03.386	vomit, better, help, like, ask, few, questions, sorry, hear, feeling	2025-10-20 09:37:03.386
3ff45ce2-4714-499b-8378-b10042ea1c0e	User: hi\n\nAssistant: To better help you, I'd like to ask a few questions:\n\n1. Welcome back! You previously mentioned you were experiencing vomiting. To help me understand better, could you please tell me: How often are you vomiting, and when did it start?\n2. Are you able to keep any fluids or food down, or does everything come back up?\n3. Are you experiencing any other symptoms along with the vomiting, such as dizziness, fever, or abdominal pain?\n\nPlease answer these questions so I can provide you with the most helpful advice.	7	2025-10-20 09:41:02.758	better, help, like, ask, few, questions, welcome, back, previously, mentioned	2025-10-20 09:41:02.758
7562938c-9d59-46da-a7c8-19acd0979a65	User: headache\n\nAssistant: To better help you, I'd like to ask a few questions:\n\n1. To help me understand better, can you describe your headache? For example, is it a dull ache, throbbing, or a sharp pain? Where is the pain located?\n2. How severe is the pain on a scale of 1 to 10, where 1 is very mild and 10 is the worst pain you've ever experienced?\n3. How long have you had this headache, and are you experiencing any other symptoms along with it, such as changes in vision, dizziness, or fever?\n\nPlease answer these questions so I can provide you with the most helpful advice.	7	2025-10-20 09:43:25.822	headache, better, help, like, ask, few, questions, understand, describe, your	2025-10-20 09:43:25.822
\.


--
-- Data for Name: knowledge_facts; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.knowledge_facts (id, category, fact_text, source_message_id, week_number, date_recorded, metadata, created_at) FROM stdin;
da59d1a9-e737-424f-8ce2-6d6a211c4c81	symptom	User is experiencing vomiting.	\N	7	2025-10-20 09:37:06.618	"{\\"extractedFrom\\":\\"chat\\",\\"confidence\\":\\"medium\\"}"	2025-10-20 09:37:06.618
638e47fa-3ea1-4388-84ee-f021295cadf7	symptom	User previously mentioned experiencing vomiting.	\N	7	2025-10-20 09:41:07.304	"{\\"extractedFrom\\":\\"chat\\",\\"confidence\\":\\"medium\\"}"	2025-10-20 09:41:07.304
dd2936c3-50ef-410b-bb48-b2868ebd6eae	symptom	User is experiencing a headache	\N	7	2025-10-20 09:43:29.111	"{\\"extractedFrom\\":\\"chat\\",\\"confidence\\":\\"medium\\"}"	2025-10-20 09:43:29.111
\.


--
-- Data for Name: pregnancy_data; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.pregnancy_data (id, user_id, due_date, last_menstrual_period, notes, created_at, updated_at) FROM stdin;
047415c2-ca03-42eb-b8c9-ba6d8bf0efd9	95cc2d45-706e-456c-8fe7-8287d07129e5	2024-08-15 00:00:00	2023-11-08 00:00:00	First pregnancy, very excited!	2025-10-20 03:19:03.03	2025-10-20 03:19:03.03
ad9a7165-b2f3-4539-849d-b18ec1c53c73	fc1a2d5a-721e-4167-b33e-d77d7500edf8	2024-08-15 00:00:00	2023-11-08 00:00:00	Test pregnancy data from Flutter replica test	2025-10-20 03:47:18.883	2025-10-20 03:47:18.883
da22ebf8-91ca-426b-9b3a-fceff2c1a67d	5a931eaa-b259-4424-8692-fc4e96ad2009	2024-08-15 00:00:00	2023-11-08 00:00:00	Test pregnancy data from Flutter replica test	2025-10-20 03:47:40.042	2025-10-20 03:47:40.042
7973cfe9-dcc8-4ec2-8476-6fdff906460b	257f38ba-274d-4d6c-a29b-5109f84ae9d8	2026-06-12 18:30:00	2025-08-30 18:30:00	\N	2025-10-20 08:08:34.085	2025-10-20 08:08:34.085
\.


--
-- Data for Name: pregnancy_tips; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.pregnancy_tips (id, week, tip, category, created_at, expires_at) FROM stdin;
\.


--
-- Data for Name: symptoms; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.symptoms (id, user_id, type, severity, date_time, notes, custom_type, created_at) FROM stdin;
aaefe541-164c-4565-870b-e876d7b650e1	257f38ba-274d-4d6c-a29b-5109f84ae9d8	headaches	mild	2025-10-20 09:43:28.355	This afternoon	\N	2025-10-20 09:43:28.357
\.


--
-- Data for Name: user_profiles; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_profiles (id, user_id, height, weight, pre_pregnancy_weight, age, gender, locality, timezone, medical_history, allergies, medications, lifestyle, created_at, updated_at) FROM stdin;
f5da0b46-2a23-4181-a5f8-82ae7fe0c304	fc1a2d5a-721e-4167-b33e-d77d7500edf8	165	60	\N	28	female	Test City	America/New_York	["None"]	["None"]	["Prenatal vitamins"]	{"diet": "Balanced", "sleep": "8 hours", "exercise": "Light walking"}	2025-10-20 03:47:18.905	2025-10-20 03:47:18.905
cdee5ef1-94c3-4a55-b128-5141a51b664d	5a931eaa-b259-4424-8692-fc4e96ad2009	165	60	\N	28	female	Test City	America/New_York	["None"]	["None"]	["Prenatal vitamins"]	{"diet": "Balanced", "sleep": "8 hours", "exercise": "Light walking"}	2025-10-20 03:47:40.053	2025-10-20 03:47:40.053
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, firebase_uid, email, display_name, photo_url, created_at, updated_at) FROM stdin;
95cc2d45-706e-456c-8fe7-8287d07129e5	3FNQdTWBK3gDFm73b6Ok98HHhRm1	test1@example.com	Test User 1	https://example.com/photo.jpg	2025-10-19 08:23:59.864	2025-10-19 08:23:59.864
d28c7f0b-2519-4590-89e9-460fd170bc5e	yF7M0KXLELOP6z9Do5lczb6FN4Y2	flutter-test-a5a5ef01@example.com	Flutter Test User	https://example.com/test-avatar.jpg	2025-10-20 03:45:43.489	2025-10-20 03:45:43.489
0e5724dd-c337-4ac7-8a4b-f0a619ca03e3	s20cse2iOLT3iW7Bp7UxSsAqeOn2	flutter-test-d560bc3e@example.com	Flutter Test User	https://example.com/test-avatar.jpg	2025-10-20 03:46:45.473	2025-10-20 03:46:45.473
fc1a2d5a-721e-4167-b33e-d77d7500edf8	tn6B8lDzwBa6tUA90mJ6clGWAhg1	flutter-test-e3d8be6f@example.com	Flutter Test User	https://example.com/test-avatar.jpg	2025-10-20 03:47:18.824	2025-10-20 03:47:18.824
0f06453f-cb19-457d-80cb-46a6a00943db	yC397ahxkgXqtxFcGgUhhcke0ge2	flutter-test-2-86200caf@example.com	Second Test User	\N	2025-10-20 03:47:19.771	2025-10-20 03:47:19.771
5a931eaa-b259-4424-8692-fc4e96ad2009	86Yf6vtCiNNzUaqPfyXVEXs4WIj1	flutter-test-dbd4978f@example.com	Flutter Test User	https://example.com/test-avatar.jpg	2025-10-20 03:47:39.995	2025-10-20 03:47:39.995
0bd232f4-c547-457f-8896-144c2ffc15bd	XvM8vrmSAIZRWrzpJGjroD11PR43	flutter-test-2-5fb40e3a@example.com	Second Test User	\N	2025-10-20 03:47:40.885	2025-10-20 03:47:40.885
51d2193d-e996-4fd3-bb07-a2a4d3096b65	QqEXi7d18vcDgbbySxde6GfadzR2	simplified-test-1760935436649@example.com	Simplified Test User	\N	2025-10-20 04:43:57.812	2025-10-20 04:43:57.812
b3b9afdf-0ed2-40c8-acc3-d808568ff15d	Ra5JyhjEFWPcFpODx9nbtF5hlA33	simplified-test-1760935490577@example.com	Simplified Test User	\N	2025-10-20 04:44:51.777	2025-10-20 04:44:51.777
257f38ba-274d-4d6c-a29b-5109f84ae9d8	JvnXzi4Iy8ZFNSXX4hyAToebbbg1	shivanandham625@gmail.com	Shiva nandham	https://lh3.googleusercontent.com/a/ACg8ocKfZceZF13hb_kyy2QMJG2h4HKDB0Y5uXlK-AbcVM8f-ls1sv9h=s96-c	2025-10-20 07:29:45	2025-10-21 05:18:43.704
\.


--
-- Data for Name: weight_entries; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.weight_entries (id, user_id, weight, date_time, notes, created_at) FROM stdin;
\.


--
-- Name: _prisma_migrations _prisma_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public._prisma_migrations
    ADD CONSTRAINT _prisma_migrations_pkey PRIMARY KEY (id);


--
-- Name: appointments appointments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.appointments
    ADD CONSTRAINT appointments_pkey PRIMARY KEY (id);


--
-- Name: chat_messages chat_messages_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.chat_messages
    ADD CONSTRAINT chat_messages_pkey PRIMARY KEY (id);


--
-- Name: chat_sessions chat_sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.chat_sessions
    ADD CONSTRAINT chat_sessions_pkey PRIMARY KEY (id);


--
-- Name: checklist_completions checklist_completions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.checklist_completions
    ADD CONSTRAINT checklist_completions_pkey PRIMARY KEY (id);


--
-- Name: conversation_chunks conversation_chunks_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.conversation_chunks
    ADD CONSTRAINT conversation_chunks_pkey PRIMARY KEY (id);


--
-- Name: knowledge_facts knowledge_facts_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.knowledge_facts
    ADD CONSTRAINT knowledge_facts_pkey PRIMARY KEY (id);


--
-- Name: pregnancy_data pregnancy_data_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pregnancy_data
    ADD CONSTRAINT pregnancy_data_pkey PRIMARY KEY (id);


--
-- Name: pregnancy_tips pregnancy_tips_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pregnancy_tips
    ADD CONSTRAINT pregnancy_tips_pkey PRIMARY KEY (id);


--
-- Name: symptoms symptoms_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.symptoms
    ADD CONSTRAINT symptoms_pkey PRIMARY KEY (id);


--
-- Name: user_profiles user_profiles_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_profiles
    ADD CONSTRAINT user_profiles_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: weight_entries weight_entries_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.weight_entries
    ADD CONSTRAINT weight_entries_pkey PRIMARY KEY (id);


--
-- Name: appointments_date_time_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX appointments_date_time_idx ON public.appointments USING btree (date_time);


--
-- Name: appointments_user_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX appointments_user_id_idx ON public.appointments USING btree (user_id);


--
-- Name: chat_messages_session_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX chat_messages_session_id_idx ON public.chat_messages USING btree (session_id);


--
-- Name: chat_messages_timestamp_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX chat_messages_timestamp_idx ON public.chat_messages USING btree ("timestamp");


--
-- Name: checklist_completions_checklist_item_id_date_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX checklist_completions_checklist_item_id_date_key ON public.checklist_completions USING btree (checklist_item_id, date);


--
-- Name: checklist_completions_checklist_item_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX checklist_completions_checklist_item_id_idx ON public.checklist_completions USING btree (checklist_item_id);


--
-- Name: checklist_completions_date_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX checklist_completions_date_idx ON public.checklist_completions USING btree (date);


--
-- Name: conversation_chunks_week_number_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX conversation_chunks_week_number_idx ON public.conversation_chunks USING btree (week_number);


--
-- Name: knowledge_facts_category_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX knowledge_facts_category_idx ON public.knowledge_facts USING btree (category);


--
-- Name: knowledge_facts_week_number_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX knowledge_facts_week_number_idx ON public.knowledge_facts USING btree (week_number);


--
-- Name: pregnancy_data_user_id_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX pregnancy_data_user_id_key ON public.pregnancy_data USING btree (user_id);


--
-- Name: pregnancy_tips_expires_at_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX pregnancy_tips_expires_at_idx ON public.pregnancy_tips USING btree (expires_at);


--
-- Name: pregnancy_tips_week_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX pregnancy_tips_week_idx ON public.pregnancy_tips USING btree (week);


--
-- Name: symptoms_date_time_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX symptoms_date_time_idx ON public.symptoms USING btree (date_time);


--
-- Name: symptoms_user_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX symptoms_user_id_idx ON public.symptoms USING btree (user_id);


--
-- Name: user_profiles_user_id_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX user_profiles_user_id_key ON public.user_profiles USING btree (user_id);


--
-- Name: users_firebase_uid_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX users_firebase_uid_key ON public.users USING btree (firebase_uid);


--
-- Name: weight_entries_date_time_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX weight_entries_date_time_idx ON public.weight_entries USING btree (date_time);


--
-- Name: weight_entries_user_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX weight_entries_user_id_idx ON public.weight_entries USING btree (user_id);


--
-- Name: appointments appointments_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.appointments
    ADD CONSTRAINT appointments_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: chat_messages chat_messages_parent_message_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.chat_messages
    ADD CONSTRAINT chat_messages_parent_message_id_fkey FOREIGN KEY (parent_message_id) REFERENCES public.chat_messages(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: chat_messages chat_messages_session_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.chat_messages
    ADD CONSTRAINT chat_messages_session_id_fkey FOREIGN KEY (session_id) REFERENCES public.chat_sessions(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: chat_sessions chat_sessions_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.chat_sessions
    ADD CONSTRAINT chat_sessions_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: pregnancy_data pregnancy_data_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pregnancy_data
    ADD CONSTRAINT pregnancy_data_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: symptoms symptoms_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.symptoms
    ADD CONSTRAINT symptoms_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: user_profiles user_profiles_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_profiles
    ADD CONSTRAINT user_profiles_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: weight_entries weight_entries_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.weight_entries
    ADD CONSTRAINT weight_entries_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

