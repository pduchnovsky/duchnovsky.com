const svgCopy = `
<svg aria-hidden="true" height="16" viewBox="0 0 16 16" version="1.1" width="16" data-view-component="true" focusable="false">
  <path fill-rule="evenodd" d="M0 6.75C0 5.784.784 5 1.75 5h1.5a.75.75 0 010 1.5h-1.5a.25.25 0 00-.25.25v7.5c0 .138.112.25.25.25h7.5a.25.25 0 00.25-.25v-1.5a.75.75 0 011.5 0v1.5A1.75 1.75 0 019.25 16h-7.5A1.75 1.75 0 010 14.25v-7.5z"></path>
  <path fill-rule="evenodd" d="M5 1.75C5 .784 5.784 0 6.75 0h7.5C15.216 0 16 .784 16 1.75v7.5A1.75 1.75 0 0114.25 11h-7.5A1.75 1.75 0 015 9.25v-7.5zm1.75-.25a.25.25 0 00-.25.25v7.5c0 .138.112.25.25.25h7.5a.25.25 0 00.25-.25v-7.5a.25.25 0 00-.25-.25h-7.5z"></path>
</svg>`;

const svgCheck = `
<svg aria-hidden="true" height="16" viewBox="0 0 16 16" version="1.1" width="16" data-view-component="true" focusable="false">
  <path fill-rule="evenodd" fill="rgb(63, 185, 80)" d="M13.78 4.22a.75.75 0 010 1.06l-7.25 7.25a.75.75 0 01-1.06 0L2.22 9.28a.75.75 0 011.06-1.06L6 10.94l6.72-6.72a.75.75 0 011.06 0z"></path>
</svg>`;

function addCopyButtons(clipboard) {
  document.querySelectorAll("pre > code").forEach((codeBlock) => {
    const button = document.createElement("button");
    button.className = "clipboard-button";
    button.type = "button";
    button.setAttribute("aria-label", "Copy code to clipboard");
    button.title = "Copy code to clipboard";
    button.innerHTML = svgCopy;

    const pre = codeBlock.parentNode;
    pre.parentNode.insertBefore(button, pre);

    button.addEventListener("click", async () => {
      try {
        await clipboard.writeText(codeBlock.textContent);
        button.blur();
        button.innerHTML = svgCheck;
        button.setAttribute("aria-label", "Copied");
        button.title = "Copied";

        setTimeout(() => {
          button.innerHTML = svgCopy;
          button.setAttribute("aria-label", "Copy code to clipboard");
          button.title = "Copy code to clipboard";
        }, 2000);
      } catch (err) {
        console.error("Copy failed", err);
        button.innerHTML = "Error";
        button.setAttribute("aria-label", "Copy failed");
        button.title = "Copy failed";
        setTimeout(() => {
          button.innerHTML = svgCopy;
          button.setAttribute("aria-label", "Copy code to clipboard");
          button.title = "Copy code to clipboard";
        }, 2000);
      }
    });
  });
}

if (navigator?.clipboard) {
  addCopyButtons(navigator.clipboard);
} else {
  const script = document.createElement("script");
  script.src =
    "https://cdnjs.cloudflare.com/ajax/libs/clipboard-polyfill/2.7.0/clipboard-polyfill.promise.js";
  script.integrity = "sha256-waClS2re9NUbXRsryKoof+F9qc1gjjIhc2eT7ZbIv94=";
  script.crossOrigin = "anonymous";
  script.onload = () => addCopyButtons(window.clipboard);
  document.body.appendChild(script);
}
