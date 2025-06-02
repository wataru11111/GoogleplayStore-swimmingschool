function initializeJumpScroll() {
  console.log("✅ initializeJumpScroll called");

  const buttons = document.querySelectorAll(".jump-link");
  if (!buttons.length) {
    console.warn("⚠️ .jump-link ボタンが見つかりませんでした");
    return;
  }

  buttons.forEach(button => {
    button.addEventListener("click", (event) => {
      const targetId = button.dataset.target;
      const target = document.getElementById(targetId);
      const offset = 80;

      if (target) {
        const top = target.getBoundingClientRect().top + window.pageYOffset - offset;
        window.scrollTo({
          top: top,
          behavior: "smooth"
        });
        console.log(`✅ スクロール: ${targetId}`);
      } else {
        console.warn(`❌ 対象のIDが見つかりません: ${targetId}`);
      }
    });
  });
}

document.addEventListener("turbo:load", initializeJumpScroll);

