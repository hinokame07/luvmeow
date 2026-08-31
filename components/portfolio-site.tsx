'use client';

import { useEffect, useRef } from 'react';
import { SITE_CONFIG } from '@/lib/site-config';

function DecorativeElements() {
  return (
    <div className="hero-sparkles" aria-hidden="true">
      <span className="deco deco-star star-1">✦</span>
      <span className="deco deco-heart heart-1">♡</span>
      <span className="deco deco-spark spark-1">✧</span>
      <span className="deco deco-mini mini-1">✦</span>

      <span className="deco deco-star star-2">✦</span>
      <span className="deco deco-heart heart-2">♡</span>
      <span className="deco deco-mini mini-2">⋆</span>

      <span className="deco deco-heart heart-3">♡</span>
      <span className="deco deco-star star-3">✦</span>
      <span className="deco deco-spark spark-2">✧</span>
      <span className="deco deco-heart heart-4">♡</span>

      <span className="tiny-note">
        pretty things live here!
      </span>

      <div className="dot-decoration dot-left" />
      <div className="dot-decoration dot-right" />
    </div>
  );
}

function CTAButtons() {
  return (
    <div className="cta-row">
      <a
        className="cta-button cta-primary"
        href={SITE_CONFIG.portfolioUrl}
      >
        ver meu trabalho
        <span aria-hidden="true">✦</span>
      </a>

      <a
        className="cta-button cta-secondary"
        href={SITE_CONFIG.discordUrl}
      >
        entre em contato
        <span aria-hidden="true">♡</span>
      </a>
    </div>
  );
}

function Hero() {
  const heroRef = useRef<HTMLElement>(null);

  function handlePointerMove(
    event: React.PointerEvent<HTMLElement>
  ) {
    if (
      window
        .matchMedia('(prefers-reduced-motion: reduce)')
        .matches
    ) {
      return;
    }

    const bounds =
      event.currentTarget.getBoundingClientRect();

    const x =
      (event.clientX - bounds.left) /
        bounds.width -
      0.5;

    const y =
      (event.clientY - bounds.top) /
        bounds.height -
      0.5;

    heroRef.current?.style.setProperty(
      '--tilt-x',
      `${x * 5}px`
    );

    heroRef.current?.style.setProperty(
      '--tilt-y',
      `${y * 4}px`
    );
  }

  return (
    <section
      className="hero"
      id="inicio"
      ref={heroRef}
      onPointerMove={handlePointerMove}
    >
      <p
        className="background-word background-word-one"
        aria-hidden="true"
      >
        LUV
      </p>

      <p
        className="background-word background-word-two"
        aria-hidden="true"
      >
        CREATE
      </p>

      <DecorativeElements />

      <div className="hero-copy">
        <div className="eyebrow-wrapper">
          <div
            className="eyebrow-rays eyebrow-rays-left"
            aria-hidden="true"
          >
            <span />
            <span />
            <span />
          </div>

          <p className="eyebrow">
            <span aria-hidden="true">♡</span>
            oi, eu sou a {SITE_CONFIG.name}!
          </p>

          <div
            className="eyebrow-rays eyebrow-rays-right"
            aria-hidden="true"
          >
            <span />
            <span />
            <span />
          </div>
        </div>

        <h1>
          Transformamos
          <br />
          ideias
          <br />
          em
          <br />
          <em>experiências visuais.</em>
        </h1>

        <div
          className="hero-divider"
          aria-hidden="true"
        >
          <span />
          <b>♡</b>
          <span />
        </div>

        <p className="hero-bio">
          {SITE_CONFIG.bio}
        </p>

        <CTAButtons />

        <div
          className="hero-bottom-decoration"
          aria-hidden="true"
        >
          <i>✧</i>
          <span>••••</span>
          <b>♡</b>
          <span>••••</span>
          <i>✧</i>
        </div>
      </div>

      <div
        className="scroll-note"
        aria-hidden="true"
      >
        scroll down ↓
      </div>
    </section>
  );
}

