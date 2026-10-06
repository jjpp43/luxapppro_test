/**
 * Xcode 26.2 rejects SWIFT_RETURNS_RETAINED on RuntimeScheduler constructors
 * in expo-modules-jsi 57.0.x. Remove it after install. Drop this when Expo ships a fix.
 */
const fs = require("fs");
const path = require("path");

const file = path.join(
  __dirname,
  "../node_modules/expo-modules-jsi/apple/Sources/ExpoModulesJSI-Cxx/include/RuntimeScheduler.h",
);

if (!fs.existsSync(file)) process.exit(0);

const before = fs.readFileSync(file, "utf8");
const after = before.replaceAll(
  "SWIFT_RETURNS_RETAINED RuntimeScheduler",
  "RuntimeScheduler",
);
if (after !== before) fs.writeFileSync(file, after);
