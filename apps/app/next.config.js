const bsconfig = require("./bsconfig.json");
const withImages = require("next-images");
const withPlugins = require("next-compose-plugins");
const withBundleAnalyzer = require("@next/bundle-analyzer")({
  enabled: process.env.ANALYZE === "true",
});
const transpileModules = ["bs-platform", ...bsconfig["bs-dependencies"]];
const withTM = require("next-transpile-modules")(transpileModules);

module.exports = withPlugins([
  [withBundleAnalyzer],
  [
    withImages({
      esModule: true,
      webpack(config) {
        return config;
      },
    }),
  ],
  [withTM()],
]);
