export interface ResultCopyBlock {
  title?: string;
  paragraphs: string[];
  items: string[];
}

const SECTION_TITLE = /^(?:💫|🎯|💬|⚠️)\s*\S/u;
const BULLET = /^(?:•|[-*])\s+(.+)$/u;

export function parseStructuredResultText(value: string): ResultCopyBlock[] | null {
  const groups = value
    .replace(/\r\n?/g, '\n')
    .split(/\n\s*\n/u)
    .map((group) => group.split('\n').map((line) => line.trim()).filter(Boolean))
    .filter((group) => group.length > 0);

  const structured = groups.some((group) => SECTION_TITLE.test(group[0] ?? ''))
    || groups.some((group) => group.some((line) => BULLET.test(line)));
  if (!structured) return null;

  return groups.map((group) => {
    const lines = [...group];
    const title = SECTION_TITLE.test(lines[0] ?? '') ? lines.shift() : undefined;
    const paragraphs: string[] = [];
    const items: string[] = [];

    for (const line of lines) {
      const bullet = line.match(BULLET);
      if (bullet) items.push(bullet[1]);
      else paragraphs.push(line);
    }

    return { title, paragraphs, items };
  });
}
