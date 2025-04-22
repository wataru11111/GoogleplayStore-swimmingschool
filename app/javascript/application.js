// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
// --- Turbo（必須）---
import "@hotwired/turbo-rails"

// --- Stimulus（使うなら）---
import "controllers"

// --- jQuery, Popper, Bootstrap ---
// これらは Importmap では使いづらいため削除するか CDN対応推奨
// 例：application.html.erb に <script src=...> で読み込む

// --- Custom JS ---
import "./custom/date_form"
import "./custom/child_form"
import "./custom/child_edit_form"

// --- ソフトキーボード対応 ---
document.querySelectorAll('input, select, textarea').forEach((element) => {
  element.addEventListener('focus', (event) => {
    setTimeout(() => {
      event.target.scrollIntoView({ behavior: 'smooth', block: 'center' });
    }, 300);
  });
});

document.addEventListener("focusin", (event) => {
  if (event.target.tagName === "INPUT" || event.target.tagName === "TEXTAREA") {
    document.body.style.paddingBottom = "300px";
  }
});

document.addEventListener("focusout", () => {
  document.body.style.paddingBottom = "0px";
});

