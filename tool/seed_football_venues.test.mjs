import assert from 'node:assert/strict';
import { spawnSync } from 'node:child_process';
import { fileURLToPath } from 'node:url';
import test from 'node:test';

import { buildSeedVenues, seedFootballVenues } from './seed_football_venues.mjs';

const adminToken = 'test-admin-token';
const ownerToken = 'test-owner-token';

function fixture({ venues = [], courts = [], publicShape = 'data' } = {}) {
  const state = {
    venues: structuredClone(venues),
    courts: structuredClone(courts),
    calls: [],
  };
  let nextId = 1;
  const request = async (method, path, token, body) => {
    state.calls.push({ method, path, token, body: structuredClone(body) });
    const url = new URL(path, 'https://example.test/api/');
    const segments = url.pathname.split('/').filter(Boolean);
    if (segments[0] === 'owner') assert.equal(token, ownerToken);
    if (segments[0] === 'admin') assert.equal(token, adminToken);

    if (method === 'GET' && url.pathname === '/owner/venues') {
      return structuredClone(state.venues.filter((venue) => venue.ownerId === 'seed-owner'));
    }
    if (method === 'POST' && url.pathname === '/owner/venues') {
      const venue = {
        id: `new-venue-${nextId++}`,
        ownerId: 'seed-owner',
        status: 'draft',
        images: [],
        ...structuredClone(body),
      };
      state.venues.push(venue);
      return structuredClone(venue);
    }
    if (segments[0] === 'owner' && segments[1] === 'venues') {
      const venue = state.venues.find((item) => item.id === segments[2]);
      assert.ok(venue, `Unknown venue: ${path}`);
      assert.equal(venue.ownerId, 'seed-owner');
      if (segments[3] === 'courts') {
        if (method === 'GET') {
          return structuredClone(state.courts.filter((court) => court.venueId === venue.id));
        }
        if (method === 'POST') {
          const court = {
            id: `new-court-${nextId++}`,
            venueId: venue.id,
            isActive: true,
            ...structuredClone(body),
          };
          state.courts.push(court);
          return structuredClone(court);
        }
      }
      if (method === 'POST' && segments[3] === 'submit') {
        assert.ok(state.courts.some((court) => court.venueId === venue.id && court.isActive));
        venue.status = 'pending';
        return structuredClone(venue);
      }
    }
    if (method === 'POST' && segments[0] === 'admin' && segments[3] === 'approve') {
      const venue = state.venues.find((item) => item.id === segments[2]);
      assert.ok(venue);
      assert.equal(venue.status, 'pending');
      venue.status = 'approved';
      return structuredClone(venue);
    }
    if (method === 'GET' && url.pathname === '/venues') {
      assert.equal(url.searchParams.get('sport'), 'Football');
      const page = Number(url.searchParams.get('page'));
      const limit = Number(url.searchParams.get('limit'));
      const approved = state.venues.filter((venue) =>
        venue.status === 'approved' && venue.sports.includes('Football'));
      return {
        total: approved.length,
        page,
        limit,
        [publicShape]: structuredClone(approved.slice((page - 1) * limit, page * limit)),
      };
    }
    throw new Error(`Unexpected request: ${method} ${path}`);
  };
  return { state, request };
}

function existingVenue(index, status = 'draft') {
  const { courts, ...venue } = buildSeedVenues()[index];
  return { id: `existing-venue-${index}`, ownerId: 'seed-owner', status, ...venue };
}

async function run(api) {
  return seedFootballVenues({ request: api.request, adminToken, ownerToken });
}

function assertComplete(state) {
  const seeded = state.venues.filter((venue) => venue.ownerId === 'seed-owner');
  assert.equal(seeded.length, 20);
  assert.equal(new Set(seeded.map((venue) => `${venue.name}|${venue.city}|${venue.address}`)).size, 20);
  for (const venue of seeded) {
    assert.equal(venue.status, 'approved');
    assert.deepEqual(venue.sports, ['Football']);
    const courts = state.courts.filter((court) => court.venueId === venue.id);
    assert.equal(courts.length, 2);
    assert.equal(new Set(courts.map((court) => court.name)).size, 2);
    assert.ok(courts.every((court) => court.isActive && court.sport === 'Football'));
  }
}

test('creates 20 publicly approved Football venues and 40 active courts', async () => {
  const api = fixture();
  const result = await run(api);
  assertComplete(api.state);
  assert.equal(result.createdVenues, 20);
  assert.equal(result.createdCourts, 40);
  assert.equal(result.verifiedVenues, 20);
});

