import React from "react";
import { Head } from "@inertiajs/react";

export default function HomePage({ name }) {
  return (
    <>
      <Head title="Home" />

      <h1>Hello, {name}!</h1>
    </>
  );
}
