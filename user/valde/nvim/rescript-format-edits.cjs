const diff = require("fast-diff");

module.exports = function formattingEdits(protocol, original, formatted) {
  const document = protocol.TextDocument.create("", "rescript", 0, original);
  let offset = 0;

  return diff(original, formatted).flatMap(([operation, text]) => {
    const start = document.positionAt(offset);
    if (operation !== diff.INSERT) {
      offset += text.length;
    }
    return operation !== diff.EQUAL
      ? [protocol.TextEdit.replace(
          { start, end: document.positionAt(offset) },
          operation === diff.INSERT ? text : "",
        )]
      : [];
  });
};