test('rerunning a completed seed performs no mutations or duplicate inserts', async () => {
  const api = fixture();
  await run(api);
  api.state.calls.length = 0;
  const result = await run(api);
  assertComplete(api.state);
  assert.equal(result.createdVenues, 0);
  assert.equal(result.createdCourts, 0);
  assert.equal(result.reusedVenues, 20);
  assert.equal(result.reusedCourts, 40);
  assert.ok(api.state.calls.every((call) => call.method === 'GET'));
});

test('resumes a draft with one court and preserves unrelated owner data', async () => {
  const first = existingVenue(0);
  const unrelated = {
    id: 'unrelated', ownerId: 'seed-owner', name: 'Existing arena',
    city: 'Lahore', address: 'Existing address', sports: ['Cricket'], status: 'approved',
  };
  const api = fixture({
    venues: [first, unrelated],
    courts: [{ id: 'existing-court', venueId: first.id, isActive: true, ...buildSeedVenues()[0].courts[0] }],
  });
  const result = await run(api);
  assert.equal(api.state.venues.length, 21);
  assert.equal(api.state.courts.length, 40);
  assert.equal(result.createdVenues, 19);
  assert.equal(result.createdCourts, 39);
  assert.deepEqual(api.state.venues.find((venue) => venue.id === 'unrelated'), unrelated);
  assert.equal(api.state.courts.filter((court) => court.venueId === first.id).length, 2);
});

test('recovers a persisted court after a lost POST response without duplicating it', async () => {
  const api = fixture();
  const normalRequest = api.request;
  let interrupted = false;
  api.request = async (...args) => {
    const result = await normalRequest(...args);
    if (!interrupted && args[0] === 'POST' && args[1].endsWith('/courts')) {
      interrupted = true;
      throw new Error('simulated lost response after insert');
    }
    return result;
  };
  await assert.rejects(run(api), /lost response/);
  api.request = normalRequest;
  await run(api);
  assertComplete(api.state);
});

for (const status of ['rejected', 'suspended']) {
  test(`refuses to republish a ${status} seed venue`, async () => {
    const api = fixture({ venues: [existingVenue(0, status)] });
    await assert.rejects(run(api));
    assert.equal(api.state.venues[0].status, status);
    assert.ok(api.state.calls.every((call) => call.method === 'GET'));
  });
}

test('refuses ambiguous venue matches rather than changing an arbitrary record', async () => {
  const first = existingVenue(0);
  const api = fixture({ venues: [first, { ...first, id: 'duplicate-venue' }] });
  await assert.rejects(run(api));
  assert.ok(api.state.calls.every((call) => call.method === 'GET'));
});

test('does not reuse inactive courts or create another with the same name', async () => {
  const first = existingVenue(0);
  const api = fixture({
    venues: [first],
    courts: [{ id: 'inactive-court', venueId: first.id, ...buildSeedVenues()[0].courts[0], isActive: false }],
  });
  await assert.rejects(run(api));
  assert.equal(api.state.courts.length, 1);
  assert.equal(api.state.courts[0].isActive, false);
  assert.ok(api.state.calls.every((call) => call.method === 'GET'));
});

for (const publicShape of ['data', 'items']) {
  test(`verifies seed IDs on later public pages using the ${publicShape} response shape`, async () => {
    const others = Array.from({ length: 105 }, (_, index) => ({
      id: `other-${index}`, ownerId: 'other-owner', name: `Other arena ${index}`,
      city: 'Lahore', address: `Address ${index}`, sports: ['Football'], status: 'approved',
    }));
    const api = fixture({ venues: others, publicShape });
    const result = await run(api);
    assert.equal(result.verifiedVenues, 20);
    assert.ok(api.state.calls.some((call) =>
      call.path.startsWith('/venues?') && new URL(call.path, 'https://example.test').searchParams.get('page') === '2'));
    assert.deepEqual(api.state.venues.filter((venue) => venue.ownerId === 'other-owner'), others);
  });
}

test('--dry-run prints a valid seed plan without credentials or network access', () => {
  const env = { ...process.env, API_BASE_URL: 'https://example.invalid/api/' };
  for (const key of ['ADMIN_EMAIL', 'ADMIN_PASSWORD', 'SEED_OWNER_PASSWORD']) delete env[key];
  const result = spawnSync(process.execPath, [fileURLToPath(new URL('./seed_football_venues.mjs', import.meta.url)), '--dry-run'], {
    env, encoding: 'utf8', timeout: 5000,
  });
  assert.equal(result.status, 0, result.stderr);
  const plan = JSON.parse(result.stdout);
  assert.deepEqual(plan, buildSeedVenues());
});
