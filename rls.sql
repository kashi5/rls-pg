
--psql -U postgres
--psql -U blog -d demo

--Create Schema
create schema demo;

-- create role blog
CREATE ROLE blog LOGIN PASSWORD 'password';
GRANT CREATE ON SCHEMA demo TO blog;
GRANT USAGE ON SCHEMA demo TO blog;
-- Grant SELECT, INSERT, and UPDATE privileges on all tables in schema
GRANT SELECT, INSERT, UPDATE ON ALL TABLES IN SCHEMA demo TO blog;


\du

--Delete tables
drop table posts cascade;
drop table comments cascade;
drop table users cascade ;


-- Create User
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


-- insert users
INSERT INTO users (username, email) VALUES ('kim', 'kim@rls.ai');
INSERT INTO users (username, email) VALUES ('sam', 'sam@rls.ai');
INSERT INTO users (username, email) VALUES ('leo', 'leo@rls.ai');
INSERT INTO users (username, email) VALUES ('don', 'don@rls.ai');
INSERT INTO users (username, email) VALUES ('kia', 'kia@rls.ai');

-- create posts
create table posts(
	id Serial primary key,
	title varchar(120),
	content text,
	is_published boolean default false,
	user_id int not null,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

--create comments
create table comments(
	id Serial primary key,
	title varchar(120),
	content text,
	post_id int not null,
	user_id int not null,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
	foreign key(post_id) references posts(id) ON DELETE CASCADE
);




CREATE OR REPLACE FUNCTION get_user_id(username_param VARCHAR) 
RETURNS INT AS $$
DECLARE
    user_id INT;
BEGIN
    SELECT id INTO user_id
    FROM demo.users
    WHERE username = username_param;
    
    RETURN user_id;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN NULL; -- Return NULL if the username is not found
END;
$$ LANGUAGE plpgsql;


-- Enable RLS on the posts table
ALTER TABLE posts ENABLE ROW LEVEL SECURITY;

select * from posts p ;

select * from demo.users u ;

-- Displays table has select statement
select *
FROM information_schema.role_table_grants
WHERE grantee = 'blog' AND table_name = 'users' AND privilege_type = 'SELECT';

insert into demo.posts(title,content,is_published,user_id) values('Hello','World',false,1);
insert into demo.posts(title,content,is_published,user_id) values('Cricket','Game',true,1);
insert into demo.posts(title,content,is_published,user_id) values('Earth','Happy',true,2);


create policy display_published_posts on demo.posts for 
select
using (is_published=true);
