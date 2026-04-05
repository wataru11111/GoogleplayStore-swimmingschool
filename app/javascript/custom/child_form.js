function initializeChildFormScripts() {
  const currentPath = window.location.pathname;

  if (
    !(
      currentPath.includes("/child/new") ||
      currentPath.match(/\/child\/\d+\/edit/) ||
      currentPath.match(/\/admin\/child\/\d+\/edit/) ||
      currentPath.match(/\/admin_area\/child\/\d+\/edit/)
    )
  ) {
    console.log("child_form.js: 対象外のページです。スクリプトを実行しません。");
    return;
  }

  const timeOptions = {
    水曜日: ["15:15", "16:00"],
    木曜日: ["14:10", "14:50"],
    土曜日: ["16:30", "17:30", "18:30"],
    日曜日: ["12:00", "13:00", "14:00", "17:00"],
  };

  const legacyTimeMap = {
    水曜日: { "14:30": "15:15", "15:15": "16:00", "19:30": "" },
    木曜日: { "14:30": "14:10", "15:00": "14:50" },
    土曜日: { "16:00": "16:30", "17:00": "17:30", "18:00": "18:30" },
  };

  const normalizeLegacyTime = (day, time) => {
    if (!day || !time) return time;
    const mapped = legacyTimeMap[day]?.[time];
    return mapped === undefined ? time : mapped;
  };

  const rebuildTimeSelect = (selectEl, day) => {
    const currentValue = normalizeLegacyTime(day, selectEl.value);
    selectEl.innerHTML = "";

    const blankOption = document.createElement("option");
    blankOption.value = "";
    blankOption.textContent = "時間選択";
    selectEl.appendChild(blankOption);

    (timeOptions[day] || []).forEach((t) => {
      const opt = document.createElement("option");
      opt.value = t;
      opt.textContent = t;
      selectEl.appendChild(opt);
    });

    if (currentValue && (timeOptions[day] || []).includes(currentValue)) {
      selectEl.value = currentValue;
    } else {
      selectEl.value = "";
    }
  };

  // 🕒 時間1
  const day1 = document.getElementById("child_contact_dey1");
  const time1 = document.getElementById("child_contact_time1");
  if (day1 && time1) {
    const updateTime1 = () => {
      rebuildTimeSelect(time1, day1.value);
    };
    day1.addEventListener("change", updateTime1);
    updateTime1();
  }

  // 🕒 時間2
  const day2 = document.getElementById("child_contact_dey2");
  const time2 = document.getElementById("child_contact_time2");
  if (day2 && time2) {
    const updateTime2 = () => {
      rebuildTimeSelect(time2, day2.value);
    };
    day2.addEventListener("change", updateTime2);
    updateTime2();
  }

  // 🗓️ 契約曜日2・契約時間2 表示切り替え
  const countSelect = document.getElementById("contract_count");
  const day2Field = document.getElementById("contact-dey2-field");
  const time2Field = document.getElementById("contact-time2-field");

  if (countSelect && day2Field && time2Field) {
    const toggleFields = () => {
      const isTwo = countSelect.value === "週2回";
      day2Field.style.display = isTwo ? "block" : "none";
      time2Field.style.display = isTwo ? "block" : "none";
      if (!isTwo) {
        const d2 = day2Field.querySelector("select");
        const t2 = time2Field.querySelector("select");
        if (d2) d2.value = "";
        if (t2) t2.value = "";
      }
    };

    countSelect.addEventListener("change", toggleFields);
    toggleFields();
  }
}

document.addEventListener("turbo:load", initializeChildFormScripts);