function Rules() {
  return (
    <div className="rules-column reveal">
      <div className="section-label">
        <span>01</span>
        antes de pedir
      </div>

      <h2>
        minhas
        <br />
        <em>regras</em>
      </h2>

      <div className="rules-list">
        {SITE_CONFIG.rules.map(
          (rule, index) => (
            <article
              className="rule-item"
              key={rule.title}
            >
              <span
                className="rule-number"
                aria-hidden="true"
              >
                {String(index + 1).padStart(
                  2,
                  '0'
                )}
              </span>

              <div>
                <h3>{rule.title}</h3>
                <p>{rule.text}</p>
              </div>
            </article>
          )
        )}
      </div>
    </div>
  );
}

function PriceGroup({
  title,
  items,
  variant,
}: {
  title: string;
  items: readonly {
    readonly label: string;
    readonly price: string;
  }[];
  variant: 'carrds' | 'designs';
}) {
  return (
    <article
      className={`price-group price-${variant}`}
    >
      <header>
        <span aria-hidden="true">
          {variant === 'carrds'
            ? '✦'
            : '♡'}
        </span>

        <h3>{title}</h3>

        <small>
          {variant === 'carrds'
            ? 'one page magic'
            : 'made with luv'}
        </small>
      </header>

      <ul>
        {items.map((item) => (
          <li key={item.label}>
            <span>{item.label}</span>

            <i aria-hidden="true" />

            <strong>{item.price}</strong>
          </li>
        ))}
      </ul>
    </article>
  );
}

function Pricing() {
  return (
    <div
      className="pricing-column reveal"
      id="portfolio"
    >
      <div className="section-label">
        <span>02</span>
        commission menu
      </div>

      <h2>
        meus
        <br />
        <em>valores</em>
      </h2>

      <div className="price-stack">
        <PriceGroup
          title="Carrds"
          items={
            SITE_CONFIG.prices.carrds
          }
          variant="carrds"
        />

        <div
          className="not-the-same"
          aria-hidden="true"
        >
          <span>not the same!</span>
          ↙ &nbsp; ↘
        </div>

        <PriceGroup
          title="Designs"
          items={
            SITE_CONFIG.prices.designs
          }
          variant="designs"
        />
      </div>

      <p className="price-note">
        os valores podem variar
        dependendo da complexidade do
        pedido ♡
      </p>
    </div>
  );
}

function CommissionInfo() {
  return (
    <section
      className="commission-section"
      id="comissoes"
    >
      <div className="commission-kicker reveal">
        <span>
          luv&apos;s little corner ♡
        </span>

        <p>commission info</p>
      </div>

      <div className="commission-grid">
        <Rules />

        <div
          className="middle-doodle"
          aria-hidden="true"
        >
          ✦
          <br />
          ♡
          <br />
          ✧
        </div>

        <Pricing />
      </div>
    </section>
  );
}

function Footer() {
  return (
    <footer id="contato">
      <p>tem uma ideia bonita?</p>

      <h2>
        vamos criar juntas!
        <span> ♡</span>
      </h2>

      <a
        className="cta-button cta-primary"
        href={SITE_CONFIG.discordUrl}
      >
        me chama no discord ✦
      </a>

      <div className="footer-line">
        <span>
          © {new Date().getFullYear()}{' '}
          {SITE_CONFIG.name}
        </span>

        <span>
          designs • carrds • pretty things
        </span>

        <a href="#inicio">
          voltar ao topo ↑
        </a>
      </div>
    </footer>
  );
}

export function PortfolioSite() {
  useEffect(() => {
    const elements =
      document.querySelectorAll<HTMLElement>(
        '.reveal'
      );

    const observer =
      new IntersectionObserver(
        (entries) => {
          entries.forEach(
            (entry) => {
              if (
                entry.isIntersecting
              ) {
                entry.target.classList.add(
                  'is-visible'
                );
              }
            }
          );
        },
        {
          threshold: 0.12,
        }
      );

    elements.forEach(
      (element) =>
        observer.observe(element)
    );

    return () =>
      observer.disconnect();
  }, []);

  return (
    <main>
      <Hero />

      <div
        className="section-transition"
        aria-hidden="true"
      >
        <span>
          ✦ work with me ✦
        </span>
      </div>

      <CommissionInfo />

      <Footer />
    </main>
  );
}