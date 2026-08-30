/** US 10-digit numbers. Strips +1 / leading 1 when pasted. */
export function digitsOnly(value: string): string {
  let digits = value.replace(/\D/g, "");
  if (digits.length === 11 && digits.startsWith("1")) {
    digits = digits.slice(1);
  }
  return digits.slice(0, 10);
}

export function formatUsPhone(value: string): string {
  const d = digitsOnly(value);
  if (d.length === 0) return "";
  if (d.length < 4) return d;
  if (d.length < 7) return `(${d.slice(0, 3)}) ${d.slice(3)}`;
  return `(${d.slice(0, 3)}) ${d.slice(3, 6)}-${d.slice(6)}`;
}

export function toE164(value: string): string | null {
  const d = digitsOnly(value);
  if (d.length !== 10) return null;
  return `+1${d}`;
}

export function displayPhone(e164: string): string {
  const d = digitsOnly(e164);
  return d.length === 10 ? formatUsPhone(d) : e164;
}
