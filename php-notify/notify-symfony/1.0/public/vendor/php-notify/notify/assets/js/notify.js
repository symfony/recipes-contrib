/*!
 * PHPNotify js 1.0.0
 * https://github.com/php-notify/notify
 * @license MIT licensed
 *
 * Copyright (C) 2020 Younes KHOUBZA
 */
(function (root, factory) {
    if (typeof define === 'function' && define.amd) {
        define([], factory(root));
    } else if (typeof exports === 'object') {
        module.exports = factory(root);
    } else {
        root.PHPNotify = factory(root);
    }
})(typeof global !== 'undefined' ? global : typeof window !== 'undefined' ? window : this, function (window) {

    'use strict';

    var exports = {};

    exports.render = function (_settings) {
        var settings = Object.assign({}, {
            scripts: [],
            styles: [],
            options: [],
            notifications: [],
        }, _settings);

        exports.addStyles(settings.styles, function () {
            exports.addScripts(settings.scripts, function () {
                var script = '';

                settings.options.forEach(function (option) {
                    script += option + "\n";
                });

                script += "\n\n";

                settings.notifications.forEach(function (notification) {
                    script += notification.code + "\n";
                });

                exports.parseScript(script);
            });
        });
    };

    exports.addStyles = function (urls, callback) {
        if (0 === urls.length) {
            if ("function" === typeof callback) {
                callback();
            }

            return this;
        }

        if (null !== document.querySelector(`link[href='${urls[0]}']`)) {
            return exports.addStyles(urls.slice(1), callback);
        }

        var tag = document.createElement('link');

        tag.href = urls[0];
        tag.type = 'text/css';
        tag.rel = 'stylesheet';
        tag.onload = function () {
            exports.addStyles(urls.slice(1), callback);
        };

        document.head.appendChild(tag);

        return this;
    };

    exports.addScripts = function (urls, callback) {
        if (0 === urls.length) {
            if ("function" === typeof callback) {
                callback();
            }

            return this;
        }

        if (null !== document.querySelector(`script[src='${urls[0]}']`)) {
            return exports.addScripts(urls.slice(1), callback);
        }

        var tag = document.createElement('script');

        tag.src = urls[0];
        tag.type = 'text/javascript';
        tag.onload = function () {
            exports.addScripts(urls.slice(1), callback);
        };

        document.body.appendChild(tag);

        return this;
    };

    exports.parseScript = function (script) {
        var tag = document.createElement('script');

        tag.type = "text/javascript";
        tag.text = script;

        document.body.appendChild(tag);

        return this;
    };

    return exports;
});
