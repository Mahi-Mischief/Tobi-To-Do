// Lightweight sanitizer: trims strings and strips basic script tags.
export function sanitizeInput(req, _res, next) {
  const scrub = (value) => {
    if (typeof value === 'string') {
      // Trim and strip simple script/style tags
      const trimmed = value.trim();
      return trimmed.replace(/<\/?(script|style)[^>]*>/gi, '');
    }
    if (Array.isArray(value)) return value.map((v) => scrub(v));
    if (value && typeof value === 'object') {
      const cleaned = {};
      for (const [k, v] of Object.entries(value)) cleaned[k] = scrub(v);
      return cleaned;
    }
    return value;
  };

  if (req.body) req.body = scrub(req.body);
  if (req.query) req.query = scrub(req.query);
  if (req.params) req.params = scrub(req.params);
  next();
}
