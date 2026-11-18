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

  // 日付から曜日を自動判定
  const holidayInput = document.getElementById("additional_transfer_dates_data"); // ADMIN_ADDITIONAL_DAYS_20261118
  let holidays = new Set();

  try {
    holidays = new Set(JSON.parse(holidayInput?.value || "[]"));
  } catch (error) {
    console.error("祝日データの読み込み失敗", error);
  }

  function dayFromDate(value) {
    if (!/^\d{4}-\d{2}-\d{2}$/.test(value)) return "";

    const [year, month, day] = value.split("-").map(Number);
    const date = new Date(Date.UTC(year, month - 1, day));

    if (
      date.getUTCFullYear() !== year ||
      date.getUTCMonth() !== month - 1 ||
      date.getUTCDate() !== day
    ) return "";

    if (date.getUTCDay() === 6) return "土曜日";
    if (date.getUTCDay() === 0) return "日曜日";
    if (holidays.has(value)) return "祝日";

    return "";
  }

  // 曜日選択に応じて時間リスト更新
  // A3_SLOT_CAPACITY_20261118
  const levelSelect = document.querySelector('select[name="transfer[level]"]') ||
                      document.getElementById("level");
  let latestAvailabilityRequest = 0;

  async function updateTimeOptions() {
    const requestNumber = ++latestAvailabilityRequest;
    const transferDate = document.getElementById("transfer_date");
    const selectedDate = transferDate ? transferDate.value : "";
    const selectedDay = dayFromDate(selectedDate);
    const level = levelSelect ? levelSelect.value : "";
    const previousTime = contactTimeSelect.value;

    contactDeySelect.value = selectedDay;
    const message = document.getElementById("transfer_day_message");
    if (message) {
      message.textContent = selectedDay
        ? `選択された振替曜日：${selectedDay}`
        : selectedDate ? "この日は振替できません" : "";
    }

    contactTimeSelect.innerHTML = "";
    contactTimeSelect.add(new Option("時間選択", ""));

    if (!selectedDate || !level || !selectedDay) {
      contactTimeSelect.options[0].textContent = !selectedDate
        ? "振替日を選択してください"
        : !level ? "クラスを選択してください" : "この日は振替できません";
      return;
    }

    contactTimeSelect.options[0].textContent = "残り人数を確認中...";
    try {
      const query = new URLSearchParams({date: selectedDate, level: level});
      const response = await fetch(`/dates/slot_availability?${query}`, {
        headers: {"Accept": "application/json"},
        credentials: "same-origin",
        cache: "no-store"
      });
      if (!response.ok) throw new Error(`HTTP ${response.status}`);
      const result = await response.json();
      if (requestNumber !== latestAvailabilityRequest) return;

      contactTimeSelect.innerHTML = "";
      contactTimeSelect.add(new Option("時間選択（表示は空き人数/定員）", ""));
      (result.slots || []).forEach(slot => {
        const label = slot.full
          ? `${slot.time}  満員`
          : `${slot.time}  ${slot.remaining}/${slot.capacity}`;
        const option = new Option(label, slot.time);
        option.disabled = !!slot.full;
        contactTimeSelect.add(option);
      });
      if ((result.slots || []).length === 0) {
        contactTimeSelect.options[0].textContent = "選択できる時間がありません";
      }
      const restored = Array.from(contactTimeSelect.options).find(
        option => option.value === previousTime && !option.disabled
      );
      if (restored) contactTimeSelect.value = previousTime;
    } catch (error) {
      if (requestNumber !== latestAvailabilityRequest) return;
      console.error("振替の空き人数を取得できませんでした", error);
      contactTimeSelect.options[0].textContent = "空き状況を取得できません。再読み込みしてください";
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
  // 振替曜日は日付の変更イベントで自動更新
  
  // 日付が変更されたときも時間選択肢を更新
  const transferDateEl = document.getElementById("transfer_date");
  if (transferDateEl) {
    transferDateEl.addEventListener("change", updateTimeOptions);
  }
  if (levelSelect) levelSelect.addEventListener("change", updateTimeOptions);
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

  // ADMIN_ADDITIONAL_DAYS_20261118
  // 原則土日だけ。管理者追加日以外の平日・祝日を選択不可にする。
  if (inputId === "transfer_date") {
    let additionalDates = [];
    try {
      additionalDates = JSON.parse(
        document.getElementById("additional_transfer_dates_data")?.value || "[]"
      );
    } catch (error) {
      console.error("振替追加日の読み込みに失敗しました", error);
    }
    const extra = new Set(additionalDates);
    disabled.push(function (date) {
      const key = [date.getFullYear(),
        String(date.getMonth() + 1).padStart(2, "0"),
        String(date.getDate()).padStart(2, "0")].join("-");
      return date.getDay() !== 0 && date.getDay() !== 6 && !extra.has(key);
    });
  }

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

