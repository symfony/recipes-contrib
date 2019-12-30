const UniteCMSAdminEncore = require('./src/Bundle/AdminBundle/Resources/assets/webpack.config');
module.exports = UniteCMSAdminEncore.build(['./assets/js/unite-admin.js']).getWebpackConfig();
