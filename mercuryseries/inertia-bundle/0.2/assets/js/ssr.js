import React from "react";
import { createInertiaApp } from "@inertiajs/react";
import createServer from "@inertiajs/react/server";
import ReactDOMServer from "react-dom/server";
import Layout from "@/components/Layout";
import "../styles/app.css";

const appName = "Symfony ❤️ Inertia.js";

createServer((page) =>
  createInertiaApp({
    page,
    render: ReactDOMServer.renderToString,
    title: (title) => (title ? `${title} | ${appName}` : appName),
    resolve: (name) => {
      const page = require(`./pages/${name}`).default;
      if (page.layout === undefined) {
        page.layout = Layout;
      }
      return page;
    },
    setup: ({ App, props }) => <App {...props} />,
  })
);
