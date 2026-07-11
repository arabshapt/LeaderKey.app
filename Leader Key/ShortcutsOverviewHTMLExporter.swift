import Foundation

extension ShortcutsOverview {
  struct ExportPayload: Codable, Equatable {
    let configName: String
    let generatedAt: String
    let keyboardRows: [[String]]
    let nodes: [ExportNode]
    let shiftedKeys: [String: String]
  }

  struct ExportNode: Codable, Equatable {
    let children: [ExportNode]
    let displayName: String
    let fallbackSource: String?
    let isFromFallback: Bool
    let key: String?
    let type: String
    let value: String?
  }

  enum ExportError: Error {
    case invalidUTF8
  }

  static func exportJSON(
    configName: String,
    actions: [ActionOrGroup],
    generationDate: Date = Date()
  ) throws -> Data {
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]
    return try encoder.encode(
      ExportPayload(
        configName: configName,
        generatedAt: iso8601String(from: generationDate),
        keyboardRows: keyboardRows,
        nodes: actions.map(exportNode),
        shiftedKeys: shiftedKeyByBaseKey
      ))
  }

  static func exportHTML(
    configName: String,
    actions: [ActionOrGroup],
    generationDate: Date = Date()
  ) throws -> String {
    let jsonData = try exportJSON(
      configName: configName,
      actions: actions,
      generationDate: generationDate
    )
    guard let json = String(data: jsonData, encoding: .utf8) else {
      throw ExportError.invalidUTF8
    }
    let embeddedJSON = scriptSafeJSON(json)

    return #"""
      <!doctype html>
      <html lang="en">
      <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <meta http-equiv="Content-Security-Policy" content="default-src 'none'; script-src 'nonce-leaderkey-export'; style-src 'nonce-leaderkey-export'; img-src data:; connect-src 'none'; font-src 'none'; object-src 'none'; base-uri 'none'; form-action 'none'">
        <title>Leader Key Shortcut Map</title>
        <style nonce="leaderkey-export">
          :root { color-scheme: light dark; font-family: -apple-system, BlinkMacSystemFont, sans-serif; }
          * { box-sizing: border-box; }
          body { margin: 0; background: Canvas; color: CanvasText; }
          main { max-width: 1120px; margin: 0 auto; padding: 28px; }
          header { display: flex; align-items: baseline; gap: 12px; margin-bottom: 18px; }
          h1 { margin: 0; font-size: 24px; }
          .meta { color: GrayText; font-size: 13px; }
          .breadcrumbs { display: flex; align-items: center; flex-wrap: wrap; gap: 6px; min-height: 30px; }
          button { font: inherit; }
          .crumb { border: 0; padding: 2px 4px; background: transparent; color: LinkText; cursor: pointer; }
          .separator { color: GrayText; }
          .keyboard { display: grid; gap: 6px; justify-content: center; margin: 22px 0 14px; }
          .keyboard-row { display: flex; gap: 6px; justify-content: center; }
          .keycap { width: 58px; height: 58px; display: grid; grid-template-rows: 1fr 1fr; overflow: hidden; border: 1px solid color-mix(in srgb, CanvasText 24%, transparent); border-radius: 8px; background: color-mix(in srgb, CanvasText 5%, transparent); }
          .keycap.free { opacity: .55; background: transparent; }
          .key-slot { display: flex; align-items: center; justify-content: center; gap: 3px; min-width: 0; border: 0; color: GrayText; background: transparent; cursor: default; font-size: 12px; }
          .key-slot.assigned { cursor: pointer; font-weight: 650; color: CanvasText; }
          .key-slot.drillable::after { content: "›"; font-weight: 800; }
          .key-slot.inherited { opacity: .7; }
          .key-slot.inherited::before { content: "•"; color: GrayText; }
          .key-slot.conflict::after { content: "⚠"; color: orange; }
          .type-group, .type-layer { background: color-mix(in srgb, AccentColor 22%, transparent); }
          .type-application { background: color-mix(in srgb, mediumpurple 22%, transparent); }
          .type-url { background: color-mix(in srgb, deepskyblue 20%, transparent); }
          .type-command { background: color-mix(in srgb, orange 22%, transparent); }
          .type-shortcut, .type-keystroke { background: color-mix(in srgb, mediumseagreen 22%, transparent); }
          .type-text { background: color-mix(in srgb, hotpink 18%, transparent); }
          .type-macro, .type-menu, .type-other { background: color-mix(in srgb, CanvasText 10%, transparent); }
          .summary { color: GrayText; font-size: 13px; text-align: center; margin-bottom: 24px; }
          .conflicts { color: orange; font-size: 13px; text-align: center; min-height: 18px; }
          .list-header { display: flex; align-items: center; gap: 16px; border-top: 1px solid color-mix(in srgb, CanvasText 16%, transparent); padding-top: 20px; }
          .list-header h2 { margin: 0; font-size: 18px; }
          input { margin-left: auto; width: min(320px, 50vw); padding: 7px 10px; border: 1px solid color-mix(in srgb, CanvasText 24%, transparent); border-radius: 6px; background: Canvas; color: CanvasText; }
          .sequence-group { margin-top: 18px; }
          .sequence-group h3 { margin: 0 0 6px; color: GrayText; font: 600 14px ui-monospace, monospace; }
          .sequence-row { display: grid; grid-template-columns: minmax(150px, 230px) minmax(160px, 1fr) auto; gap: 12px; align-items: start; padding: 8px; border-radius: 6px; background: color-mix(in srgb, CanvasText 3%, transparent); margin: 4px 0; }
          .sequence-keys { font: 650 12px ui-monospace, monospace; }
          .sequence-name { font-weight: 600; }
          .sequence-value, .provenance, .empty { color: GrayText; font-size: 12px; overflow-wrap: anywhere; }
          .provenance { opacity: .7; white-space: nowrap; }
          .empty { padding: 36px 0; text-align: center; }
          @media (max-width: 820px) {
            main { padding: 16px; overflow-x: auto; }
            .keycap { width: 46px; height: 52px; }
            .sequence-row { grid-template-columns: 1fr; }
            .provenance { white-space: normal; }
          }
        </style>
      </head>
      <body>
        <main>
          <header>
            <h1 id="config-name"></h1>
            <span class="meta" id="generation-date"></span>
          </header>
          <nav class="breadcrumbs" id="breadcrumbs" aria-label="Shortcut path"></nav>
          <section class="keyboard" id="keyboard" aria-label="Shortcut keyboard map"></section>
          <div class="summary" id="free-summary"></div>
          <div class="conflicts" id="conflicts" role="status"></div>
          <section>
            <div class="list-header">
              <h2>All Sequences</h2>
              <label for="search">Search</label>
              <input id="search" type="search" placeholder="Search shortcuts">
            </div>
            <div id="sequence-list"></div>
          </section>
        </main>
        <script id="shortcut-data" type="application/json" nonce="leaderkey-export">
      \#(embeddedJSON)
        </script>
        <script nonce="leaderkey-export">
          "use strict";
          const data = JSON.parse(document.getElementById("shortcut-data").textContent);
          const state = { path: [] };
          const byId = (id) => document.getElementById(id);

          function appendText(parent, tag, className, value) {
            const element = document.createElement(tag);
            if (className) element.className = className;
            element.textContent = value;
            parent.appendChild(element);
            return element;
          }

          function exactAssignments(nodes) {
            const primary = new Map();
            const duplicates = new Map();
            for (const node of nodes) {
              if (typeof node.key !== "string" || node.key.length === 0) continue;
              if (!primary.has(node.key)) {
                primary.set(node.key, node);
              } else {
                duplicates.set(node.key, (duplicates.get(node.key) || 0) + 1);
              }
            }
            return { primary, duplicates };
          }

          function resolvePath() {
            let nodes = data.nodes;
            const breadcrumb = [];
            const validPath = [];
            for (const key of state.path) {
              const node = nodes.find((candidate) => candidate.key === key);
              if (!node || !Array.isArray(node.children) || node.children.length === 0) break;
              validPath.push(key);
              breadcrumb.push(node);
              nodes = node.children;
            }
            state.path = validPath;
            return { nodes, breadcrumb };
          }

          function typeClass(type) {
            const allowed = new Set([
              "group", "layer", "application", "url", "command", "shortcut",
              "keystroke", "text", "macro", "menu"
            ]);
            return "type-" + (allowed.has(type) ? type : "other");
          }

          function slotButton(glyph, node, duplicateCount) {
            const button = document.createElement("button");
            button.type = "button";
            button.className = "key-slot";
            button.textContent = glyph;
            if (!node) {
              button.setAttribute("aria-label", glyph + ", unassigned");
              return button;
            }

            button.classList.add("assigned", typeClass(node.type));
            if (node.isFromFallback) button.classList.add("inherited");
            if (duplicateCount > 0) button.classList.add("conflict");
            const drillable = Array.isArray(node.children) && node.children.length > 0;
            if (drillable) button.classList.add("drillable");
            const details = [glyph + ": " + node.displayName];
            if (node.value) details.push(node.value);
            if (node.isFromFallback) details.push("Inherited from " + (node.fallbackSource || "Fallback App Config"));
            if (duplicateCount > 0) details.push(duplicateCount + " duplicate assignment(s)");
            button.title = details.join("\n");
            button.setAttribute("aria-label", details.join(", "));
            if (drillable) {
              button.addEventListener("click", () => {
                state.path.push(node.key);
                renderLevel();
              });
            }
            return button;
          }

          function renderBreadcrumbs(breadcrumb) {
            const container = byId("breadcrumbs");
            container.replaceChildren();
            const root = appendText(container, "button", "crumb", "Root");
            root.type = "button";
            root.addEventListener("click", () => { state.path = []; renderLevel(); });
            breadcrumb.forEach((node, index) => {
              appendText(container, "span", "separator", "›");
              const button = appendText(container, "button", "crumb", node.key + " · " + node.displayName);
              button.type = "button";
              button.addEventListener("click", () => {
                state.path = state.path.slice(0, index + 1);
                renderLevel();
              });
            });
          }

          function renderLevel() {
            const resolved = resolvePath();
            renderBreadcrumbs(resolved.breadcrumb);
            const assignments = exactAssignments(resolved.nodes);
            const keyboard = byId("keyboard");
            keyboard.replaceChildren();
            let freeCount = 0;
            for (const row of data.keyboardRows) {
              const rowElement = document.createElement("div");
              rowElement.className = "keyboard-row";
              for (const baseKey of row) {
                const shiftedKey = data.shiftedKeys[baseKey];
                const baseNode = assignments.primary.get(baseKey);
                const shiftedNode = assignments.primary.get(shiftedKey);
                const cap = document.createElement("div");
                cap.className = "keycap";
                if (!baseNode && !shiftedNode) {
                  cap.classList.add("free");
                  freeCount += 1;
                }
                cap.appendChild(slotButton(shiftedKey, shiftedNode, assignments.duplicates.get(shiftedKey) || 0));
                cap.appendChild(slotButton(baseKey, baseNode, assignments.duplicates.get(baseKey) || 0));
                rowElement.appendChild(cap);
              }
              keyboard.appendChild(rowElement);
            }
            byId("free-summary").textContent = freeCount + " free keys on this grid.";
            let conflictCount = 0;
            for (const count of assignments.duplicates.values()) conflictCount += count;
            byId("conflicts").textContent = conflictCount > 0
              ? conflictCount + " duplicate exact-key assignment(s); the first item is displayed."
              : "";
          }

          function flatten(nodes, prefix, output) {
            nodes.forEach((node, index) => {
              if (typeof node.key !== "string" || node.key.length === 0) return;
              const keys = prefix.concat(node.key);
              if (Array.isArray(node.children) && node.children.length > 0) {
                flatten(node.children, keys, output);
              } else {
                output.push({ node, keys, order: output.length + index });
              }
            });
            return output;
          }

          function matchesSearch(entry, query) {
            if (!query) return true;
            const values = [
              entry.keys.join(" → "), entry.node.displayName, entry.node.value || "",
              entry.node.fallbackSource || ""
            ];
            return values.some((value) => value.toLocaleLowerCase().includes(query));
          }

          function renderList() {
            const query = byId("search").value.trim().toLocaleLowerCase();
            const entries = flatten(data.nodes, [], []).filter((entry) => matchesSearch(entry, query));
            const container = byId("sequence-list");
            container.replaceChildren();
            if (entries.length === 0) {
              appendText(container, "div", "empty", query ? "No matching shortcuts" : "No shortcuts");
              return;
            }

            const groups = new Map();
            for (const entry of entries) {
              const firstKey = entry.keys[0];
              if (!groups.has(firstKey)) groups.set(firstKey, []);
              groups.get(firstKey).push(entry);
            }
            for (const [firstKey, groupEntries] of groups) {
              const section = document.createElement("section");
              section.className = "sequence-group";
              appendText(section, "h3", "", firstKey);
              for (const entry of groupEntries) {
                const row = document.createElement("div");
                row.className = "sequence-row";
                appendText(row, "div", "sequence-keys", entry.keys.join(" → "));
                const description = document.createElement("div");
                appendText(description, "div", "sequence-name", entry.node.displayName);
                if (entry.node.value) appendText(description, "div", "sequence-value", entry.node.value);
                row.appendChild(description);
                appendText(
                  row,
                  "div",
                  "provenance",
                  entry.node.isFromFallback
                    ? "Inherited from " + (entry.node.fallbackSource || "Fallback App Config")
                    : ""
                );
                section.appendChild(row);
              }
              container.appendChild(section);
            }
          }

          byId("config-name").textContent = data.configName;
          byId("generation-date").textContent = "Generated " + data.generatedAt;
          byId("search").addEventListener("input", renderList);
          document.addEventListener("keydown", (event) => {
            if (event.key === "Escape" && state.path.length > 0) {
              state.path.pop();
              renderLevel();
            }
          });
          renderLevel();
          renderList();
        </script>
      </body>
      </html>
      """#
  }

  private static func exportNode(_ node: ActionOrGroup) -> ExportNode {
    ExportNode(
      children: children(of: node)?.map(exportNode) ?? [],
      displayName: node.item.displayName,
      fallbackSource: fallbackSource(node),
      isFromFallback: isFromFallback(node),
      key: node.item.key,
      type: node.item.type.rawValue,
      value: {
        if case .action(let action) = node { return action.value }
        return nil
      }()
    )
  }

  private static func iso8601String(from date: Date) -> String {
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = [.withInternetDateTime]
    formatter.timeZone = TimeZone(secondsFromGMT: 0)
    return formatter.string(from: date)
  }

  private static func scriptSafeJSON(_ json: String) -> String {
    json
      .replacingOccurrences(of: "&", with: "\\u0026")
      .replacingOccurrences(of: "<", with: "\\u003C")
      .replacingOccurrences(of: ">", with: "\\u003E")
      .replacingOccurrences(of: "\u{2028}", with: "\\u2028")
      .replacingOccurrences(of: "\u{2029}", with: "\\u2029")
  }
}
