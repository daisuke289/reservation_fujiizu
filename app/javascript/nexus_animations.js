// ============================================================
// Nexus風スクロールアニメーション・インタラクション効果
// 富士伊豆農業協同組合 予約システム
// ============================================================

document.addEventListener('turbo:load', () => {
  console.log('[Nexus Animations] Initializing...');

  // ============================================================
  // Intersection Observer によるスクロールアニメーション
  // ============================================================
  const observerOptions = {
    root: null,
    rootMargin: '0px',
    threshold: 0.1
  };

  const observer = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
      if (entry.isIntersecting) {
        entry.target.classList.add('visible');
        // 一度表示されたら監視を解除（パフォーマンス向上）
        observer.unobserve(entry.target);
      }
    });
  }, observerOptions);

  // .scroll-reveal クラスを持つ全要素を監視
  const revealElements = document.querySelectorAll('.scroll-reveal');
  revealElements.forEach((element, index) => {
    // 各要素に遅延を追加（順番にアニメーション）
    const delay = parseFloat(element.style.transitionDelay) || (index * 0.05);
    element.style.transitionDelay = `${delay}s`;
    observer.observe(element);
  });

  console.log(`[Nexus Animations] Observing ${revealElements.length} scroll-reveal elements`);

  // ============================================================
  // グラスカードのホバー効果強化
  // ============================================================
  const glassCards = document.querySelectorAll('.glass-card');
  glassCards.forEach(card => {
    // マウスオーバー時の3D効果（軽微なtransform）
    card.addEventListener('mouseenter', (e) => {
      if (!card.classList.contains('no-hover')) {
        card.style.transform = 'translateY(-2px) scale(1.005)';
      }
    });

    card.addEventListener('mouseleave', (e) => {
      if (!card.classList.contains('no-hover')) {
        card.style.transform = 'translateY(0) scale(1)';
      }
    });

    // クリック可能なカードにカーソル変更
    if (card.querySelector('a, button')) {
      card.style.cursor = 'pointer';
    }
  });

  console.log(`[Nexus Animations] Enhanced ${glassCards.length} glass-cards`);

  // ============================================================
  // ボタンのリップル効果
  // ============================================================
  const buttons = document.querySelectorAll('button, a.btn, .btn-link, a[class*="bg-gradient"]');

  buttons.forEach(button => {
    button.addEventListener('click', function(e) {
      // 既存のリップルを削除
      const existingRipple = this.querySelector('.ripple-effect');
      if (existingRipple) {
        existingRipple.remove();
      }

      // リップル要素を作成
      const ripple = document.createElement('span');
      const rect = this.getBoundingClientRect();
      const size = Math.max(rect.width, rect.height);
      const x = e.clientX - rect.left - size / 2;
      const y = e.clientY - rect.top - size / 2;

      ripple.style.width = ripple.style.height = size + 'px';
      ripple.style.left = x + 'px';
      ripple.style.top = y + 'px';
      ripple.classList.add('ripple-effect');

      this.appendChild(ripple);

      // アニメーション後に削除
      setTimeout(() => {
        ripple.remove();
      }, 600);
    });
  });

  console.log(`[Nexus Animations] Added ripple effect to ${buttons.length} buttons`);

  // ============================================================
  // スムーススクロール（アンカーリンク）
  // ============================================================
  const anchorLinks = document.querySelectorAll('a[href^="#"]');

  anchorLinks.forEach(link => {
    link.addEventListener('click', function(e) {
      const targetId = this.getAttribute('href').substring(1);
      if (targetId) {
        const targetElement = document.getElementById(targetId);
        if (targetElement) {
          e.preventDefault();
          targetElement.scrollIntoView({
            behavior: 'smooth',
            block: 'start'
          });
        }
      }
    });
  });

  console.log(`[Nexus Animations] Enabled smooth scrolling for ${anchorLinks.length} anchor links`);

  // ============================================================
  // フォーカス表示の強化（アクセシビリティ）
  // ============================================================
  const focusableElements = document.querySelectorAll(
    'a, button, input, select, textarea, [tabindex]:not([tabindex="-1"])'
  );

  focusableElements.forEach(element => {
    element.addEventListener('focus', function() {
      this.classList.add('focus-visible');
    });

    element.addEventListener('blur', function() {
      this.classList.remove('focus-visible');
    });
  });

  console.log(`[Nexus Animations] Enhanced focus for ${focusableElements.length} focusable elements`);

  // ============================================================
  // 画像の遅延読み込み（Lazy Loading）
  // ============================================================
  if ('IntersectionObserver' in window) {
    const lazyImages = document.querySelectorAll('img[data-src]');

    const imageObserver = new IntersectionObserver((entries) => {
      entries.forEach(entry => {
        if (entry.isIntersecting) {
          const img = entry.target;
          img.src = img.dataset.src;
          img.removeAttribute('data-src');
          imageObserver.unobserve(img);
        }
      });
    });

    lazyImages.forEach(img => imageObserver.observe(img));
    console.log(`[Nexus Animations] Lazy loading ${lazyImages.length} images`);
  }

  // ============================================================
  // カードのクリック時のフィードバック（モバイル対応）
  // ============================================================
  const clickableCards = document.querySelectorAll('.glass-card[class*="hover"]');

  clickableCards.forEach(card => {
    card.addEventListener('touchstart', function() {
      this.style.opacity = '0.9';
    }, { passive: true });

    card.addEventListener('touchend', function() {
      this.style.opacity = '1';
    }, { passive: true });

    card.addEventListener('touchcancel', function() {
      this.style.opacity = '1';
    }, { passive: true });
  });

  console.log(`[Nexus Animations] Added touch feedback to ${clickableCards.length} clickable cards`);

  // ============================================================
  // パフォーマンス監視（開発環境のみ）
  // ============================================================
  if (window.location.hostname === 'localhost' || window.location.hostname === '127.0.0.1') {
    // Performance API を使用してページ読み込み時間を測定
    window.addEventListener('load', () => {
      const perfData = window.performance.timing;
      const pageLoadTime = perfData.loadEventEnd - perfData.navigationStart;
      const domReadyTime = perfData.domContentLoadedEventEnd - perfData.navigationStart;

      console.log('[Nexus Animations] Performance Metrics:');
      console.log(`  - DOM Ready: ${domReadyTime}ms`);
      console.log(`  - Page Load: ${pageLoadTime}ms`);
    });
  }

  // ============================================================
  // 初期化完了
  // ============================================================
  console.log('[Nexus Animations] Initialization complete ✓');
});

// ============================================================
// モーション軽減設定の確認
// ============================================================
const prefersReducedMotion = window.matchMedia('(prefers-reduced-motion: reduce)');

if (prefersReducedMotion.matches) {
  console.log('[Nexus Animations] Reduced motion preference detected - animations disabled');
  document.documentElement.classList.add('reduce-motion');
}

// モーション設定変更の監視
prefersReducedMotion.addEventListener('change', (e) => {
  if (e.matches) {
    console.log('[Nexus Animations] Reduced motion preference enabled');
    document.documentElement.classList.add('reduce-motion');
  } else {
    console.log('[Nexus Animations] Reduced motion preference disabled');
    document.documentElement.classList.remove('reduce-motion');
  }
});
