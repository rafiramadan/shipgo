// Prototype user store — no database yet, mirroring the rest of this app's approach
// (trip/DO data is also hardcoded). Passwords are bcrypt-hashed, never stored in
// plaintext. Swap this for a real users table before onboarding real accounts.
export const USERS = [
  {
    id: 'u1',
    email: 'dispatcher@shipgo.id',
    name: 'Rafi Ramadani',
    role: 'Dispatcher',
    passwordHash: '$2b$10$od1NBLsMSh1NFbYN2d/LO.ATMQTK0nrZzxCO5fspk8S4kI1dCJ5Ai', // ShipGo!2026
  },
  {
    id: 'u2',
    email: 'admin@shipgo.id',
    name: 'Admin ShipGo',
    role: 'Administrator',
    passwordHash: '$2b$10$8rRiYmIrz/6j0AWqnKsNxuHDqlW8ykTg/qWzuYdJIGtvH1lZwrrEK', // Parama!Admin26
  },
];

export function findUserByEmail(email) {
  return USERS.find((u) => u.email.toLowerCase() === email) || null;
}
