<div align="center">

# 🛍️ Full-Stack E-Commerce App

### Flutter Mobile Application · Laravel 12 REST API · Laravel Sanctum

A mobile shopping experience powered by a **Flutter frontend** and a **Laravel backend**, featuring token-based authentication, product discovery, favorites, cart management, and cash-on-delivery checkout.

**Flutter** · **Dart** · **Laravel 12** · **PHP 8.2+** · **Sanctum** · **REST API** · **Dio** · **BLoC/Cubit**

</div>

---

## 📱 App Preview


## 📱 App Preview

<div align="center">
  <img
    src="586a2a1f-3b54-4a2c-bdb1-32563ab24b21.png"
    alt="Laravel and Flutter Full-Stack E-Commerce App"
    width="100%"
  />
</div>

---

## ✨ Features


> **Image setup:** Upload `586a2a1f-3b54-4a2c-bdb1-32563ab24b21.png` to the same directory as this `README.md` in your GitHub repository so the preview renders correctly.

## ✨ Features

### Flutter mobile app
- User registration and login through Laravel Sanctum.
- Product listing with search and category filtering.
- Product detail views showing description, price, and stock availability.
- Favorites and shopping-cart interactions.
- Checkout with delivery contact information and **cash on delivery (COD)**.
- Order confirmation UI.
- Token handling with `flutter_secure_storage`.
- HTTP integration using `dio` and state management using `flutter_bloc`.

### Laravel backend
- RESTful JSON API built with Laravel 12.
- Sanctum personal access tokens for authentication.
- Admin-only product create, update, and delete operations.
- Category listing and admin category creation.
- Product search, category filtering, and pagination.
- Transactional COD checkout with stock validation and deduction.
- Order item snapshots of product names and purchase prices.
- Order status lookup restricted to the order owner.

## 🧰 Technology Stack

| Layer | Technology |
|---|---|
| Mobile frontend | Flutter, Dart |
| State management | `flutter_bloc` (BLoC/Cubit) |
| API client | `dio` |
| Secure token storage | `flutter_secure_storage` |
| Local database dependency | `sqflite` |
| Backend | Laravel 12, PHP 8.2+ |
| Authentication | Laravel Sanctum 4 |
| Database | SQLite for local setup; Laravel supports other configured drivers |
| API format | JSON REST endpoints |

## 🏗️ Architecture

```text
┌──────────────────────────────┐
│        Flutter App           │
│  UI · BLoC/Cubit · Dio       │
│  Secure token storage       │
└──────────────┬───────────────┘
               │ HTTP + JSON
               │ Authorization: Bearer <token>
               ▼
┌──────────────────────────────┐
│       Laravel 12 API         │
│  routes/api.php              │
│  auth:sanctum · admin        │
│  Controllers · Validation    │
└──────────────┬───────────────┘
               ▼
┌──────────────────────────────┐
│         Eloquent ORM         │
│ Users · Categories · Products│
│ Orders · OrderItems          │
└──────────────┬───────────────┘
               ▼
         SQL Database
```

## 🔐 Authentication and Permissions

Users can register or log in to receive a Sanctum bearer token. The Flutter client sends that token in the `Authorization` header for protected requests.

```http
Authorization: Bearer YOUR_TOKEN
Accept: application/json
```

New users are non-admin by default. Admin middleware checks `is_admin` before permitting catalog modifications. Customers can only retrieve their own orders.

## 🔌 API Reference

All endpoints are relative to `/api`.

| Method | Endpoint | Access | Purpose |
|---|---|---|---|
| GET | `/hello` | Public | API connectivity check |
| POST | `/register` | Public | Register and receive token |
| POST | `/login` | Public | Log in and receive token |
| GET | `/user` | Authenticated | Current user |
| POST | `/logout` | Authenticated | Revoke current token |
| GET | `/categories` | Authenticated | List categories |
| POST | `/categories` | Admin | Create category |
| GET | `/products` | Authenticated | Search, filter, paginate products |
| GET | `/products/{product}` | Authenticated | Product details |
| POST | `/products` | Admin | Create product |
| PUT | `/products/{product}` | Admin | Update product |
| DELETE | `/products/{product}` | Admin | Delete product |
| POST | `/checkout` | Authenticated | Place COD order |
| GET | `/orders/{order}` | Owner only | Get order status and total |

**Example product query:**

```http
GET /api/products?search=watch&category_id=1&per_page=10&page=1
```

**Example login request:**

```json
{
  "email": "demo@example.com",
  "password": "secret123"
}
```

## 🛒 Checkout Workflow

The current backend supports **cash on delivery**. Card payments are not implemented.

```json
POST /api/checkout
{
  "payment_method": "cod",
  "phone": "01000000000",
  "address": "12 Example St",
  "city": "Cairo",
  "items": [
    { "product_id": 1, "qty": 2 },
    { "product_id": 2, "qty": 1 }
  ]
}
```

The server validates the request, aggregates duplicate product IDs, locks selected product rows within a database transaction, verifies stock, creates the order and order items, deducts stock, and calculates the total in cents. On failure, the transaction rolls back.

