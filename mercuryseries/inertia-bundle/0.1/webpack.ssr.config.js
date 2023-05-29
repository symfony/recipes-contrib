const Encore = require("@symfony/webpack-encore");
const FosRouting = require("fos-router/webpack/FosRouting");
const nodeExternals = require("webpack-node-externals");
const path = require("path");

if (!Encore.isRuntimeEnvironmentConfigured()) {
  Encore.configureRuntimeEnvironment(process.env.NODE_ENV || "dev");
}

Encore.addPlugin(new FosRouting())
  .setOutputPath("public/build-ssr/")
  .setPublicPath("/build-ssr")
  .enableReactPreset()
  .addAliases({
    "@": path.resolve("assets/js"),
    "@img": path.resolve("assets/img"),
  })
  .addEntry("ssr", "./assets/js/ssr.js")
  .disableSingleRuntimeChunk()
  .cleanupOutputBeforeBuild()
  .enableSourceMaps(!Encore.isProduction())
  .configureBabel((config) => {
    // config.plugins.push("@babel/a-babel-plugin");

    if (Encore.isProduction()) {
      config.plugins.push("transform-react-remove-prop-types");
    }
  })
  .configureBabelPresetEnv((config) => {
    config.useBuiltIns = "usage";
    config.corejs = "3.23";
  });

const config = Encore.getWebpackConfig();
config.externalsPresets = { node: true };
config.externals = [
  nodeExternals({
    allowlist: [/^@inertiajs/],
  }),
];
config.output.globalObject = "this";

module.exports = config;
