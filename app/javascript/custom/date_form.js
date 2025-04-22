function initializeDateFormScripts() {
  console.log("initializeDateFormScripts called");

  const currentPath = window.location.pathname;
  console.log("Current Path:", currentPath);

  if (currentPath !== "/date") {
    console.log("Path does not match /date");
    return;
  }

  const contactDeySelect = document.getElementById("contact_dey");
  const contactTimeSelect = document.getElementById("transfer_time");

  if (!contactDeySelect || !contactTimeSelect) {
    console.error("必要な要素が見つかりません");
    return;
  }

  console.log("Elements found. Initializing options...");

  const timeOptions = {
    土曜日: [["16:00", "16:00"], ["17:00", "17:00"], ["18:00", "18:00"]],
    日曜日: [["12:00", "12:00"], ["13:00", "13:00"], ["14:00", "14:00"], ["17:00", "17:00"]],
    水曜日: [["19:30", "19:30"]],
  };

  function updateTimeOptions() {
    const selectedDay = contactDeySelect.value;
    console.log("Selected day:", selectedDay);
    contactTimeSelect.innerHTML = "";

    if (timeOptions[selectedDay]) {
      console.log("Time options for selected day:", timeOptions[selectedDay]);
      timeOptions[selectedDay].forEach(([value, label]) => {
        const option = document.createElement("option");
        option.value = value;
        option.textContent = label;
        contactTimeSelect.appendChild(option);
      });
    } else {
      console.log("No time options found for:", selectedDay);
      const defaultOption = document.createElement("option");
      defaultOption.value = "";
      defaultOption.textContent = "時間選択";
      contactTimeSelect.appendChild(defaultOption);
    }
  }

  updateTimeOptions();
  contactDeySelect.addEventListener("change", updateTimeOptions);
}

document.addEventListener("turbo:load", initializeDateFormScripts);
