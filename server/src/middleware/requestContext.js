import { AsyncLocalStorage } from 'async_hooks';

// Async-local storage used to propagate the authenticated user id into the DB layer.
const requestContext = new AsyncLocalStorage();

export function requestContextMiddleware(req, res, next) {
  // Start a new context per request; auth middleware will populate userId when present.
  requestContext.run({ userId: null }, () => next());
}

export function setContextUser(userId) {
  const store = requestContext.getStore();
  if (store) {
    store.userId = userId || null;
  }
}

export function getContextUser() {
  const store = requestContext.getStore();
  return store?.userId || null;
}
