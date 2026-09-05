.pragma library

function stableHash(value) {
    let hash = 2166136261;
    const text = String(value || "");
    for (let index = 0; index < text.length; index++) {
        hash ^= text.charCodeAt(index);
        hash = Math.imul(hash, 16777619);
    }
    return hash >>> 0;
}

function applications(values) {
    const seen = Object.create(null);
    return values.filter(function(app) {
        const name = String(app.name || "").trim();
        const id = String(app.id || name);
        if (!name || !String(app.command || "").trim() || /^about(?:\s|$)/i.test(name) || seen[id])
            return false;
        seen[id] = true;
        return true;
    }).sort(function(first, second) {
        const difference = stableHash(first.id || first.name) - stableHash(second.id || second.name);
        return difference || String(first.name).localeCompare(String(second.name));
    }).map(function(app) {
        return { id: "app:" + (app.id || app.name), appId: app.id || app.name,
            kind: "app", name: app.name, detail: app.genericName || app.comment || app.id || "Application",
            keywords: [app.name, app.genericName, app.comment, app.id].join(" "), app: app,
            enabled: true };
    });
}

function surfaceCommands(widgets) {
    const aliases = { walls: "wallpaper wallpapers parallax background library", calendar: "calendar weather forecast sundial earth helio",
        media: "resonance music lyrics equalizer pitch pitcher", audio: "volume microphone output mixer pipewire routing",
        network: "wifi wi-fi bluetooth ethernet", battery: "battery power energy", system: "cpu memory temperature system monitor",
        guide: "manual help keyboard bindings shortcuts", capture: "screenshot recording optics", notifications: "alerts history",
        focus: "focus concentration", workspaces: "windows workspace overview", clipboard: "copy paste history", tools: "tools utilities" };
    return widgets.filter(function(widget) { return widget.id !== "apps"; }).map(function(widget) {
        return { id: "surface:" + widget.id, kind: "surface", target: widget.id,
            name: widget.title, detail: "Open " + (widget.title || widget.id),
            keywords: [widget.id, widget.title, aliases[widget.id] || ""].join(" "), enabled: true };
    });
}

function matches(entry, needle) {
    const haystack = [entry.name, entry.detail, entry.keywords || ""].join(" ").toLowerCase();
    // Search words need not follow the order used in the description.
    return needle.split(/\s+/).every(function(word) {
        if (haystack.indexOf(word) >= 0)
            return true;
        let cursor = 0;
        for (let index = 0; index < word.length; index++) {
            cursor = haystack.indexOf(word.charAt(index), cursor);
            if (cursor < 0)
                return false;
            cursor++;
        }
        return true;
    });
}

function filter(entries, query, category, favorites) {
    let needle = String(query || "").trim().toLowerCase();
    const commandsOnly = needle.charAt(0) === ">";
    if (commandsOnly)
        needle = needle.substring(1).trim();
    const saved = favorites || [];
    return entries.filter(function(entry) {
        if (commandsOnly ? entry.kind === "app"
            : category === "apps" ? entry.kind !== "app"
            : category === "actions" ? entry.kind === "app"
            : category === "saved" ? entry.kind !== "app" || saved.indexOf(entry.appId) < 0 : false)
            return false;
        return !needle || matches(entry, needle);
    });
}

function selectedId(entries, currentId) {
    if (entries.some(function(entry) { return entry.id === currentId; }))
        return currentId;
    const available = entries.find(function(entry) { return entry.enabled !== false; });
    return available ? available.id : (entries.length ? entries[0].id : "");
}

function moveSelection(entries, currentId, delta) {
    if (!entries.length)
        return "";
    let index = entries.findIndex(function(entry) { return entry.id === currentId; });
    if (index < 0)
        index = delta > 0 ? -1 : 0;
    return entries[(index + delta + entries.length) % entries.length].id;
}
