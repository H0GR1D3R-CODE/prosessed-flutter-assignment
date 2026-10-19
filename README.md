# ShopSphere

A Flutter shopping app built on the [DummyJSON](https://dummyjson.com) API, for the Prosessed Flutter Developer Intern assignment.

Sign in, browse a live catalogue with search, categories and sorting, open a product, build a cart that survives restarts, place a (simulated) order, and manage a profile. It adapts from a phone to a tablet with a master–detail layout, speaks English and Hindi, has a dark theme, shows what it can while offline, and turns every network failure into a state the shopper can act on.

| Download | Link |
| --- | --- |
| Release APK (`ShopSphere_NebinStanly_v1.0.0.apk`, 60 MB, Android 8.0+) | `<ADD GITHUB RELEASE LINK>` |
| Demo video (3 min 43 s: all features, 6 error scenarios, tablet and landscape) | `<ADD GOOGLE DRIVE LINK>` |
| Submission folder (APK, video, 27 screenshots) | `<ADD GOOGLE DRIVE FOLDER LINK>` |

> Built and checked with Flutter 3.47.7 / Dart 3.13.5. 324 tests pass, `flutter analyze` reports no issues, and line coverage over all of `lib/` is 94.9%.

## 1. Screenshots

**Phone** (release build on an Android 16 emulator, live DummyJSON data)

| Splash | Validation | Wrong password | Home: deal of the day |
| --- | --- | --- | --- |
| <img src="docs/screenshots/a01-splash.jpg" width="180"> | <img src="docs/screenshots/a02-validation.jpg" width="180"> | <img src="docs/screenshots/a03-wrong-password.jpg" width="180"> | <img src="docs/screenshots/a04-home-deal.jpg" width="180"> |

| Shelves and grid | Search suggestions | Category and sort | Quick add |
| --- | --- | --- | --- |
| <img src="docs/screenshots/a05-shelves.jpg" width="180"> | <img src="docs/screenshots/a06-search.jpg" width="180"> | <img src="docs/screenshots/a07-category.jpg" width="180"> | <img src="docs/screenshots/a08-quick-add.jpg" width="180"> |

| Details | Cart | Checkout | Order placed |
| --- | --- | --- | --- |
| <img src="docs/screenshots/a09-details.jpg" width="180"> | <img src="docs/screenshots/a10-cart.jpg" width="180"> | <img src="docs/screenshots/a11-checkout.jpg" width="180"> | <img src="docs/screenshots/a12-order-placed.jpg" width="180"> |

| Order history | Offline | Profile (dark, Hindi) | Error lab |
| --- | --- | --- | --- |
| <img src="docs/screenshots/a13-orders-buy-again.jpg" width="180"> | <img src="docs/screenshots/b01-offline.jpg" width="180"> | <img src="docs/screenshots/b03-hindi.jpg" width="180"> | <img src="docs/screenshots/b04-error-lab.jpg" width="180"> |

| Slow network handled | Session ended |
| --- | --- |
| <img src="docs/screenshots/b05-error-result.jpg" width="180"> | <img src="docs/screenshots/b06-session-ended.jpg" width="180"> |

**Tablet, landscape** (master–detail, resizable and collapsible panels)

| Home with a details pane | Product details beside the list |
| --- | --- |
| <img src="docs/screenshots/t01-landscape-home.jpg" width="420"> | <img src="docs/screenshots/t02-landscape-details.jpg" width="420"> |

| Details pane collapsed | Cart with its summary |
| --- | --- |
| <img src="docs/screenshots/t03-landscape-collapsed.jpg" width="420"> | <img src="docs/screenshots/t04-landscape-cart.jpg" width="420"> |

| Summary tucked away | Profile |
| --- | --- |
| <img src="docs/screenshots/t05-landscape-cart-collapsed.jpg" width="420"> | <img src="docs/screenshots/t06-landscape-profile.jpg" width="420"> |

**Tablet, portrait**

| Shop: navigation rail, wider grid | Profile |
| --- | --- |
| <img src="docs/screenshots/t07-portrait-shop.jpg" width="260"> | <img src="docs/screenshots/t08-portrait-profile.jpg" width="260"> |

All 27 screenshots are in [`docs/screenshots`](docs/screenshots).

## 2. Features

**Required**

- [x] Splash screen that checks the stored session and routes to Home or Login
- [x] Login with validation, show/hide password, a loading state, tokens in secure storage, and a clear message for `400 Invalid credentials`
- [x] Product list: responsive grid with thumbnail, title, price, discount and rating
- [x] Infinite scroll (`limit`/`skip`, page size 20) and pull-to-refresh
- [x] Category chips loaded from the API, search with a 400 ms debounce, sort by price, rating or title
- [x] Shimmer skeleton while loading, and an empty state
- [x] Product details: image carousel with indicator, brand (and a missing brand), price and discount, rating, stock, description, reviews
- [x] Add to cart with a quantity, disabled when out of stock, and a clear page for `404`
- [x] Cart: add, remove (with undo), change quantity, subtotal, discount and total, saved on the device, live badge on the tab
- [x] Place order (`POST /carts/add`), success screen, cart cleared
- [x] Profile from `GET /auth/me` (avatar, name, email, phone, address), logout clears the tokens
- [x] A rejected session (`401`/`403` after a failed refresh) signs the user out with a message

**Bonus**

- [x] Token-refresh interceptor: a `401` refreshes the token once and retries the request
- [x] Light, dark or system theme, remembered across launches
- [x] Wishlist (heart on every card and details page, a Saved tab)
- [x] Offline mode: the last product page stays on screen with a banner and a retry
- [x] Widget tests (and app-level flow tests that run the real app)
- [x] English and Hindi, switchable in the profile
- [x] GitHub Actions: format check, `flutter analyze` and `flutter test` on every push

**Also**

- [x] Responsive on three tiers (see [Architecture](#5-architecture))
- [x] An in-app **Error lab** (Profile → Developer tools) that triggers a server error, a 404, a slow response, a timeout, an expired token and a rejected refresh token, so every failure path can be shown on demand
- [x] **A livelier home page**: an offers carousel that slides on its own (today's best deal, a promo code you can copy, a giving nudge), then "Deals worth grabbing" and "Loved by shoppers" shelves, then the full grid. The shelves are built from products already on screen, so they cost no extra requests, and they give way to plain results when you search or pick a category
- [x] **Product photos on a studio backdrop**: a softly lit, barely tinted paper backdrop with a contact shadow, instead of a saturated shape behind each photo
- [x] **Quick add**: a round + on every in-stock photo (cards and shelves) adds one without opening the product, and the photo flies to the cart tab
- [x] **Buy again**: an order in the history goes back into the cart in one tap
- [x] **Promo codes at checkout** (`WELCOME10`, `SAVE5`, `ORBIT20`), with minimum spends and a cap, suggestions you can tap, and clear messages for a wrong code or one the order is too small for
- [x] **A donation at checkout**: round up to the next dollar, or add $1, $2 or $5. Demo only: nothing is really charged or donated
- [x] **Keep me signed in** on the sign-in form, with the last username filled in. Unticking it ends the session when the app is closed, which is what you want on a shared device
- [x] A splash with a progress bar and tagline, skeletons shaped like the page that replaces them, and the cart showing what you are saving
- [x] **Order history** (Profile → Your orders): every placed order with its items, total and date, kept across restarts
- [x] **Smart search**: recent searches and matching categories as you type, a "Search for …" row so Enter always searches what you typed, and a **/** shortcut on web and desktop that jumps to the box
- [x] **Recently viewed** shelf on the shop page, clearable
- [x] **Resizable panels** on tablet, desktop and web: drag the divider or tap the chevron to collapse the details pane (shop) or the summary pane (cart)
- [x] **Photos that recover**: a failed image retries twice, then becomes a tap-to-reload tile instead of a broken icon
- [x] Motion: page transitions (rise, slide, zoom, fade), a product that flies into the cart, animated totals, staggered reveals, a confetti order screen, hero transitions, and reduced-motion support
- [x] Web build with a proper favicon, install icons and manifest
- [x] An orbit-themed visual identity, 48 dp touch targets, screen-reader labels, and no overflow at 1.3× text

## 3. Tech stack

| Area | Choice | Version |
| --- | --- | --- |
| Framework | Flutter / Dart | 3.47.7 stable / 3.13.5 |
| State management | `flutter_bloc` (Cubit) | 9.1.1 |
| Value equality | `equatable` | 3.0.0 |
| Dependency injection | `get_it` | 9.3.0 |
| Navigation | `go_router` | 18.1.0 |
| HTTP | `dio` | 5.11.1 |
| Secure storage (tokens) | `flutter_secure_storage` | 11.2.0 |
| Local storage (cart, wishlist, settings, cache) | `shared_preferences` | 2.5.6 |
| Images | `cached_network_image` | 4.0.4 |
| Localisation | `flutter_localizations`, `intl` | SDK, 0.20.3 |
| Tests | `flutter_test`, `bloc_test`, `mocktail` | SDK, 10.0.0, 1.0.5 |
| Lints | `flutter_lints` (plus strict analysis) | 6.0.0 |
| Icons | `flutter_launcher_icons` | 0.14.4 |

Fonts: Unbounded (display) and DM Sans (text), bundled under the SIL Open Font License ([notice](assets/fonts/LICENSE.md)).

## 4. Getting started

Requirements: Flutter 3.47.7 (Dart 3.13.5) and, for Android, JDK 17 and the Android SDK.

```bash
flutter --version     # Flutter 3.47.7 • channel stable • Dart 3.13.5
flutter pub get
flutter run           # a connected Android device or emulator
```

Build the release APK:

```bash
flutter build apk --release
# build/app/outputs/flutter-apk/app-release.apk
```

No API key, token or `.env` file is needed: DummyJSON is public. The app calls these endpoints (all of them checked live):
`POST /auth/login`, `GET /auth/me`, `POST /auth/refresh`, `GET /products` (with `limit`, `skip`, `sortBy`, `order`), `GET /products/search`, `GET /products/categories`, `GET /products/category/{slug}`, `GET /products/{id}`, `POST /carts/add`, plus `GET /http/500` and `GET /http/404` for the Error lab.

Useful commands:

```bash
dart format .                 # format
flutter analyze               # static analysis (strict mode, no issues)
flutter test                  # all 324 tests
bash tool/coverage.sh         # honest coverage, see Testing
flutter gen-l10n              # only after editing lib/l10n/*.arb (output is committed)
```

The release build is signed with the **debug key**, because no keystore is committed. It installs and runs fine for review; a Play Store release would need a real upload key.

## 5. Architecture

Feature-first clean architecture. Each feature has `data`, `domain` and `presentation`, and dependencies point inward: **presentation → domain ← data**. `domain` is pure Dart (no Flutter, no Dio).

```mermaid
flowchart LR
  subgraph Presentation
    W[Widgets / Pages] --> C[Cubits]
  end
  subgraph Domain["Domain (pure Dart)"]
    U[Use cases] --> RI[Repository interfaces]
    E[Entities]
  end
  subgraph Data
    R[Repository implementations] --> DS[Data sources]
    DS --> M[Models / JSON]
  end
  C --> U
  R -. implements .-> RI
  DS --> API[(DummyJSON)]
  DS --> ST[(Secure storage / SharedPreferences)]
```

**Folder structure**

```text
lib/
├── main.dart, app.dart               # entry point, providers, theme, locale, router
├── core/
│   ├── di/                           # get_it registrations (one place wires everything)
│   ├── error/                        # exceptions, Failures, guard(): the only exception → Failure mapper
│   ├── result/                       # Result<T> (success or failure)
│   ├── network/                      # ApiClient, dio factory, auth interceptor, error mapper, session events
│   ├── router/                       # go_router routes, redirects, shell
│   ├── theme/                        # Material 3 theme, colours, typography, spacing
│   ├── utils/                        # breakpoints, formatters, debouncer, JSON readers
│   ├── presentation/                 # failure → localised wording
│   └── widgets/                      # shared UI: orbs, buttons, photos, resizable split, motion, state views
├── features/
│   ├── auth/        data/ domain/ presentation/    # login, session, logout
│   ├── products/    data/ domain/ presentation/    # list, search, details
│   ├── cart/        data/ domain/ presentation/    # cart, checkout (promo codes, donation), order
│   ├── wishlist/    data/ domain/ presentation/
│   ├── orders/      data/ domain/ presentation/    # local order history (with code and donation)
│   ├── discover/    data/ domain/ presentation/    # recent searches, recently viewed
│   ├── settings/    data/ domain/ presentation/    # theme and language
│   ├── profile/     presentation/
│   ├── dev_tools/   data/ domain/ presentation/    # the Error lab
│   ├── shell/       presentation/                  # bottom bar / rail
│   └── splash/      presentation/
└── l10n/                             # app_en.arb, app_hi.arb (generated code is committed)
test/                                 # mirrors lib/, plus helpers/, fixtures/, and app/ flow tests
tool/                                 # coverage scripts and the icon generator
```

**How a request flows** (loading the product list):

1. `ProductListPage` calls `ProductListCubit.load()`.
2. The Cubit runs a use case; the use case calls the `ProductRepository` **interface**.
3. `ProductRepositoryImpl` calls `ProductRemoteDataSource`, which calls `ApiClient` (one shared Dio).
4. The Dio interceptors run: debug-only logging, then `AuthInterceptor` (adds the bearer token; on a `401` it refreshes once and replays the request).
5. The JSON becomes a model, then a pure-Dart entity. Anything that throws is mapped by `guard()` into a typed `Failure`.
6. The repository returns a `Result<ProductPage>`; the Cubit emits a sealed state (loading, success, empty or error) and the page rebuilds.

**Responsive layout**

| Width | Layout |
| --- | --- |
| compact, under 600 | 2-column grid, bottom navigation bar |
| medium, 600–1024 | 3–4 column grid, navigation rail |
| expanded, over 1024 | navigation rail with **master–detail**: list on the left, details on the right |

## 6. State management: Cubit (`flutter_bloc`)

- A Cubit is a small class that holds a state and exposes methods that emit new states, with no event classes to write for these "do X, get a new state" screens.
- States are **sealed classes** (and `Equatable`), so the compiler forces every screen to handle loading, success, empty and error, and identical states don't rebuild the UI.
- State transitions are plain data, so `bloc_test` can assert the exact **sequence** of states each action produces.
- App-wide state (`AuthCubit`, `CartCubit`, `WishlistCubit`, `SettingsCubit`, `OrdersCubit`, `SearchHistoryCubit`, `RecentlyViewedCubit`). The checkout page also has its own short-lived `CheckoutExtrasCubit` for the code and donation is provided once at the top; screen state is created per screen from `get_it`.
- Only this one solution is used, so there is a single way to read and test state across the app.

## 7. Error handling

- Low-level code throws typed exceptions. **`guard()` is the only place** that turns them into `Failure`s (`NetworkFailure`, `TimeoutFailure`, `ServerFailure`, `NotFoundFailure`, `InvalidCredentialsFailure`, `SessionExpiredFailure`, ...). Repositories return `Result<T>`, so nothing throws past the data layer.
- Failures carry no user-facing text. `FailureCopy` maps each one to localised wording and an icon, so a failure reads the same everywhere and is translated.
- Every network screen has **loading** (shimmer), **empty**, **error with a Retry button** and **success**.
- One Dio client with connect, send and receive timeouts. Logging is on in debug builds only and never prints headers or bodies (they hold tokens).
- `401`: refresh the token once and retry. If the refresh itself is refused (`401`/`403`), the tokens are cleared and the user lands on the login screen with a "session ended" notice.
- Offline: the last default product page and the categories are cached, so a failed load shows them with a banner and a retry instead of an empty error.
- You can see all of this live: **Profile → Developer tools → Error lab**.

## 8. Testing

**324 tests, all passing.** Honest line coverage is **94.9%** (6,090 of 6,417 lines in `lib/`, generated localisation code excluded).

```bash
flutter test
bash tool/coverage.sh      # measures all of lib/, then prints a per-folder summary
```

Flutter's own `--coverage` only lists files that some test imports, which hides untested screens and flatters the total. `tool/coverage.sh` imports every file first, so untested code counts as 0%.

| Area | What is covered |
| --- | --- |
| Domain and use cases | cart maths (whole cents, no float drift), merging, stock caps, wishlist and settings rules, validators, promo-code and round-up maths, which products make the home shelves, the remember-me rules |
| Repositories | success, server failure and network failure for auth, products (including offline fallback), cart |
| Cubits (`bloc_test`) | exact state sequences for login, session, product list (search debounce, stale answers, pagination, refresh), details, categories, cart, checkout |
| JSON parsing | models parsed from **real saved API responses** in `test/fixtures` |
| Network | the auth interceptor (refresh once, replay, forced expiry) and the Dio error mapper |
| Widgets | error and empty views, quantity stepper limits, buttons, badges, the login form, photo retry and fallback, the resizable split, motion helpers |
| App-level flows | the **real app** (router and DI) against a scripted API: sign in and buy, the home carousel and shelves, promo codes and donations at checkout, staying signed in (or not), order history, search suggestions, recently viewed, search/sort/category, errors and retry, offline, wishlist, theme, language, profile, session expiry, every Error-lab scenario, tablet, landscape and 1.3× text |

Mocks use `mocktail`. The app-level tests swap only the network (a fake HTTP adapter) and storage; everything else is the production code.

Running the release build on emulators found problems the unit tests could not, and the app-level tests then caught several more (a snackbar that never dismissed, an R8 build that never left the splash, a keyboard that returned after leaving the search box, touch targets under 48 dp, and two overflows at 1.3× text on a 320 dp phone). All are fixed, and each has a regression test except the R8 one, which is a build setting.

## 9. Test credentials

DummyJSON's test account (also behind the "Use the demo account" button on the login screen):

```text
username: emilys
password: emilyspass
```

## 10. Assumptions and trade-offs

- **Orders are simulated.** `POST /carts/add` confirms an order but stores nothing. The success screen shows the order id the API returns and the app's own total.
- **Totals are exact to the cent.** The app computes in whole cents; DummyJSON rounds its totals, so the two can differ by a cent. The app's figure is the one shown.
- **Minimum order quantity is shown, not enforced.** The API's `minimumOrderQuantity` (for example 48) would make a normal demo cart impossible, so the details page lists it and the cart does not block on it.
- **Offline support is deliberately narrow:** the default first page and the categories are cached. Search results, other sorts and details pages are not.
- **Token refresh is a "check, then refresh" guard, not a lock.** A request that was sent with a stale token re-reads the stored one first, which avoids most duplicate refreshes. Two requests failing at the exact same instant could still both refresh.
- **Release signing and shrinking.** The release APK uses the debug key (no keystore is committed) and R8 shrinking is switched off because it broke `shared_preferences` on a device. The APK is larger as a result (60 MB, all ABIs).
- **Tested on emulators** (Android 16, phone and tablet), not on a physical device, and not on an API 26 device. iOS scaffolding exists but was not built or tested.
- **Hindi strings should be reviewed by a native speaker.** They render correctly, but wording has not had a native review.
- **Currency is US dollars.** DummyJSON prices are dollars and the brief does not ask for another currency, so the app shows them as they come instead of inventing an exchange rate.
- **Promo codes and the donation are the app's own.** DummyJSON has no coupons and no payments. The three codes and the "Orbit Trees" donation are demo features: the discount and the donation are worked out on the device and kept with the order, but nothing is charged, donated or sent to the API.
- **"Keep me signed in" is applied at launch.** Unticked, the session is cleared the next time the app starts; it does not time out while the app is open.
- Wishlist, cart, settings, order history, recent searches and recently viewed products live on the device, per signed-in user. Nothing is synced to a server, because DummyJSON stores nothing.
- **Order history is local.** An order is saved on the device when `POST /carts/add` succeeds (the latest 50 are kept). It is a record of what this app placed, not data read back from the API.

## 11. Author

**Nebin Stanly**

- Email: nebinstanly12@gmail.com
- LinkedIn: `<ADD LINKEDIN URL>`

## 12. AI tools used

I used **Claude Code (Anthropic)** as an AI pair-programmer on this project. It generated a large part of the implementation, the tests, the visual design, the scripts, and the first draft of this README, and it was also used to debug issues found while running the app. I set the scope and priorities, ran the app and the tests, reviewed the changes, and made the product decisions. The screenshots and the demo video are real recordings of the release APK running on Android emulators. All commits are authored by me.

---

Data is from [DummyJSON](https://dummyjson.com), which is a test API: products, users and orders are fake.
