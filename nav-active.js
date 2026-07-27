/* Marks the ac-nav__link matching the current page as aria-current="page",
 * which amber-theme.css / amber-console renders as inverse video — same
 * lit-key look as :hover. navbar.html is a single static include baked into
 * every page, so it has no way to know which link is "current" on its own. */
(function () {
  var here = location.pathname.split("/").pop() || "index.html";
  var links = document.querySelectorAll(".ac-nav__link");
  for (var i = 0; i < links.length; i++) {
    var href = links[i].getAttribute("href");
    if (href === here) {
      links[i].setAttribute("aria-current", "page");
    }
  }
})();
