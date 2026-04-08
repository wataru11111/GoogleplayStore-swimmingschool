function initializeChildEditFormScripts() {
    const currentPath = window.location.pathname;
  
    const childEditPathRegex = /^\/child\/\d+\/edit$/;
    if (!childEditPathRegex.test(currentPath)) {
      console.log("child_edit_form.js: 対象外のページです。スクリプトを実行しません。");
      return;
    }
  
    const daySelect = document.getElementById("contact_dey");
    const timeSelect = document.getElementById("contact_time");
  
    if (!daySelect || !timeSelect) {
      console.error("contact_dey または contact_time が見つかりませんでした。");
      return;
    }
  
    const timeOptions = {
      水曜日: ["15:15", "16:00"],
      木曜日: ["14:10", "14:50"],
      土曜日: ["16:30", "17:30", "18:30"],
      日曜日: ["12:00", "13:00", "14:00", "17:00"],
    };

    const legacyTimeMap = {
      水曜日: { "14:30": "15:15","19:30": "" },
      木曜日: { "14:30": "14:10", "15:00": "14:50" },
      土曜日: { "16:00": "16:30", "17:00": "17:30", "18:00": "18:30" },
    };

    function normalizeLegacyTime(day, time) {
      if (!day || !time) return time;
      const mapped = legacyTimeMap[day]?.[time];
      return mapped === undefined ? time : mapped;
    }
  
    function updateContactTimeOptions() {
      const selectedDay = daySelect.value;
      const currentValue = normalizeLegacyTime(selectedDay, timeSelect.value);
      timeSelect.innerHTML = "";

      const blankOption = document.createElement("option");
      blankOption.value = "";
      blankOption.textContent = "時間選択";
      timeSelect.appendChild(blankOption);
  
      if (timeOptions[selectedDay]) {
        timeOptions[selectedDay].forEach(function (time) {
          const option = document.createElement("option");
          option.value = time;
          option.textContent = time;
          timeSelect.appendChild(option);
        });
      }

      if (currentValue && timeOptions[selectedDay]?.includes(currentValue)) {
        timeSelect.value = currentValue;
      } else {
        timeSelect.value = "";
      }
    }
  
    updateContactTimeOptions();
    daySelect.addEventListener("change", updateContactTimeOptions);
  }
  
  // turbolinks:load イベントに対応
  document.addEventListener("turbo:load", initializeChildEditFormScripts);
  

