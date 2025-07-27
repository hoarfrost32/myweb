document.addEventListener("DOMContentLoaded", function() {
  const p1 = document.getElementById('p1');
  const p2 = document.getElementById('p2');
  const p3 = document.getElementById('p3');

  // Function to fade in elements
  function fadeIn(element) {
    element.style.opacity = 0;
    element.style.display = 'block';

    let opacity = 0;
    const timer = setInterval(function () {
      if (opacity >= 1){
        clearInterval(timer);
      }
      element.style.opacity = opacity;
      element.style.filter = 'alpha(opacity=' + opacity * 100 + ")";
      opacity += 0.1;
    }, 50);
  }

  setTimeout(function() {
    if (p1) fadeIn(p1);
  }, 3000);

  setTimeout(function() {
    if (p2) fadeIn(p2);
  }, 8000);

  setTimeout(function() {
    if (p3) fadeIn(p3);
  }, 13000);

  setTimeout(function() {
    window.location.href = "/";
  }, 15000);
});
