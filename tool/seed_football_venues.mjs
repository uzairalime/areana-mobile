#!/usr/bin/env node
import { randomBytes } from 'node:crypto';
import { chmod, readFile, writeFile } from 'node:fs/promises';
import { dirname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const PROJECT_ROOT = resolve(dirname(fileURLToPath(import.meta.url)), '..');
const OWNER_STATE_PATH = resolve(PROJECT_ROOT, '.seed-football-owner.json');
const OWNER_EMAIL = 'football-seed@example.com';

/** Fictional venues; coordinates identify approximate neighborhoods only. */
export function buildSeedVenues() {
  const locations = [
    ['Lahore', 'DHA Phase 5', 31.4657, 74.415],
    ['Lahore', 'Johar Town', 31.4697, 74.2728],
    ['Lahore', 'Gulberg', 31.5106, 74.3441],
    ['Lahore', 'Model Town', 31.4815, 74.3239],
    ['Lahore', 'Bahria Town', 31.3601, 74.1754],
    ['Lahore', 'Valencia', 31.39, 74.2585],
    ['Lahore', 'Wapda Town', 31.4328, 74.2855],
    ['Lahore', 'Cantt', 31.5327, 74.3831],
    ['Karachi', 'Clifton', 24.8142, 67.0225],
    ['Karachi', 'DHA Phase 6', 24.8047, 67.0633],
    ['Karachi', 'Gulshan-e-Iqbal', 24.9276, 67.0903],
    ['Karachi', 'North Nazimabad', 24.9364, 67.0422],
    ['Karachi', 'PECHS', 24.8618, 67.0621],
    ['Karachi', 'Malir', 24.9029, 67.1922],
    ['Islamabad', 'F-6', 33.7294, 73.0755],
    ['Islamabad', 'F-11', 33.6822, 72.9897],
    ['Islamabad', 'G-13', 33.6518, 72.9617],
    ['Islamabad', 'Bahria Enclave', 33.6703, 73.2188],
    ['Rawalpindi', 'Satellite Town', 33.6394, 73.0644],
    ['Rawalpindi', 'Bahria Phase 7', 33.5193, 73.0923],
  ];
  return locations.map(([city, neighborhood, lat, lng], index) => ({
    name: `Demo ${neighborhood} Football Arena`,
    address: `Demo ground, ${neighborhood} (sample location)`,
    city,
    lat,
    lng,
    sports: ['Football'],
    amenities: ['Floodlights', 'Parking', 'Restrooms', 'Drinking Water'],
    courts: ['5v5', '7v7'].map((size, courtIndex) => ({
      name: `Demo ${size} Turf`,
      sport: 'Football',
      size,
      surface: 'artificial_grass',
      indoor: false,
      pricePerHour: Math.min(6000, 2500 + (index % 8) * 400 + courtIndex * 700),
      openMinutes: 360,
      closeMinutes: 1380,
      slotMinutes: 60,
    })),
  }));
}

function requireArray(value, label) {
  if (!Array.isArray(value)) throw new Error(`Unexpected ${label} response.`);
  return value;
}

function requireId(value, label) {
  if (!value || typeof value.id !== 'string' || !value.id) {
    throw new Error(`Missing ${label} ID in API response.`);
  }
  return value;
}

/** request(method, relativePath, bearerToken?, jsonBody?) returns parsed JSON. */
export async function seedFootballVenues({ request, adminToken, ownerToken, log = () => {} }) {
  if (typeof request !== 'function' || !adminToken || !ownerToken) {
    throw new Error('An API request function and admin/owner tokens are required.');
  }
  const counters = {
    createdVenues: 0,
    reusedVenues: 0,
    createdCourts: 0,
    reusedCourts: 0,
    approvedVenues: 0,
    verifiedVenues: 0,
  };
  const owned = requireArray(await request('GET', '/owner/venues', ownerToken), 'owner venues');
  const seededIds = new Set();

  for (const definition of buildSeedVenues()) {
    const { courts, ...payload } = definition;
    const matches = owned.filter((venue) =>
      venue.name === payload.name && venue.city === payload.city && venue.address === payload.address,
    );
    if (matches.length > 1) throw new Error(`Ambiguous demo venue: ${payload.name}.`);
    let venue;
    if (matches.length === 1) {
      venue = requireId(matches[0], 'venue');
      counters.reusedVenues++;
    } else {
      venue = requireId(await request('POST', '/owner/venues', ownerToken, payload), 'venue');
      owned.push(venue);
      counters.createdVenues++;
    }
    if (!['draft', 'pending', 'approved'].includes(venue.status)) {
      throw new Error(`Demo venue ${payload.name} has status ${venue.status}; manual review required.`);
    }
    if (!Array.isArray(venue.sports) || !venue.sports.includes('Football')) {
      throw new Error(`Demo venue ${payload.name} does not have the Football sport.`);
    }
    const existingCourts = requireArray(
      await request('GET', `/owner/venues/${encodeURIComponent(venue.id)}/courts`, ownerToken),
      'owner courts',
    );
    for (const court of courts) {
      const courtMatches = existingCourts.filter((existing) => existing.name === court.name);
      if (courtMatches.length > 1) throw new Error(`Ambiguous demo court at ${payload.name}: ${court.name}.`);
      if (courtMatches.length === 1) {
        const existing = courtMatches[0];
        if (existing.sport !== 'Football' || existing.isActive !== true) {
          throw new Error(`Existing demo court at ${payload.name} must be active Football: ${court.name}.`);
        }
        counters.reusedCourts++;
      } else {
        const created = requireId(
          await request('POST', `/owner/venues/${encodeURIComponent(venue.id)}/courts`, ownerToken, court),
          'court',
        );
        existingCourts.push(created);
        counters.createdCourts++;
      }
    }
    if (venue.status === 'draft') {
      venue = await request('POST', `/owner/venues/${encodeURIComponent(venue.id)}/submit`, ownerToken);
      if (venue?.status !== 'pending') throw new Error(`Demo venue submission failed: ${payload.name}.`);
    }
    if (venue.status === 'pending') {
      venue = await request('POST', `/admin/venues/${encodeURIComponent(venue.id)}/approve`, adminToken);
      if (venue?.status !== 'approved') throw new Error(`Demo venue approval failed: ${payload.name}.`);
      counters.approvedVenues++;
    }
    seededIds.add(requireId(venue, 'approved venue').id);
    log(`Ready: ${payload.name}, ${payload.city}`);
  }

  const found = new Set();
  for (let page = 1; page <= 10000 && found.size < seededIds.size; page++) {
    const result = await request('GET', `/venues?sport=Football&page=${page}&limit=100`);
    const venues = requireArray(result?.data ?? result?.items, 'public venues');
    for (const venue of venues) if (seededIds.has(venue.id)) found.add(venue.id);
    if (!venues.length || (Number.isFinite(result.total) && page * 100 >= result.total)) break;
  }
  counters.verifiedVenues = found.size;
  if (found.size !== seededIds.size) {
    throw new Error(`Public verification found ${found.size}/${seededIds.size} demo Football venues.`);
  }
  return counters;
}

export function normalizeApiBaseUrl(input) {
  let url;
  try { url = new URL(input); } catch { throw new Error('API_BASE_URL must be a valid API URL.'); }
  const local = ['localhost', '127.0.0.1', '[::1]'].includes(url.hostname);
  if (url.protocol !== 'https:' && !(url.protocol === 'http:' && local)) {
    throw new Error('API_BASE_URL must use HTTPS, or HTTP on localhost.');
  }
  if (url.username || url.password || url.search || url.hash) {
    throw new Error('API_BASE_URL cannot contain credentials, a query, or a fragment.');
  }
  url.pathname = `${url.pathname.replace(/\/+$/, '').replace(/\/api$/, '')}/api/`;
  return url.href;
}

function createRequest(baseUrl) {
  return async (method, path, token, body) => {
    let response;
    try {
      response = await fetch(`${baseUrl}${path.replace(/^\//, '')}`, {
        method,
        redirect: 'error',
        signal: AbortSignal.timeout(30000),
        headers: {
          accept: 'application/json',
          ...(body === undefined ? {} : { 'content-type': 'application/json' }),
          ...(token ? { authorization: `Bearer ${token}` } : {}),
        },
        ...(body === undefined ? {} : { body: JSON.stringify(body) }),
      });
    } catch {
      throw new Error(`${method} ${path} failed (network, timeout, or redirect). Rerun to reconcile existing records.`);
    }
    if (!response.ok) throw new Error(`${method} ${path} failed (HTTP ${response.status}).`);
    try { return await response.json(); } catch { throw new Error(`${method} ${path} returned invalid JSON.`); }
  };
}

async function readOwnerState() {
  try {
    const state = JSON.parse(await readFile(OWNER_STATE_PATH, 'utf8'));
    if (!state || state.version !== 1 || !state.targets || typeof state.targets !== 'object') {
      throw new Error('Invalid saved owner credentials.');
    }
    await chmod(OWNER_STATE_PATH, 0o600);
    return state;
  } catch (error) {
    if (error.code === 'ENOENT') return { version: 1, targets: {} };
    throw new Error('Cannot read saved demo owner credentials.');
  }
}

async function saveOwnerState(state) {
  await writeFile(OWNER_STATE_PATH, `${JSON.stringify(state, null, 2)}\n`, { mode: 0o600 });
  await chmod(OWNER_STATE_PATH, 0o600);
}

function requireOwnerLogin(login) {
  const permissions = login?.user?.permissions;
  if (!login?.accessToken || login.user?.role !== 'owner' || !Array.isArray(permissions) ||
      !['venues.manage', 'courts.manage'].every((permission) => permissions.includes(permission))) {
    throw new Error('Demo owner login must have owner role, venues.manage, and courts.manage permissions.');
  }
  return login.accessToken;
}

export async function runCLI(args = process.argv.slice(2), env = process.env) {
  if (args.includes('--help')) {
    console.log('Usage: node tool/seed_football_venues.mjs [--dry-run]\nLive: ADMIN_EMAIL, ADMIN_PASSWORD; optional API_BASE_URL, SEED_OWNER_EMAIL, SEED_OWNER_PASSWORD.');
    return;
  }
  if (args.some((argument) => argument !== '--dry-run')) throw new Error('Unknown argument. Use --help.');
  if (args.includes('--dry-run')) {
    console.log(JSON.stringify(buildSeedVenues(), null, 2));
    return;
  }
  if (!env.ADMIN_EMAIL || !env.ADMIN_PASSWORD) throw new Error('ADMIN_EMAIL and ADMIN_PASSWORD are required.');
  let configuredUrl = env.API_BASE_URL;
  if (!configuredUrl) {
    try { configuredUrl = JSON.parse(await readFile(resolve(PROJECT_ROOT, 'config.development.json'), 'utf8')).API_BASE_URL; }
    catch { throw new Error('Set API_BASE_URL or provide config.development.json.'); }
  }
  const baseUrl = normalizeApiBaseUrl(configuredUrl);
  const request = createRequest(baseUrl);
  const admin = await request('POST', '/auth/staff/login', undefined, {
    email: env.ADMIN_EMAIL,
    password: env.ADMIN_PASSWORD,
  });
  if (!admin?.accessToken || !admin.user?.permissions?.includes('*')) {
    throw new Error('Admin login must have the super-admin permission.');
  }
  const adminToken = admin.accessToken;
  const roles = requireArray(await request('GET', '/admin/roles', adminToken), 'roles');
  const ownerRoles = roles.filter((role) => role.name === 'owner');
  if (ownerRoles.length !== 1) throw new Error('Exactly one owner role is required; bootstrap the backend roles first.');
  const ownerRole = requireId(ownerRoles[0], 'owner role');
  const email = (env.SEED_OWNER_EMAIL || OWNER_EMAIL).trim().toLowerCase();
  if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) throw new Error('SEED_OWNER_EMAIL must be a valid email.');
  const users = requireArray(await request('GET', `/admin/users?q=${encodeURIComponent(email)}`, adminToken), 'users');
  const matches = users.filter((user) => user.email?.toLowerCase() === email);
  if (matches.length > 1) throw new Error('Ambiguous demo owner email.');
  const existingOwner = matches[0];
  if (existingOwner && (existingOwner.roleId !== ownerRole.id || existingOwner.status !== 'active')) {
    throw new Error('Existing demo account must already be an active owner; no account settings were changed.');
  }
  const state = await readOwnerState();
  const saved = state.targets[baseUrl];
  let password = env.SEED_OWNER_PASSWORD || (saved?.email === email ? saved.password : undefined);
  if (existingOwner && !password) {
    throw new Error('Existing demo owner requires SEED_OWNER_PASSWORD or saved credentials.');
  }
  password ||= randomBytes(32).toString('base64url');
  if (password.length < 8 || password.length > 100) throw new Error('Demo owner password must be 8–100 characters.');
  let expectedOwner = existingOwner;
  if (!existingOwner) {
    // Persist before account creation so an interrupted run can resume safely.
    state.targets[baseUrl] = { email, password };
    await saveOwnerState(state);
    expectedOwner = requireId(await request('POST', '/admin/users', adminToken, {
      email, password, name: 'Demo Football Venues Owner', roleId: ownerRole.id,
    }), 'demo owner');
  }
  const owner = await request('POST', '/auth/staff/login', undefined, { email, password });
  const ownerToken = requireOwnerLogin(owner);
  if (owner.user.id !== expectedOwner.id) throw new Error('Demo owner login returned a different account.');
  if (existingOwner) {
    // A mistyped override must never replace working saved credentials.
    state.targets[baseUrl] = { email, password };
    await saveOwnerState(state);
  }
  const result = await seedFootballVenues({ request, adminToken, ownerToken, log: console.log });
  console.log(JSON.stringify(result, null, 2));
  return result;
}

if (process.argv[1] && resolve(process.argv[1]) === fileURLToPath(import.meta.url)) {
  runCLI().catch((error) => {
    console.error(`Football seed failed: ${error.message}`);
    process.exitCode = 1;
  });
}
