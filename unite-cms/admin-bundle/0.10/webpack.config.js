const UniteCMSAdminEncore = require('@unite/admin/Resources/assets/webpack.config');
module.exports = UniteCMSAdminEncore.build(['./assets/js/unite-admin.js']).getWebpackConfig();
