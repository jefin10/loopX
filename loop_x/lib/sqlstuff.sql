sql tables in subabase
-- Supabase SQL
CREATE TABLE profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  username TEXT UNIQUE,
  email TEXT,
  bio TEXT,
  avatar_url TEXT,
  created_at TIMESTAMP DEFAULT NOW()
);
create table posts (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references profiles(id) on delete cascade,
  text text,
  image_url text,
  created_at timestamp with time zone default timezone('utc'::text, now())
);
create table likes (
  id uuid primary key default gen_random_uuid(),
  post_id uuid references posts(id) on delete cascade,
  user_id uuid references profiles(id) on delete cascade,
  created_at timestamp default now(),
  unique (post_id, user_id) -- prevent double likes
);
CREATE TABLE follows (
  follower_id UUID REFERENCES profiles(id),
  following_id UUID REFERENCES profiles(id),
  created_at TIMESTAMP DEFAULT NOW(),
  PRIMARY KEY (follower_id, following_id)
);
create table chat_rooms (
  id uuid primary key default gen_random_uuid(),
  user1_id uuid not null,
  user2_id uuid not null,
  created_at timestamp with time zone default now(),
  last_message text,
  last_message_at timestamp with time zone,

  constraint user_order check (user1_id < user2_id),
  unique (user1_id, user2_id),

  foreign key (user1_id) references auth.users(id),
  foreign key (user2_id) references auth.users(id)
);

create table messages (
  id uuid primary key default gen_random_uuid(),
  chat_room_id uuid not null,
  sender_id uuid not null,
  content text not null,
  created_at timestamp with time zone default now(),
  seen boolean default false,

  foreign key (chat_room_id) references chat_rooms(id) on delete cascade,
  foreign key (sender_id) references auth.users(id)
);
create table search_history (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid references auth.users(id) on delete cascade,
  query text,
  searched_at timestamp default now()
);