**Example successful response (`201 Created`):**

```json
{
  "order_id": 7,
  "status": "confirmed",
  "payment_method": "cod",
  "checkout_url": null
}
```

## 🗃️ Data Model

```text
User ───────< Order ───────< OrderItem >────── Product
                                               │
Category ─────────────────────────────────────< Product
```

- **User:** Account details, hashed password, admin flag, Sanctum tokens.
- **Category:** Name and optional image URL.
- **Product:** Category, name, description, price, stock, image URL.
- **Order:** Customer, status, payment method, total in cents, delivery details.
- **OrderItem:** Order reference, product reference, name/price snapshot, quantity.

## 🚀 Getting Started

### Prerequisites

- Flutter SDK compatible with Dart `^3.6.0`.
- Android Studio or VS Code and an Android emulator/device.
- PHP 8.2+, Composer, and a configured Laravel database.
- A copy of the Laravel API project and this Flutter frontend.

### 1. Run the Laravel API

From the **Laravel backend directory**:

```bash
composer install
cp .env.example .env
php artisan key:generate
# Configure DB_CONNECTION and other database settings in .env
php artisan migrate
php artisan db:seed
php artisan serve
```

On Windows PowerShell, replace `cp` with `Copy-Item .env.example .env` if needed.

> **Migration warning:** The analyzed backend archive contains repeated additions of `payment_method` and other order columns. Fresh migrations may fail until those migrations are reconciled. Do **not** run `migrate:fresh` against a database containing important data.

### 2. Run the Flutter app

From the **Flutter frontend directory**:

```bash
flutter pub get
flutter run
```

Configure the API base URL in your Dio client for your environment:

| Environment | Example base URL |
|---|---|
| Android emulator | `http://10.0.2.2:8000/api` |
| iOS simulator (same host) | `http://127.0.0.1:8000/api` |
| Physical device | `http://YOUR_COMPUTER_LAN_IP:8000/api` |
| Production | `https://your-domain.com/api` |

For physical-device testing, Laravel must listen on a reachable interface, and the computer's firewall must permit the connection. Prefer HTTPS in production. Android cleartext HTTP may require development-only network configuration.

**Example Dio integration:**

```dart
final dio = Dio(
  BaseOptions(baseUrl: 'http://10.0.2.2:8000/api'),
);

final response = await dio.post('/login', data: {
  'email': email,
  'password': password,
});

final token = response.data['token'] as String;
dio.options.headers['Authorization'] = 'Bearer $token';

final products = await dio.get('/products');
```

### 3. Generate the app icon (optional)

Place the icon at `lib/appicon.png`, then run:

```bash
dart run flutter_launcher_icons
```

### 4. Build an Android release APK

```bash
flutter build apk --release
```

Output: `build/app/outputs/flutter-apk/app-release.apk`.

Configure production signing and a production API URL before distributing the app.

## ⚠️ Current Limitations

- **Card payments:** The checkout endpoint rejects card payments (`422`); Paymob integration is a placeholder.
- **Webhooks:** A placeholder webhook method exists but has no registered route.
- **Order management:** The backend provides owner-only order lookup, not a full order-history or fulfillment system.
- **Migrations:** Duplicate order-column additions need to be fixed for clean database initialization.
- **Tests:** The analyzed backend archive does not contain dedicated authentication, catalog, or checkout feature tests.
- **Admin dashboard:** Admin APIs exist, but a separate admin dashboard is not established by the supplied source documentation.

## 🧪 Recommended Tests

- Register, login, invalid credentials, and logout token revocation.
- Reject non-admin catalog modifications.
- Search, category filtering, and pagination.
- COD checkout with correct total and stock deduction.
- Insufficient-stock rollback and duplicate product ID aggregation.
- Reject access to another user's order.
- Concurrent purchases against the production database engine.

## 🛣️ Roadmap

- [ ] Repair and verify the backend migration chain.
- [ ] Add Laravel feature tests for auth, admin access, and checkout.
- [ ] Add full order history and order lifecycle management.
- [ ] Implement verified online payment integration and webhooks.
- [ ] Build or document a separate admin dashboard.
- [ ] Improve deployment configuration, API security, and production monitoring.

## 🔒 Security Notes

Never commit `.env`, API credentials, database dumps, or personal access tokens. Use HTTPS for deployed APIs, keep tokens in secure storage, and review exposed secrets before publishing backend code. The analyzed backend archive contained sensitive local artifacts and should not be uploaded unchanged.

## 👨‍💻 Developer

**Ahmed Jaber Ahmed** — Flutter Developer

- [GitHub](https://github.com/AhmedJaberAhmed)
- [Portfolio](https://ahmedjaberahmed.github.io/Jaber-website/)
- [LinkedIn](https://www.linkedin.com/in/ahmedjaberahmed/)

---

> **Documentation scope:** Based on the supplied Laravel Sanctum E-Commerce API source-code analysis (21 October 2026) and Flutter UI screenshots. Backend behavior described here was not independently verified by running the API or automated tests. Screenshot paths are placeholders until image files are added to the repository.
