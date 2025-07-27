document.addEventListener('DOMContentLoaded', () => {
  const highlights = document.querySelectorAll('div.highlight');

  highlights.forEach((highlight) => {
    const button = document.createElement('button');
    button.className = 'copy-button';
    button.textContent = 'Copy';
    button.setAttribute('aria-label', 'Copy code to clipboard');

    button.addEventListener('click', () => {
      const code = highlight.querySelector('code');
      if (code) {
        navigator.clipboard.writeText(code.innerText).then(() => {
          button.textContent = 'Copied!';
          setTimeout(() => {
            button.textContent = 'Copy';
          }, 2000);
        }).catch(err => {
          console.error('Failed to copy text: ', err);
          button.textContent = 'Error';
        });
      }
    });

    highlight.prepend(button);
  });
});
