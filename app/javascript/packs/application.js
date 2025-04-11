// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

// --- 必要なライブラリを先に読み込む（順番重要） ---
import 'jquery';
import 'popper.js';
import 'bootstrap'; // ← jQueryとPopperの後！

// --- Rails 関連 ---
import Rails from "@rails/ujs";
import Turbolinks from "turbolinks";
import * as ActiveStorage from "@rails/activestorage";
import "channels";

Rails.start();
Turbolinks.start();
ActiveStorage.start();

// --- CSS & SCSS ---
import "../stylesheets/application.scss";

// --- カスタム JS ---
import "../custom/date_form";
import "../custom/child_form";
import "../custom/child_edit_form";

// --- カレンダー（FullCalendar） ---
import { Calendar } from "@fullcalendar/core";
import dayGridPlugin from "@fullcalendar/daygrid";

function initializeCalendar() {
  const calendarEl = document.getElementById("calendar");
  if (calendarEl) {
    const calendar = new Calendar(calendarEl, {
      plugins: [dayGridPlugin],
    });
    calendar.render();
  }
}

document.addEventListener("turbolinks:load", initializeCalendar);

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
