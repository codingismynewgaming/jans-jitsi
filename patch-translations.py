import json
import os
import glob

def patch_file(filepath):
    if not os.path.exists(filepath):
        return

    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            data = json.load(f)
    except Exception as e:
        print(f"Fehler beim Lesen von {filepath}: {e}")
        return

    def clean_text(text):
        if not isinstance(text, str):
            return text
        t = text
        t = t.replace("Die Kühne Runde", "Jans Jitsi")
        t = t.replace("Kühne Runde", "Jans Jitsi")
        t = t.replace("Mutig reden, kühn zuhören. Kaffee bringt jeder selbst mit.", "Calls mit Jan")
        t = t.replace("Mutig reden, kühn zuhören.", "")
        t = t.replace("Danke fürs Kühnsein, bis zum nächsten Mal!", "Vielen Dank für Ihre Teilnahme!")
        t = t.replace("Danke fürs Kühnsein", "Vielen Dank")
        return t

    def walk_and_patch(node):
        if isinstance(node, dict):
            for k, v in list(node.items()):
                if isinstance(v, str):
                    node[k] = clean_text(v)
                elif isinstance(v, (dict, list)):
                    walk_and_patch(v)
            if "headerSubtitle" in node:
                node["headerSubtitle"] = "Calls mit Jan"
        elif isinstance(node, list):
            for item in node:
                walk_and_patch(item)

    walk_and_patch(data)

    # Direkte Absicherung für Jitsi WelcomePage Strukturen
    if "welcomepage" in data and isinstance(data["welcomepage"], dict):
        data["welcomepage"]["headerTitle"] = "Jans Jitsi"
        data["welcomepage"]["headerSubtitle"] = "Calls mit Jan"
        if "title" in data["welcomepage"]:
            data["welcomepage"]["title"] = "Jans Jitsi"

    if "headerTitle" in data:
        data["headerTitle"] = "Jans Jitsi"
    if "headerSubtitle" in data:
        data["headerSubtitle"] = "Calls mit Jan"
    if "appDescription" in data:
        data["appDescription"] = "Jans Jitsi"

    with open(filepath, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
    print(f"Patched: {filepath}")

for path in glob.glob("/usr/share/jitsi-meet/lang/*.json"):
    patch_file(path)
