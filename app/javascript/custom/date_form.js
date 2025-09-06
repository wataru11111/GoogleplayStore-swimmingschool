// app/javascript/custom/date_form.js
function initializeDateFormScripts() {
  // ===== Flatpickr をセット（両ページで動かす）=====
  setupFlatpickr("transfer_date");
  setupFlatpickr("off_month");

  // ===== /date ページ限定：曜日→時間の連動 =====
  const currentPath = window.location.pathname;
  if (currentPath !== "/date") return;

  const contactDeySelect  = document.getElementById("contact_dey");
  const contactTimeSelect = document.getElementById("transfer_time");
  if (!contactDeySelect || !contactTimeSelect) return;

  // 曜日ごとの時間リスト
  const timeOptions = {
    土曜日: [
      ["16:00","16:00"], ["17:00","17:00"], ["18:00","18:00"]
    ],
    日曜日: [
      ["12:00","12:00"], ["13:00","13:00"], ["14:00","14:00"], ["17:00","17:00"]
    ],
    水曜日: [
      ["19:30","19:30"]
    ],
    祝日: [
      ["11:00","11:00"], ["11:30","11:30"],
      ["12:00","12:00"], ["12:30","12:30"],
      ["13:00","13:00"], ["13:30","13:30"],
      ["14:00","14:00"], ["14:30","14:30"],
      ["15:00","15:00"], ["15:30","15:30"],
      ["16:00","16:00"], ["16:30","16:30"],
      ["17:00","17:00"], ["17:30","17:30"],
      ["18:00","18:00"], ["18:30","18:30"],
      ["19:00","19:00"], ["19:30","19:30"]
    ]
  };

  // 曜日選択に応じて時間リスト更新
  function updateTimeOptions() {
    const selectedDay = contactDeySelect.value;
    contactTimeSelect.innerHTML = "";
    const list = timeOptions[selectedDay] || [];
    if (list.length === 0) {
      const defaultOption = document.createElement("option");
      defaultOption.value = "";
      defaultOption.textContent = "時間選択";
      contactTimeSelect.appendChild(defaultOption);
      return;
    }
    list.forEach(([value, label]) => {
      const option = document.createElement("option");
      option.value = value;
      option.textContent = label;
      contactTimeSelect.appendChild(option);
    });
  }

  updateTimeOptions();
  contactDeySelect.addEventListener("change", updateTimeOptions);
}

// Flatpickr 初期化（data-* から min/max/disable を取得）
function setupFlatpickr(inputId) {
  const el = document.getElementById(inputId);
  if (!el || !window.flatpickr) return;

  const disabled = (el.dataset.disabledDates || "")
    .split(/[,、，\s]+/)
    .map(s => s.trim())
    .filter(Boolean);

  const minDate = el.dataset.mindate || el.getAttribute("min") || null;
  const maxDate = el.dataset.maxdate || el.getAttribute("max") || null;

  if (window.flatpickr.l10ns && window.flatpickr.l10ns.ja) {
    window.flatpickr.localize(window.flatpickr.l10ns.ja);
  }

  window.flatpickr(el, {
    dateFormat: "Y-m-d",
    disableMobile: true,   // スマホでも同じUI
    minDate: minDate,
    maxDate: maxDate,
    disable: disabled      // ← ここで不可能日を完全にクリック不可に
  });
}

document.addEventListener("turbo:load", initializeDateFormScripts);

