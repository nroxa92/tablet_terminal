# VillaOS Tablet - QA CHECKLIST
## Version: 1.0 | Date: 2026-01-10 | FAZA 4

---

## 📋 PRE-TEST SETUP

| # | Item | Status |
|---|------|--------|
| 1 | Tablet connected to WiFi | ☐ |
| 2 | Firebase project active | ☐ |
| 3 | Web Panel has test unit/owner | ☐ |
| 4 | Sentry DSN configured | ☐ |
| 5 | Debug build installed | ☐ |

**Test Unit Code:** `________________`
**Owner ID:** `________________`
**Cleaner PIN:** `________________`
**Master PIN:** `________________`

---

## 🚀 1. SETUP FLOW

| # | Test Case | Steps | Expected | ✓ |
|---|-----------|-------|----------|---|
| 1.1 | Fresh Install | Install app, open | Shows Setup screen | ☐ |
| 1.2 | Invalid Code | Enter "XXXXX" | Error message | ☐ |
| 1.3 | Valid Code | Enter valid unit code | Validates, goes to Welcome | ☐ |
| 1.4 | Persist on Restart | Kill app, reopen | Goes directly to Welcome (skip setup) | ☐ |

---

## 🏠 2. WELCOME SCREEN

| # | Test Case | Steps | Expected | ✓ |
|---|-----------|-------|----------|---|
| 2.1 | Display | Open Welcome | Shows villa name, weather | ☐ |
| 2.2 | Check-in Button | Tap "Check-In" | Goes to CheckIn Intro | ☐ |
| 2.3 | House Rules | Tap "House Rules" | Shows rules screen | ☐ |
| 2.4 | Chat | Tap "Chat" | Opens AI chat | ☐ |
| 2.5 | Screensaver | Wait 2 min idle | Screensaver activates | ☐ |
| 2.6 | Wake from Screensaver | Tap screen | Returns to Welcome | ☐ |

---

## 📋 3. CHECK-IN FLOW

| # | Test Case | Steps | Expected | ✓ |
|---|-----------|-------|----------|---|
| 3.1 | Intro Screen | Start check-in | Shows booking info, guest count | ☐ |
| 3.2 | Document Selection | Select ID type | Can choose Passport/ID Card | ☐ |
| 3.3 | Country Selection | Select country | Dropdown works | ☐ |
| 3.4 | Camera Opens | Proceed to scan | Rear camera, frame visible | ☐ |
| 3.5 | Auto-scan | Position document | Auto-captures every 1.5s | ☐ |
| 3.6 | MRZ Detection | Scan MRZ | Data populates, green checkmark | ☐ |
| 3.7 | Manual Capture | Tap "SLIKAJ" | Manual capture works | ☐ |
| 3.8 | Confirmation | After scan | Can edit extracted data | ☐ |
| 3.9 | Validation Error | Submit without name | Shows error dialog | ☐ |
| 3.10 | Multiple Guests | 2+ guests in booking | Loop repeats for each | ☐ |
| 3.11 | Success Screen | Complete all guests | Animated ✓, countdown | ☐ |
| 3.12 | Auto-redirect | After countdown | Returns to Welcome | ☐ |

---

## ✍️ 4. SIGNATURE

| # | Test Case | Steps | Expected | ✓ |
|---|-----------|-------|----------|---|
| 4.1 | Signature Pad | After guest data | Can sign with finger | ☐ |
| 4.2 | Clear Signature | Tap "Obriši" | Clears signature | ☐ |
| 4.3 | Submit | Tap "Potvrdi" | Uploads to Firebase Storage | ☐ |
| 4.4 | Verify in Firebase | Check Storage bucket | Signature PNG exists | ☐ |

---

## 🔒 5. KIOSK MODE

| # | Test Case | Steps | Expected | ✓ |
|---|-----------|-------|----------|---|
| 5.1 | Default State | Fresh install | UNLOCKED | ☐ |
| 5.2 | Remote Lock | Web Panel → Lock tablet | Tablet enters kiosk mode | ☐ |
| 5.3 | Home Button | Press Home (when locked) | Nothing happens / returns to app | ☐ |
| 5.4 | Back Button | Press Back (when locked) | Nothing happens | ☐ |
| 5.5 | Status Bar | Swipe down (when locked) | No access | ☐ |
| 5.6 | Remote Unlock | Web Panel → Unlock | Kiosk mode disabled | ☐ |

---

## 🔐 6. PIN & ADMIN

| # | Test Case | Steps | Expected | ✓ |
|---|-----------|-------|----------|---|
| 6.1 | Access PIN Screen | Dashboard → Staff Access | Shows PIN dialog | ☐ |
| 6.2 | Wrong PIN (1st) | Enter wrong PIN | "Invalid PIN (X remaining)" | ☐ |
| 6.3 | Wrong PIN (5x) | Enter wrong 5 times | Lockout activated | ☐ |
| 6.4 | Lockout Timer | During lockout | Shows countdown | ☐ |
| 6.5 | Lockout Expires | Wait 5 min | Can try again | ☐ |
| 6.6 | Cleaner PIN | Enter cleaner PIN | Goes to Cleaner Tasks | ☐ |
| 6.7 | Master PIN | Enter master PIN | Opens **Admin Menu** | ☐ |

