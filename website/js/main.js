/* ManifestAI marketing site — hand-rolled interactions & animations.
   No frameworks. Respects prefers-reduced-motion throughout. */
(function () {
  "use strict";

  var reduceMotion = window.matchMedia("(prefers-reduced-motion: reduce)").matches;

  /* --------------------------------------------------------------------
     Sticky nav: shrink + blur on scroll, mobile menu toggle
     -------------------------------------------------------------------- */
  var nav = document.querySelector(".site-nav");
  var navToggle = document.querySelector(".nav-toggle");
  var navLinks = document.querySelector(".nav-links");

  function onScrollNav() {
    if (window.scrollY > 24) {
      nav.classList.add("scrolled");
    } else {
      nav.classList.remove("scrolled");
    }
  }
  onScrollNav();
  window.addEventListener("scroll", onScrollNav, { passive: true });

  if (navToggle && navLinks) {
    navToggle.addEventListener("click", function () {
      var isOpen = navLinks.classList.toggle("open");
      navToggle.setAttribute("aria-expanded", isOpen ? "true" : "false");
    });
    navLinks.querySelectorAll("a").forEach(function (link) {
      link.addEventListener("click", function () {
        navLinks.classList.remove("open");
        navToggle.setAttribute("aria-expanded", "false");
      });
    });
  }

  /* --------------------------------------------------------------------
     Scroll-reveal via IntersectionObserver (staggered by nth-child index)
     -------------------------------------------------------------------- */
  var revealEls = document.querySelectorAll(".reveal, .reveal-scale");
  if ("IntersectionObserver" in window && revealEls.length) {
    var io = new IntersectionObserver(
      function (entries) {
        entries.forEach(function (entry) {
          if (entry.isIntersecting) {
            var el = entry.target;
            var parent = el.parentElement;
            var siblings = parent ? Array.prototype.slice.call(parent.children) : [];
            var idx = siblings.indexOf(el);
            el.style.transitionDelay = reduceMotion ? "0ms" : Math.min(idx, 6) * 90 + "ms";
            el.classList.add("in-view");
            io.unobserve(el);
          }
        });
      },
      { threshold: 0.15, rootMargin: "0px 0px -8% 0px" }
    );
    revealEls.forEach(function (el) { io.observe(el); });
  } else {
    revealEls.forEach(function (el) { el.classList.add("in-view"); });
  }

  /* --------------------------------------------------------------------
     Starfield canvas — twinkling particles + slow parallax drift
     -------------------------------------------------------------------- */
  var canvas = document.getElementById("starfield");
  if (canvas && canvas.getContext) {
    var ctx = canvas.getContext("2d");
    var stars = [];
    var width, height, dpr;

    function resize() {
      dpr = Math.min(window.devicePixelRatio || 1, 2);
      width = canvas.clientWidth;
      height = canvas.clientHeight;
      canvas.width = width * dpr;
      canvas.height = height * dpr;
      ctx.setTransform(dpr, 0, 0, dpr, 0, 0);
      seedStars();
    }

    function seedStars() {
      var count = Math.min(160, Math.floor((width * height) / 9000));
      stars = [];
      for (var i = 0; i < count; i++) {
        stars.push({
          x: Math.random() * width,
          y: Math.random() * height,
          r: Math.random() * 1.4 + 0.3,
          baseAlpha: Math.random() * 0.5 + 0.25,
          twinkleSpeed: Math.random() * 0.015 + 0.004,
          phase: Math.random() * Math.PI * 2,
          driftY: Math.random() * 0.06 + 0.01,
          gold: Math.random() < 0.12
        });
      }
    }

    var t = 0;
    function draw() {
      ctx.clearRect(0, 0, width, height);
      for (var i = 0; i < stars.length; i++) {
        var s = stars[i];
        var alpha = s.baseAlpha + Math.sin(t * s.twinkleSpeed + s.phase) * 0.35;
        alpha = Math.max(0.05, Math.min(1, alpha));
        ctx.beginPath();
        ctx.arc(s.x, s.y, s.r, 0, Math.PI * 2);
        ctx.fillStyle = s.gold
          ? "rgba(252, 212, 113, " + alpha + ")"
          : "rgba(247, 243, 255, " + alpha + ")";
        ctx.fill();

        if (!reduceMotion) {
          s.y -= s.driftY;
          if (s.y < -4) { s.y = height + 4; s.x = Math.random() * width; }
        }
      }
      t += 1;
      raf = requestAnimationFrame(draw);
    }

    var raf;
    var visible = true;
    var ro = window.ResizeObserver ? new ResizeObserver(resize) : null;
    resize();
    if (ro) ro.observe(canvas); else window.addEventListener("resize", resize);

    document.addEventListener("visibilitychange", function () {
      visible = document.visibilityState === "visible";
      if (visible && !raf) draw();
      if (!visible && raf) { cancelAnimationFrame(raf); raf = null; }
    });

    if (reduceMotion) {
      // Draw a single static frame, no animation loop.
      draw = (function (orig) {
        return function () {
          ctx.clearRect(0, 0, width, height);
          for (var i = 0; i < stars.length; i++) {
            var s = stars[i];
            ctx.beginPath();
            ctx.arc(s.x, s.y, s.r, 0, Math.PI * 2);
            ctx.fillStyle = s.gold
              ? "rgba(252, 212, 113, " + s.baseAlpha + ")"
              : "rgba(247, 243, 255, " + s.baseAlpha + ")";
            ctx.fill();
          }
        };
      })(draw);
      draw();
    } else {
      draw();
    }
  }

  /* --------------------------------------------------------------------
     Hero parallax — phone + owl react gently to pointer position
     -------------------------------------------------------------------- */
  if (!reduceMotion) {
    var heroVisual = document.querySelector(".hero-visual");
    var phoneEl = document.querySelector(".phone-parallax");
    var owlEl = document.querySelector(".hero-owl");
    if (heroVisual && (phoneEl || owlEl)) {
      var rect = null;
      heroVisual.addEventListener("mousemove", function (e) {
        rect = heroVisual.getBoundingClientRect();
        var px = (e.clientX - rect.left) / rect.width - 0.5;
        var py = (e.clientY - rect.top) / rect.height - 0.5;
        if (phoneEl) {
          phoneEl.style.transform =
            "rotateY(" + (px * 10) + "deg) rotateX(" + (py * -10) + "deg)";
        }
        if (owlEl) {
          owlEl.style.transform = "translate(" + px * -18 + "px," + py * -12 + "px)";
        }
      });
      heroVisual.addEventListener("mouseleave", function () {
        if (phoneEl) phoneEl.style.transform = "rotateY(0deg) rotateX(0deg)";
        if (owlEl) owlEl.style.transform = "translate(0,0)";
      });
    }

    // Scroll-linked parallax for the hero background nebula
    var heroBg = document.querySelector(".hero-bg");
    var lastY = -1;
    function parallaxOnScroll() {
      var y = window.scrollY;
      if (y === lastY) { requestAnimationFrame(parallaxOnScroll); return; }
      lastY = y;
      if (heroBg && y < window.innerHeight) {
        heroBg.style.transform = "translateY(" + y * 0.18 + "px)";
      }
      requestAnimationFrame(parallaxOnScroll);
    }
    requestAnimationFrame(parallaxOnScroll);
  }

  /* --------------------------------------------------------------------
     Glass tilt on feature / testimonial cards
     -------------------------------------------------------------------- */
  if (!reduceMotion) {
    var tiltCards = document.querySelectorAll(".feature-card, .testimonial-card");
    tiltCards.forEach(function (card) {
      card.addEventListener("mousemove", function (e) {
        var r = card.getBoundingClientRect();
        var px = (e.clientX - r.left) / r.width - 0.5;
        var py = (e.clientY - r.top) / r.height - 0.5;
        card.style.transform =
          "perspective(800px) rotateX(" + (py * -6) + "deg) rotateY(" + (px * 6) + "deg) translateY(-4px)";
      });
      card.addEventListener("mouseleave", function () {
        card.style.transform = "perspective(800px) rotateX(0) rotateY(0) translateY(0)";
      });
    });
  }

  /* --------------------------------------------------------------------
     FAQ accordion — close siblings when one opens (native <details>)
     -------------------------------------------------------------------- */
  var faqItems = document.querySelectorAll(".faq-item");
  faqItems.forEach(function (item) {
    item.addEventListener("toggle", function () {
      if (item.open) {
        faqItems.forEach(function (other) {
          if (other !== item) other.open = false;
        });
      }
    });
  });

  /* --------------------------------------------------------------------
     Current year in footer
     -------------------------------------------------------------------- */
  var yearEl = document.getElementById("year");
  if (yearEl) yearEl.textContent = new Date().getFullYear();
})();
