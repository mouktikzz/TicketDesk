// ── API base URL ──────────────────────────────────────────────────────────────
const BASE_URL = "http://0.0.0.0:8000";

// Generic fetch wrapper with error handling
async function apiFetch(path, options = {}) {
  try {
    const res = await fetch(`${BASE_URL}${path}`, {
      headers: { "Content-Type": "application/json", ...options.headers },
      ...options,
    });
    if (!res.ok) {
      const err = await res.json().catch(() => ({ detail: res.statusText }));
      throw new Error(err.detail || "API error");
    }
    return res.status === 204 ? null : res.json();
  } catch (e) {
    showToast(e.message, "error");
    throw e;
  }
}

// ── Dashboard ─────────────────────────────────────────────────────────────────
export const getDashboard = () => apiFetch("/api/dashboard");

// ── Tickets ───────────────────────────────────────────────────────────────────
export const getTickets = (params = {}) => {
  const qs = new URLSearchParams(
    Object.fromEntries(Object.entries(params).filter(([, v]) => v))
  ).toString();
  return apiFetch(`/api/tickets${qs ? "?" + qs : ""}`);
};

export const getTicket = (id) => apiFetch(`/api/tickets/${id}`);

export const createTicket = (body) =>
  apiFetch("/api/tickets", {
    method: "POST",
    body: JSON.stringify(body),
  });

export const updateStatus = (id, status) =>
  apiFetch(`/api/tickets/${id}/status`, {
    method: "PATCH",
    body: JSON.stringify({ status }),
  });

// ── Comments ──────────────────────────────────────────────────────────────────
export const addComment = (ticketId, author, body) =>
  apiFetch(`/api/tickets/${ticketId}/comments`, {
    method: "POST",
    body: JSON.stringify({ author, body }),
  });

// ── Attachments ───────────────────────────────────────────────────────────────
export const uploadAttachment = async (ticketId, file) => {
  // 1. Ask FastAPI for a presigned S3 upload URL
  const params = new URLSearchParams({
    filename: file.name,
    content_type: file.type || "application/octet-stream",
  });

  const presigned = await apiFetch(
    `/api/tickets/${ticketId}/attachments/presigned-url?${params.toString()}`
  );

  // 2. Upload the file directly to S3
  const uploadResponse = await fetch(presigned.upload_url, {
    method: "PUT",
    headers: {
      "Content-Type": file.type || "application/octet-stream",
    },
    body: file,
  });

  if (!uploadResponse.ok) {
    throw new Error("Failed to upload file to S3");
  }

  // 3. Tell FastAPI that the S3 upload completed
  return apiFetch(
    `/api/tickets/${ticketId}/attachments/complete?${new URLSearchParams({
      filename: file.name,
      object_key: presigned.object_key,
    }).toString()}`,
    {
      method: "POST",
    }
  );
};

// S3 objects are private, so we don't use the old /uploads/ URL anymore.
export const getFileUrl = async (storedName) => {
  const params = new URLSearchParams({
    object_key: storedName,
  });

  const result = await apiFetch(
    `/api/attachments/url?${params.toString()}`
  );

  return result.download_url;
};

// ── Toast notification ────────────────────────────────────────────────────────
export function showToast(message, type = "success") {
  const container = document.getElementById("toast-container");
  const toast = document.createElement("div");
  toast.className = `toast toast--${type}`;
  toast.innerHTML = `
    <span class="toast__icon">${type === "error" ? "✕" : "✓"}</span>
    <span>${message}</span>
  `;
  container.appendChild(toast);
  // Trigger animation
  requestAnimationFrame(() => toast.classList.add("toast--visible"));
  setTimeout(() => {
    toast.classList.remove("toast--visible");
    setTimeout(() => toast.remove(), 300);
  }, 3500);
}
