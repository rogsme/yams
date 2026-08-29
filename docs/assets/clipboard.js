(function () {
  function fallbackCopyText(text) {
    const textarea = document.createElement("textarea");
    textarea.value = text;
    textarea.setAttribute("readonly", "");
    textarea.style.position = "fixed";
    textarea.style.opacity = "0";
    document.body.appendChild(textarea);
    textarea.select();

    let copied = false;
    try {
      copied = document.execCommand("copy");
    } catch (error) {
      copied = false;
    } finally {
      textarea.remove();
    }
    return copied;
  }

  function writeText(text) {
    if (!navigator.clipboard?.writeText) return Promise.resolve(fallbackCopyText(text));
    return navigator.clipboard.writeText(text)
      .then(function () { return true; })
      .catch(function () { return fallbackCopyText(text); });
  }

  function copyText(text, button) {
    clearTimeout(button.copyFadeTimer);
    clearTimeout(button.copyResetTimer);
    button.classList.remove("is-copy-fading");

    writeText(text).then(function (copied) {
      if (!copied) return;
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
    addCopyButton(pre, pre.querySelector("code"));
  });

  document.querySelectorAll(".dozzle-command-row").forEach(row => {
    addCopyButton(row, row.querySelector("code"));
  });
})();
