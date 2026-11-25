(() => {
  for (const button of document.querySelectorAll('button.copy[data-from]')) {
    const source = document.getElementById(button.dataset.from);
    if (!source) continue;
    const label = button.textContent;
    button.addEventListener('click', async () => {
      const text = source.innerText.trim();
      let ok = false;
      try {
        if (navigator.clipboard && window.isSecureContext) { await navigator.clipboard.writeText(text); ok = true; }
      } catch (e) {}
      if (!ok) {
        const box = document.createElement('textarea');
        box.className = 'manual-copy'; box.readOnly = true; box.value = text;
        box.setAttribute('aria-label', 'Prompt text to copy');
        const host = button.closest('.ex');
        const old = host.querySelector('.manual-copy'); if (old) old.remove();
        host.appendChild(box); box.focus(); box.select();
        button.textContent = 'Select and copy';
      } else {
        button.textContent = 'Copied';
      }
      setTimeout(() => { button.textContent = label; }, 1800);
    });
  }
})();
