// User Model Schema
export const UserSchema = {
  tableName: 'users',
  columns: {
    id: 'UUID PRIMARY KEY DEFAULT gen_random_uuid()',
    email: 'VARCHAR(255) UNIQUE NOT NULL',
    password_hash: 'VARCHAR(255)',
    firebase_uid: 'VARCHAR(255) UNIQUE',
    full_name: 'VARCHAR(255)',
    avatar_url: 'TEXT',
    bio: 'TEXT',
    theme_preference: "VARCHAR(20) DEFAULT 'light'",
    notifications_enabled: 'BOOLEAN DEFAULT true',
    created_at: 'TIMESTAMP DEFAULT CURRENT_TIMESTAMP',
    updated_at: 'TIMESTAMP DEFAULT CURRENT_TIMESTAMP',
    deleted_at: 'TIMESTAMP'
  }
};

export class User {
  constructor(data) {
    this.id = data.id;
    this.email = data.email;
    this.password_hash = data.password_hash;
    this.firebase_uid = data.firebase_uid;
    this.full_name = data.full_name;
    this.avatar_url = data.avatar_url;
    this.bio = data.bio;
    this.theme_preference = data.theme_preference || 'light';
    this.notifications_enabled = data.notifications_enabled !== false;
    this.created_at = data.created_at;
    this.updated_at = data.updated_at;
  }

  toJSON() {
    // Exclude sensitive data
    const { password_hash, ...userData } = this;
    return userData;
  }
}
