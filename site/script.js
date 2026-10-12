// Loaded in <head> so a saved theme is applied before the page paints.
(function () {
  const root = document.documentElement;

  try {
    const saved = localStorage.getItem("theme");
    if (saved === "light" || saved === "dark") root.setAttribute("data-theme", saved);
  } catch (e) {
    // Storage blocked (private mode, etc.): fall back to the system preference.
  }

  document.addEventListener("DOMContentLoaded", function () {
    // Theme toggle
    const themeBtn = document.querySelector(".theme-toggle");
    if (themeBtn) {
      themeBtn.addEventListener("click", function () {
        const current =
          root.getAttribute("data-theme") ||
          (window.matchMedia("(prefers-color-scheme: dark)").matches ? "dark" : "light");
        const next = current === "dark" ? "light" : "dark";
        root.setAttribute("data-theme", next);
        try {
          localStorage.setItem("theme", next);
        } catch (e) {
          // Not persisted; the toggle still works for this visit.
        }
      });
    }

    // Mobile menu
    const navBtn = document.querySelector(".nav-toggle");
    const nav = document.getElementById("site-nav");
    if (navBtn && nav) {
      const setOpen = function (open) {
        navBtn.setAttribute("aria-expanded", String(open));
        nav.classList.toggle("open", open);
      };
      navBtn.addEventListener("click", function () {
        setOpen(navBtn.getAttribute("aria-expanded") !== "true");
      });
      nav.addEventListener("click", function (event) {
        if (event.target.closest("a")) setOpen(false);
      });
      document.addEventListener("keydown", function (event) {
        if (event.key === "Escape") setOpen(false);
      });
    }

    // Footer year
    const year = document.getElementById("year");
    if (year) year.textContent = String(new Date().getFullYear());
  });
})();
