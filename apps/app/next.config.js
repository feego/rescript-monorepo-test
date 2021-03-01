const bsconfig = require("./bsconfig.json");
const withImages = require("next-images");
const withPlugins = require("next-compose-plugins");
const withBundleAnalyzer = require("@next/bundle-analyzer")({
  enabled: process.env.ANALYZE === "true",
});
const transpileModules = ["bs-platform", ...bsconfig["bs-dependencies"]];
// const withTM = require("@weco/next-plugin-transpile-modules");
const withTM = require("next-transpile-modules")(transpileModules);
// const withTM = require("@module-federation/next-transpile-modules")(transpileModules, { debug: true });

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
  // [
  //   withTM({
  //     transpileModules,
  //   }),
  // ],
  [
    withTM({
      future: {
        webpack5: false,
      },
    }),
  ],
  {
    future: {
      webpack5: false,
    },
  },
]);
