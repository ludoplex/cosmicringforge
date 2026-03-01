# users.sql — User management schema
# Example SQL spec for sqlgen

table users {
    id: integer primary key
    name: text not null
    email: text unique not null
    created_at: timestamp default now
}

table sessions {
    id: integer primary key
    user_id: integer references users(id)
    token: text unique not null
    expires_at: timestamp not null
}

index users_email on users(email)
index sessions_token on sessions(token)

query find_by_email(email: text) -> users {
    SELECT * FROM users WHERE email = ?
}

query get_user_sessions(user_id: integer) -> sessions {
    SELECT * FROM sessions WHERE user_id = ? AND expires_at > datetime('now')
}
