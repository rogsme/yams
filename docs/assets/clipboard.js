(function () {
  function copyText(text, button) {
    if (!navigator.clipboard) return;

    clearTimeout(button.copyFadeTimer);
    clearTimeout(button.copyResetTimer);
    button.classList.remove("is-copy-fading");

    navigator.clipboard.writeText(text).then(function () {
      button.classList.add("is-copied");
      button.setAttribute("aria-label", "Copied");
      button.title = "Copied";
      button.querySelector("img").src = "/icons/tick.svg";
      button.querySelector("img").alt = "Copied";
      button.copyFadeTimer = setTimeout(function () {
        button.classList.add("is-copy-fading");
      }, 820);
      button.copyResetTimer = setTimeout(function () {
        button.classList.remove("is-copied");
        button.classList.remove("is-copy-fading");
        button.setAttribute("aria-label", "Copy to clipboard");
        button.title = "Copy to clipboard";
        button.querySelector("img").src = "/icons/copy.svg";
        button.querySelector("img").alt = "";
      }, 940);
    });
  }

  function addCopyButton(container, target) {
    if (!target || container.querySelector(".book-copy-button")) return;

    const button = document.createElement("button");
    button.type = "button";
    button.className = "book-copy-button";
    button.setAttribute("aria-label", "Copy to clipboard");
    button.title = "Copy to clipboard";

    const icon = document.createElement("img");
    icon.src = "/icons/copy.svg";
    icon.alt = "";
    icon.setAttribute("aria-hidden", "true");
    button.appendChild(icon);

    button.addEventListener("click", function (event) {
      event.stopPropagation();
      copyText(target.textContent, button);
    });

    container.classList.add("book-copy-container");
    container.appendChild(button);
  }

  document.querySelectorAll("pre:has(code)").forEach(pre => {
    pre.addEventListener("click", pre.focus);
    pre.addEventListener("copy", function (event) {
      event.preventDefault();
      if (navigator.clipboard) {
        const content = window.getSelection().toString() || pre.textContent;
        navigator.clipboard.writeText(content);
      }
    });
    addCopyButton(pre, pre.querySelector("code"));
  });

  document.querySelectorAll(".dozzle-command-row").forEach(row => {
    addCopyButton(row, row.querySelector("code"));
  });
})();
