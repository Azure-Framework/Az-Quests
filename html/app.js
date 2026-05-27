(() => {
  const resource = (window.GetParentResourceName ? GetParentResourceName() : "Az-Quests");

  const $ = (sel) => document.querySelector(sel);
  const elApp = $("#app");
  const elList = $("#questList");
  const elSearch = $("#qSearch");

  const elEmpty = $("#empty");
  const elDetails = $("#details");

  const elDiscord = $("#discord");
  const elDiscordLink = $("#discord .link");

  const elTitle = $("#dTitle");
  const elDesc = $("#dDesc");
  const elStatus = $("#dStatus");
  const elProgressText = $("#dProgressText");
  const elProgressBar = $("#dProgressBar");
  const elActive = $("#dActive");
  const elStepsMeta = $("#stepsMeta");
  const elStepList = $("#stepList");

  const btnClose = $("#btnClose");
  const btnTrack = $("#btnTrack");
  const btnUntrack = $("#btnUntrack");
  const btnReset = $("#btnReset");

  const state = {
    open: false,
    theme: null,
    discord: null,
    quests: [],
    progress: {},
    activeQuestId: null,
    selectedQuestId: null,
    search: ""
  };

  function postNui(name, data = {}) {
    return fetch(`https://${resource}/${name}`, {
      method: "POST",
      headers: { "Content-Type": "application/json; charset=UTF-8" },
      body: JSON.stringify(data)
    }).catch(() => {});
  }

  function applyTheme(theme) {
    if (!theme) return;
    const root = document.documentElement;
    const map = {
      "--bg": theme.bg,
      "--panel": theme.panel,
      "--panel2": theme.panel2,
      "--stroke": theme.stroke,
      "--text": theme.text,
      "--muted": theme.muted,
      "--accent": theme.accent,
      "--accent2": theme.accent2,
    };
    for (const [k, v] of Object.entries(map)) {
      if (v) root.style.setProperty(k, v);
    }
  }

  function openUI() {
    elApp.classList.remove("hidden");
    elApp.setAttribute("aria-hidden", "false");
  }

  function closeUI() {
    postNui("close");
  }

  function setSelected(id) {
    state.selectedQuestId = id;
    render();
  }

  function getQuest(id) {
    return state.quests.find(q => q.id === id) || null;
  }

  function isCompleted(q) {
    const done = Number(state.progress[q.id] || 0);
    return done >= (q.points?.length || 0);
  }

  function getDone(q) {
    return Number(state.progress[q.id] || 0);
  }

  function formatPill(q) {
    const done = getDone(q);
    const total = q.points?.length || 0;
    if (total <= 0) return { text: "EMPTY", cls: "" };
    if (done >= total) return { text: "DONE", cls: "" };
    if (state.activeQuestId === q.id) return { text: "ACTIVE", cls: "" };
    return { text: `${done}/${total}`, cls: "" };
  }

  function renderList() {
    const q = (state.search || "").trim().toLowerCase();
    const quests = state.quests
      .filter(x => {
        if (!q) return true;
        return (x.title || "").toLowerCase().includes(q) || (x.description || "").toLowerCase().includes(q) || (x.id || "").toLowerCase().includes(q);
      });

    elList.innerHTML = "";
    quests.forEach(quest => {
      const pill = formatPill(quest);
      const done = getDone(quest);
      const total = quest.points?.length || 0;

      const item = document.createElement("div");
      item.className = "qItem" + (state.selectedQuestId === quest.id ? " active" : "");
      item.setAttribute("role", "listitem");
      item.dataset.id = quest.id;

      item.innerHTML = `
        <div class="qTitle">${escapeHtml(quest.title || quest.id)}</div>
        <div class="qMeta">
          <div class="qDesc">${escapeHtml(quest.description || "")}</div>
          <div class="qMini">${escapeHtml(pill.text)}</div>
        </div>
      `;
      item.addEventListener("click", () => setSelected(quest.id));
      elList.appendChild(item);
    });

    if (!state.selectedQuestId && quests.length) {
      state.selectedQuestId = quests[0].id;
    }
  }

  function renderDetails() {
    const quest = getQuest(state.selectedQuestId);
    if (!quest) {
      elDetails.classList.add("hidden");
      elEmpty.classList.remove("hidden");
      return;
    }

    elEmpty.classList.add("hidden");
    elDetails.classList.remove("hidden");

    const done = getDone(quest);
    const total = quest.points?.length || 0;
    const active = state.activeQuestId === quest.id;
    const completed = isCompleted(quest);

    elTitle.textContent = quest.title || quest.id;
    elDesc.textContent = quest.description || "";

    elStatus.textContent = completed ? "COMPLETED" : (active ? "ACTIVE" : "READY");
    elStatus.style.borderColor = completed ? "rgba(94,201,240,.35)" : (active ? "rgba(228,89,164,.35)" : "rgba(255,255,255,.12)");
    elStatus.style.background = completed ? "rgba(94,201,240,.10)" : (active ? "rgba(228,89,164,.10)" : "rgba(0,0,0,.25)");

    elProgressText.textContent = `${done}/${total}`;
    const pct = total > 0 ? Math.max(0, Math.min(1, done / total)) : 0;
    elProgressBar.style.width = `${pct * 100}%`;

    elActive.classList.toggle("hidden", !active);
    btnUntrack.classList.toggle("hidden", !active);
    btnTrack.textContent = completed ? "Completed" : (active ? "Tracking…" : "Track Quest");
    btnTrack.disabled = completed;

    elStepsMeta.textContent = `${total} objective${total === 1 ? "" : "s"} • ${completed ? "done" : "in progress"}`;

    elStepList.innerHTML = "";
    (quest.points || []).forEach((pt, i) => {
      const idx = i + 1;
      const isDone = done >= idx;
      const isNext = !completed && (done + 1) === idx;

      const row = document.createElement("div");
      row.className = "step" + (isDone ? " stepDone" : "");
      row.innerHTML = `
        <div class="stepIcon">
          ${isDone ? checkSvg() : pinSvg()}
        </div>
        <div class="stepMain">
          <div class="stepLabel">${escapeHtml(pt.label || `Objective ${idx}`)} ${isNext ? "• NEXT" : ""}</div>
          <div class="stepSub">${escapeHtml(coordText(pt.coords))}${pt.radius ? ` • radius ${pt.radius}` : ""}</div>
        </div>
      `;
      elStepList.appendChild(row);
    });
  }

  function renderDiscord() {
    const d = state.discord;
    if (!d || !d.enabled) {
      elDiscord.classList.add("hidden");
      return;
    }
    elDiscord.classList.remove("hidden");
    elDiscord.querySelector(".tag").textContent = d.label || "DISCORD";
    elDiscordLink.textContent = (d.invite || "").replace(/^https?:\/\//i, "");
  }

  function render() {
    renderDiscord();
    renderList();
    renderDetails();
  }

  function escapeHtml(str) {
    return String(str || "")
      .replace(/&/g, "&amp;")
      .replace(/</g, "&lt;")
      .replace(/>/g, "&gt;")
      .replace(/"/g, "&quot;")
      .replace(/'/g, "&#039;");
  }

  function coordText(c) {
    if (!c) return "—";

    const x = Number(c.x ?? c[0] ?? 0).toFixed(2);
    const y = Number(c.y ?? c[1] ?? 0).toFixed(2);
    const z = Number(c.z ?? c[2] ?? 0).toFixed(2);
    return `(${x}, ${y}, ${z})`;
  }

  function pinSvg() {
    return `<svg viewBox="0 0 24 24" aria-hidden="true"><path d="M12 2C8.13 2 5 5.13 5 9c0 5.25 7 13 7 13s7-7.75 7-13c0-3.87-3.13-7-7-7zm0 9.5c-1.38 0-2.5-1.12-2.5-2.5S10.62 6.5 12 6.5s2.5 1.12 2.5 2.5S13.38 11.5 12 11.5z"/></svg>`;
  }

  function checkSvg() {
    return `<svg viewBox="0 0 24 24" aria-hidden="true"><path d="M9 16.17 4.83 12l-1.42 1.41L9 19 21 7l-1.41-1.41z"/></svg>`;
  }




  window.addEventListener("message", (ev) => {
    const msg = ev.data || {};
    if (msg.type !== "sync") return;

    state.open = !!msg.open;
    state.theme = msg.theme || state.theme;
    state.discord = msg.discord || state.discord;
    state.quests = Array.isArray(msg.quests) ? msg.quests : [];
    state.progress = msg.progress || {};
    state.activeQuestId = msg.activeQuestId || null;

    applyTheme(state.theme);

    if (state.open) {
      openUI();
      render();
    } else {
      elApp.classList.add("hidden");
      elApp.setAttribute("aria-hidden", "true");
    }
  });

  btnClose.addEventListener("click", closeUI);
  elApp.addEventListener("click", (e) => {
    const t = e.target;
    if (t && t.classList && t.classList.contains("overlay")) closeUI();
  });

  elSearch.addEventListener("input", (e) => {
    state.search = e.target.value || "";
    renderList();
  });

  btnTrack.addEventListener("click", () => {
    const quest = getQuest(state.selectedQuestId);
    if (!quest) return;
    postNui("trackQuest", { id: quest.id });
  });

  btnUntrack.addEventListener("click", () => postNui("untrack"));

  btnReset.addEventListener("click", () => {
    const quest = getQuest(state.selectedQuestId);
    if (!quest) return;
    postNui("resetQuest", { id: quest.id });
  });


  document.addEventListener("keydown", (e) => {
    if (e.key === "Escape") closeUI();
  });
})();
