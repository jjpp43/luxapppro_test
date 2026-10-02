# Demo for PM — Lux Pro referral sidecar

Send this to the person who will sit with the client. A developer does **not** need to be in the room. This is a **clickable fake**, not live Lightspeed.

**What you are asking them to approve:** Beautician builds a product list → customer scans a QR → phone shows 5% off those items and a code the cashier would type. TapMango and the register stay as they are.

**What is fake (say this out loud in the first 20 seconds):**

- Login code is always `000000`. No text is sent.
- Product list is a demo shelf, not live Decatur stock.
- Store credit `$12` is a stub. Production is 5% of listed items they actually buy, in dollars.
- Nothing is sent to Lightspeed. The cashier step is acted, not automated.

---

## What you need in the room

**Best:** two phones with the **Lux Pro** app already installed (the install link the developer sent you — not Expo Go).

**If you only have one phone with the app:** that phone is the **customer**. Your laptop browser can be the **beautician** (build the list, make the QR big on screen). Web cannot scan; only the phone can.

**Do not** install Expo Go from the App Store. It will not open this app.

---

## 5-minute walkthrough

### Phone A — beautician (or laptop)

1. Open **Lux Pro**.
2. Enter any US number (example: `(702) 555 0100`). Continue.
3. Code: `000000`. Verify.
4. **Account** → turn **Beautician tools** on. You should see **$12** store credit and a **List** tab.
5. **List** → tap 2–3 products → **Show QR**.
6. Hold that QR toward the other phone (or the laptop toward the phone).

### Phone B — customer

1. Open **Lux Pro**. Sign in with a **different** number, code `000000`.
2. **Scan** → point at Phone A’s QR.
3. **Home** should show the same products, **5%**, **$20** min ticket, and a code like `LUX M4NK`.
4. Say: “At the register they show this code. Cashier types it or keys 5% on those lines. That part is not wired yet.”

### If Scan fails (one phone only)

On the customer phone: **Load a sample referral**. Home shows `LUX TEST 5` and a sample list. Still enough to talk through the loop.

---

## If something breaks

| What happens | What to do |
|---|---|
| App asks for Expo Go / won’t open | Wrong install. Use the link the developer sent, not the App Store. |
| Reload / reopen and you’re signed out | Tell the developer — session should stick for this demo. |
| Camera denied | iPhone: Settings → Lux Pro → Camera on. Or use **Load a sample referral**. |
| “Not a Lux list” | You’re scanning the wrong QR. Use the QR from **List → Show QR**. |
| Client wants to tap around admin / points earn | Out of scope. Earn is off. This meeting is only the referral loop. |

**Backup if phones fail:** play the short screen recording the developer sent. Still walk the same script.

---

## Close the meeting (ask these)

1. Does this loop match how beauticians actually send clients in?
2. Is a cashier typing a code acceptable for a first store, or do they need Lightspeed to apply it automatically?
3. Who are the 3–5 beauticians for a closed beta at Decatur?
4. Can we put this on **their** phones next (Apple/Google accounts in the store’s name)?

Do not promise live earn, TapMango replacement, or other stores in this meeting.

---

## Screenshots (if you cannot install)

Phone-sized captures of every demo screen:

| File | Screen |
|---|---|
| `01-phone.png` | Sign in — phone |
| `02-otp.png` | Code `000000` |
| `03-home-empty.png` | Home, no referral yet |
| `04-scan.png` | Scan (camera is phone-only; sample button on web) |
| `05-account.png` | Account, tools off |
| `06-account-beautician.png` | Tools on, $12 store credit |
| `07-list.png` | Fake Decatur catalog |
| `07b-list-selected.png` | Two products on the list |
| `08-qr.png` | QR for that list |
| `09-home-deal.png` | Home with sample deal `LUX TEST 5` |

Folder: [`docs/demo-screenshots/`](./demo-screenshots/).
