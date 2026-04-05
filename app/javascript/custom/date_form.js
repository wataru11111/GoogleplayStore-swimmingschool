// app/javascript/custom/date_form.js
let disabledTransferSlots = [];
let disabledOffSlots = [];

function initializeDateFormScripts() {
  // ===== 制限データを先に取得（Flatpickrより前） =====
  const currentPath = window.location.pathname;

  const disabledSlotsEl = document.getElementById("disabled_slots_data");
  if (disabledSlotsEl && disabledSlotsEl.value) {
    try {
      disabledTransferSlots = JSON.parse(disabledSlotsEl.value);
    } catch(e) {
      console.error("Failed to parse transfer disabled slots:", e);
      disabledTransferSlots = [];
    }
  }

  const disabledOffSlotsEl = document.getElementById("disabled_off_slots_data");
  if (disabledOffSlotsEl && disabledOffSlotsEl.value) {
    try {
      disabledOffSlots = JSON.parse(disabledOffSlotsEl.value);
    } catch(e) {
      console.error("Failed to parse off disabled slots:", e);
      disabledOffSlots = [];
    }
  }

  // ===== Flatpickr をセット（両ページで動かす）=====
  setupFlatpickr("transfer_date");
  setupFlatpickr("off_month");

  // ===== /date ページ限定：曜日→時間の連動 =====
  if (currentPath !== "/date") return;

  const contactDeySelect  = document.getElementById("contact_dey");
  const contactTimeSelect = document.getElementById("transfer_time");
  if (!contactDeySelect || !contactTimeSelect) return;

  // 曜日ごとの時間リスト
  const timeOptions = {
    土曜日: [
      ["16:30","16:30"], ["17:30","17:30"], ["18:30","18:30"]
    ],
    日曜日: [
      ["12:00","12:00"], ["13:00","13:00"], ["14:00","14:00"], ["17:00","17:00"]
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
    const selectedDate = document.getElementById("transfer_date").value;
    
    contactTimeSelect.innerHTML = "";
    const list = timeOptions[selectedDay] || [];
    if (list.length === 0) {
      const defaultOption = document.createElement("option");
      defaultOption.value = "";
      defaultOption.textContent = "時間選択";
      contactTimeSelect.appendChild(defaultOption);
      return;
    }
    
    // 時間帯制限をチェック
    list.forEach(([value, label]) => {
      // この時間が選択可能かチェック
      if (isTimeDisabled(selectedDate, value)) {
        return; // この時間は選択肢に追加しない
      }
      
      const option = document.createElement("option");
      option.value = value;
      option.textContent = label;
      contactTimeSelect.appendChild(option);
    });
    
    // 選択肢が何もない場合
    if (contactTimeSelect.options.length === 0) {
      const defaultOption = document.createElement("option");
      defaultOption.value = "";
      defaultOption.textContent = "この日は振替できません";
      contactTimeSelect.appendChild(defaultOption);
    }
  }
  
  // 指定日時が不可能かチェック
  function isTimeDisabled(date, time) {
    if (!date || !time || disabledTransferSlots.length === 0) {
      return false;
    }
    
    for (const slot of disabledTransferSlots) {
      if (slot.date !== date) continue;
      
      // 全休の場合はすべての時間が不可
      if (slot.type === 'all_day') {
        return true;
      }
      
      // 時間帯指定の場合
      if (slot.type === 'time_range' && slot.start_time && slot.end_time) {
        // 選択時間が不可能時間帯に含まれているかチェック
        if (time >= slot.start_time && time < slot.end_time) {
          return true;
        }
      }
    }
    
    return false;
  }

  updateTimeOptions();
  contactDeySelect.addEventListener("change", updateTimeOptions);
  
  // 日付が変更されたときも時間選択肢を更新
  const transferDateEl = document.getElementById("transfer_date");
  if (transferDateEl) {
    transferDateEl.addEventListener("change", updateTimeOptions);
  }
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

  // ===== transfer_date：振替登録の不可能日 =====
  if (inputId === "transfer_date" && disabledTransferSlots.length > 0) {
    disabledTransferSlots.forEach(slot => {
      if (slot.type === 'all_day') {
        disabled.push(slot.date);
      }
    });
  }

  // ===== off_month：お休み登録の不可能日 =====
  if (inputId === "off_month" && disabledOffSlots.length > 0) {
    disabledOffSlots.forEach(slot => {
      if (slot && slot.date) {
        disabled.push(slot.date);
      }
    });
  }

  const uniqueDisabled = [...new Set(disabled)];

  if (window.flatpickr.l10ns && window.flatpickr.l10ns.ja) {
    window.flatpickr.localize(window.flatpickr.l10ns.ja);
  }

  window.flatpickr(el, {
    dateFormat: "Y-m-d",
    disableMobile: true,   // スマホでも同じUI
    minDate: minDate,
    maxDate: maxDate,
    disable: uniqueDisabled      // ← ここで不可能日を完全にクリック不可に
  });
}

document.addEventListener("turbo:load", initializeDateFormScripts);

