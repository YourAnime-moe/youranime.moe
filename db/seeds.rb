def seed
  seed_users
end

def seed_users
  admin_user = Staff.create(
    username: 'admin',
    name: 'Admin User',
    limited: false
  )

  admin_user.to_user!
end

seed
