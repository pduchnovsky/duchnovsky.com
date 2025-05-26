// static/admin/notice-component.js

CMS.registerEditorComponent({
  id: "notice", // Unique ID for your component
  label: "Notice Block", // Label shown in Decap CMS UI
  fields: [
    {
      name: "type",
      label: "Notice Type",
      widget: "select",
      options: [
        { label: "Note", value: "note" },
        { label: "Tip", value: "tip" },
        { label: "Example", value: "example" },
        { label: "Question", value: "question" },
        { label: "Info", value: "info" },
        { label: "Warning", value: "warning" },
        { label: "Error", value: "error" },
      ],
      default: "note",
    },
    {
      name: "title",
      label: "Title (Optional)",
      widget: "string",
      required: false,
    },
    {
      name: "body",
      label: "Content",
      widget: "markdown",
      editor_components: ["image", "code-block"],
    },
  ],
  pattern:
    /^{{\<\s*notice\s+([a-z]+)\s*(?:\"(.*?)\")?\s*\>}}(.*?){{\<\s*\/notice\s*\>}}$/s,
  fromBlock: function (match) {
    return {
      type: match[1],
      title: match[2] || "",
      body: match[3],
    };
  },
  toBlock: function (obj) {
    const titlePart = obj.title ? ` "${obj.title}"` : "";
    return `{{< notice ${obj.type}${titlePart} >}}\n${obj.body}\n{{< /notice >}}`;
  },
  toPreview: function (obj) {
    // Basic preview HTML - can be styled further with CSS loaded in admin/index.html
    const iconMap = {
      note: "fa-sticky-note",
      tip: "fa-lightbulb",
      example: "fa-file-text",
      question: "fa-question",
      info: "fa-exclamation-circle",
      warning: "fa-exclamation-triangle",
      error: "fa-times-circle",
    };
    const iconClass = iconMap[obj.type] || "fa-question-circle";

    const titleText = obj.title
      ? `<strong>${obj.title}</strong>`
      : `<strong>${
          obj.type.charAt(0).toUpperCase() + obj.type.slice(1)
        }</strong>`;

    return `
      <div style="padding: 15px; margin: 15px 0; border-radius: 5px; border-left: 5px solid #ccc; background-color: #f8f8f8;">
        <div style="font-weight: bold; margin-bottom: 10px; display: flex; align-items: center;">
          <i class="${iconClass}" style="margin-right: 8px; color: #666;"></i>
          ${titleText}
        </div>
        <div style="margin-top: 5px;">
          ${obj.body}
        </div>
      </div>
    `;
  },
});
