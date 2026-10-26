# myapp

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Firebase catalog and reservations

The Flutter app connects to the `myapp-b43d6` Firebase project. It reads
active products in real time from Firestore's `products` collection. When a
customer places a reservation, the app writes an order to the private
`reservations` collection. Firestore security rules verify each product is
active and that the submitted price and line total match the catalog. The app
does not process online payments or require Cloud Functions for reservations.

To initialize or deploy the Firebase data layer:

1. Enable Cloud Firestore in the Firebase console for `myapp-b43d6`.
2. Deploy the rules. Clients can read active products but cannot edit products
   or read/write reservations:

   ```powershell
   firebase.cmd deploy --only firestore:rules --project myapp-b43d6
   ```

3. Seed the initial product documents. Authenticate Google Application Default
   Credentials with an account authorized to write Firestore, then run:

   ```powershell
   gcloud.cmd auth application-default login
   cd functions
   npm.cmd install
   npm.cmd run seed:catalog -- --project=myapp-b43d6
   cd ..
   ```

   The seed command merges the initial products into `products`. To manage the
   live catalog later, edit documents in the Firebase console. Set `active` to
   `false` to hide a product without deleting it. Documents need `name`
   (string), `category` (string), `price` (integer in PHP), `size` (string),
   `condition` (string), `imageUrl` (string), `tint` (six-digit hex string),
   `sortOrder` (integer), and `active` (boolean).

4. If you maintain the optional callable in `functions/index.js`, deploying
   Cloud Functions requires the Firebase project to use the Blaze
   (pay-as-you-go) plan. The app's reservation flow itself uses Firestore and
   does not require that callable.
