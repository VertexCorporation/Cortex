"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const ext_apps_1 = require("@modelcontextprotocol/ext-apps");
const app = new ext_apps_1.App({ name: "firebase-init", version: "1.0.0" });
const initBtn = document.getElementById("init-btn");
const statusBox = document.getElementById("status-box");
const productRadios = document.getElementsByName("product");
const firestoreSection = document.getElementById("firestore-section");
const authSection = document.getElementById("auth-section");
const googleCheckbox = document.getElementById("auth-google");
const googleFields = document.getElementById("google-fields");
const searchInput = document.getElementById("search-input");
const projectListContainer = document.getElementById("project-list");
let projects = [];
let filteredProjects = [];
let selectedProjectId = null;
function setStatus(message, type = "info") {
    statusBox.className = `status ${type}`;
    statusBox.textContent = message;
    statusBox.style.display = "block";
}
function renderProjects() {
    projectListContainer.innerHTML = "";
    if (filteredProjects.length === 0) {
        const empty = document.createElement("div");
        empty.className = "dropdown-item";
        empty.style.cursor = "default";
        empty.innerHTML = `<div class="item-name">No projects found</div>`;
        projectListContainer.appendChild(empty);
        return;
    }
    filteredProjects.forEach((project) => {
        const item = document.createElement("div");
        item.className = "dropdown-item";
        if (project.projectId === selectedProjectId) {
            item.classList.add("selected");
        }
        const displayName = project.displayName || project.projectId;
        const projectId = project.projectId;
        item.innerHTML = `
      <div class="item-name">${displayName}</div>
      <div class="item-id">${projectId}</div>
    `;
        item.onclick = () => {
            selectedProjectId = projectId;
            initBtn.disabled = false;
            renderProjects();
        };
        projectListContainer.appendChild(item);
    });
}
searchInput.oninput = () => {
    const query = searchInput.value.toLowerCase().trim();
    if (query === "") {
        filteredProjects = projects;
    }
    else {
        filteredProjects = projects.filter((p) => {
            const name = (p.displayName || p.projectId).toLowerCase();
            const id = p.projectId.toLowerCase();
            return name.includes(query) || id.includes(query);
        });
    }
    renderProjects();
};
productRadios.forEach((radio) => {
    radio.addEventListener("change", (e) => {
        const target = e.target;
        if (target.checked) {
            if (target.value === "firestore") {
                firestoreSection.classList.add("active");
                authSection.classList.remove("active");
            }
            else if (target.value === "auth") {
                authSection.classList.add("active");
                firestoreSection.classList.remove("active");
            }
        }
    });
});
googleCheckbox.addEventListener("change", (e) => {
    const target = e.target;
    if (target.checked) {
        googleFields.classList.add("active");
    }
    else {
        googleFields.classList.remove("active");
    }
});
initBtn.addEventListener("click", async () => {
    const selectedProduct = Array.from(productRadios).find((r) => r.checked)?.value;
    if (!selectedProjectId) {
        setStatus("Please select a project first.", "error");
        return;
    }
    initBtn.disabled = true;
    initBtn.textContent = "Initializing...";
    setStatus("Setting active project...", "info");
    try {
        const updateResult = await app.callServerTool({
            name: "firebase_update_environment",
            arguments: { active_project: selectedProjectId },
        });
        if (updateResult.isError) {
            setStatus(`Failed to set active project: ${JSON.stringify(updateResult.content)}`, "error");
            initBtn.disabled = false;
            initBtn.textContent = "Initialize";
            return;
        }
        setStatus("Initializing product...", "info");
        const args = { features: {} };
        if (selectedProduct === "firestore") {
            const dbId = document.getElementById("firestore-db-id").value;
            const rulesFile = document.getElementById("firestore-rules-file").value;
            args.features.firestore = {
                database_id: dbId,
                rules_filename: rulesFile,
            };
        }
        else if (selectedProduct === "auth") {
            const emailEnabled = document.getElementById("auth-email").checked;
            const anonymousEnabled = document.getElementById("auth-anonymous")
                .checked;
            const googleEnabled = googleCheckbox.checked;
            args.features.auth = {
                providers: {
                    emailPassword: emailEnabled,
                    anonymous: anonymousEnabled,
                },
            };
            if (googleEnabled) {
                const displayName = document.getElementById("google-display-name")
                    .value;
                const supportEmail = document.getElementById("google-support-email")
                    .value;
                args.features.auth.providers.googleSignIn = {
                    oAuthBrandDisplayName: displayName,
                    supportEmail: supportEmail,
                };
            }
        }
        const res = await app.callServerTool({
            name: "firebase_init",
            arguments: args,
        });
        if (res.isError) {
            setStatus(`Failed to initialize: ${JSON.stringify(res.content)}`, "error");
        }
        else {
            setStatus(`Successfully initialized ${selectedProduct}!`, "success");
        }
    }
    catch (err) {
        const message = err instanceof Error ? err.message : String(err);
        setStatus(`Error: ${message}`, "error");
    }
    finally {
        initBtn.disabled = false;
        initBtn.textContent = "Initialize";
    }
});
app.onhostcontextchanged = (ctx) => {
    if (ctx.theme)
        (0, ext_apps_1.applyDocumentTheme)(ctx.theme);
    if (ctx.styles?.variables)
        (0, ext_apps_1.applyHostStyleVariables)(ctx.styles.variables);
    if (ctx.styles?.css?.fonts)
        (0, ext_apps_1.applyHostFonts)(ctx.styles.css.fonts);
    if (ctx.safeAreaInsets) {
        const { top, right, bottom, left } = ctx.safeAreaInsets;
        document.body.style.padding = `${top}px ${right}px ${bottom}px ${left}px`;
    }
};
(async () => {
    const envDirEl = document.getElementById("env-dir");
    try {
        await app.connect();
        setStatus("Connecting to server...", "info");
        try {
            const envResult = await app.callServerTool({
                name: "firebase_get_environment",
                arguments: {},
            });
            if (envResult.isError) {
                throw new Error(`Failed to fetch environment: ${JSON.stringify(envResult.content)}`);
            }
            const envData = envResult.structuredContent;
            if (envData) {
                envDirEl.textContent = envData.projectDir || "<NONE>";
            }
        }
        catch (err) {
            console.error("Failed to fetch environment:", err);
            envDirEl.textContent = "Error loading";
        }
        try {
            const result = await app.callServerTool({
                name: "firebase_list_projects",
                arguments: { page_size: 1000 },
            });
            if (result.isError) {
                throw new Error(`Failed to load projects: ${JSON.stringify(result.content)}`);
            }
            const data = result.structuredContent;
            if (data && data.projects) {
                projects = data.projects;
                filteredProjects = projects;
                renderProjects();
                setStatus("Projects loaded.", "success");
                setTimeout(() => {
                    if (statusBox.className === "status success")
                        statusBox.style.display = "none";
                }, 2000);
            }
            else {
                setStatus("No projects returned from server.", "error");
            }
        }
        catch (err) {
            const message = err instanceof Error ? err.message : String(err);
            setStatus(`Failed to load projects: ${message}`, "error");
        }
    }
    catch (err) {
        const message = err instanceof Error ? err.message : String(err);
        setStatus(`Failed to connect: ${message}`, "error");
        if (envDirEl)
            envDirEl.textContent = "Error loading";
    }
})();