---

## 🛠️ 7. ADMIN MENU

| # | Test Case | Steps | Expected | ✓ |
|---|-----------|-------|----------|---|
| 7.1 | Debug Panel | Tap "Debug Panel" | Opens Debug Screen | ☐ |
| 7.2 | Disable Kiosk | Tap "Disable Kiosk" | Confirms, disables 5 min | ☐ |
| 7.3 | Kiosk Auto-relock | Wait 5 min | Kiosk re-enables | ☐ |
| 7.4 | Factory Reset | Tap "Factory Reset" | Confirmation dialog | ☐ |
| 7.5 | Confirm Reset | Confirm reset | Clears data, goes to Setup | ☐ |

---

## 🐛 8. DEBUG PANEL

| # | Test Case | Steps | Expected | ✓ |
|---|-----------|-------|----------|---|
| 8.1 | Status Tab | Open Debug → Status | Shows device/kiosk/connectivity info | ☐ |
| 8.2 | Firebase Tab | Debug → Firebase | Shows live Firestore docs | ☐ |
| 8.3 | Storage Tab | Debug → Storage | Shows all Hive data | ☐ |
| 8.4 | Copy to Clipboard | Storage → Copy All | Copies dump | ☐ |
| 8.5 | Run All Tests | Tests → Run All | Executes all tests | ☐ |
| 8.6 | Individual Test | Tap play on one test | Runs single test | ☐ |
| 8.7 | Actions - Navigate | Actions → Go to Welcome | Navigates correctly | ☐ |
| 8.8 | Actions - Sentry | Actions → Send Test Error | Error in Sentry dashboard | ☐ |

---

## 🔥 9. FIREBASE SYNC

| # | Test Case | Steps | Expected | ✓ |
|---|-----------|-------|----------|---|
| 9.1 | Guest Subcollection | Complete check-in | Guests in `bookings/{id}/guests/` | ☐ |
| 9.2 | Signature URL | Check guest doc | `signatureUrl` is Storage URL (not base64) | ☐ |
| 9.3 | Tablet Heartbeat | Check `tablets/{id}` | `lastSeen` updates | ☐ |
| 9.4 | Real-time Sync | Change villa name in Panel | Tablet reflects change | ☐ |
| 9.5 | Booking Sync | Create booking in Panel | Tablet shows new booking | ☐ |

---

## 🌐 10. OFFLINE MODE

| # | Test Case | Steps | Expected | ✓ |
|---|-----------|-------|----------|---|
| 10.1 | Offline Indicator | Disable WiFi | Shows "Offline" indicator | ☐ |
| 10.2 | OCR Offline | Scan document offline | OCR works locally | ☐ |
| 10.3 | Queue Operations | Submit check-in offline | Queued for later | ☐ |
| 10.4 | Reconnect Sync | Enable WiFi | Queued ops sync | ☐ |

---

## 📊 11. SENTRY MONITORING

| # | Test Case | Steps | Expected | ✓ |
|---|-----------|-------|----------|---|
| 11.1 | Breadcrumbs | Complete check-in | Events visible in Sentry | ☐ |
| 11.2 | Error Capture | Force crash in Debug | Error in Sentry | ☐ |
| 11.3 | Tags | Check Sentry event | Has unit_id, owner_id tags | ☐ |
| 11.4 | User Context | Check Sentry | User context set | ☐ |

---

## 🧹 12. CLEANER FLOW

| # | Test Case | Steps | Expected | ✓ |
|---|-----------|-------|----------|---|
| 12.1 | Task List | Login with cleaner PIN | Shows cleaning tasks | ☐ |
| 12.2 | Check Tasks | Tap checkboxes | Tasks mark complete | ☐ |
| 12.3 | Submit | Complete all, submit | Confirmation, returns to Welcome | ☐ |
| 12.4 | Firebase Update | Check Firestore | Cleaning status updated | ☐ |

---

## ⚠️ 13. EDGE CASES

| # | Test Case | Steps | Expected | ✓ |
|---|-----------|-------|----------|---|
| 13.1 | No Booking | Remove all bookings | Shows "No active booking" | ☐ |
| 13.2 | Expired Booking | Past checkout date | Shows appropriate message | ☐ |
| 13.3 | Low Light OCR | Scan in dark room | Handles gracefully | ☐ |
| 13.4 | Blurry Document | Scan blurry doc | Retries or shows error | ☐ |
| 13.5 | Network Drop Mid-flow | Disconnect during check-in | Handles gracefully | ☐ |
| 13.6 | App Kill Mid-flow | Kill app during check-in | Resumes or restarts cleanly | ☐ |

---

## 📝 NOTES & ISSUES

```
Issue #:
Description:
Steps to Reproduce:
Expected:
Actual:
Screenshot/Video:
```

---

## ✅ SIGN-OFF

| Role | Name | Date | Signature |
|------|------|------|-----------|
| QA Tester | | | |
| Developer | | | |
| Product Owner | | | |

---

**Test Environment:**
- Device: ________________
- Android Version: ________________
- App Version: ________________
- Firebase Project: ________________