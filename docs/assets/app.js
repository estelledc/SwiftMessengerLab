"use strict";

const catalogURL = "assets/type-catalog.json";
const repositorySourceBase = "https://github.com/estelledc/SwiftMessengerLab/blob/main/";
const controlLabels = {
  valueStepper: "数值变化",
  propertyObserver: "属性观察",
  text: "文本与集合",
  valueReference: "值与引用",
  stateMachine: "状态机代理",
  ownership: "所有权代理",
  foundation: "Foundation 代理",
  concurrency: "并发代理",
  navigation: "导航与生命周期",
  viewAppearance: "视图外观",
  button: "控件事件",
  textInput: "文本输入",
  collection: "列表与稳定身份",
};

const list = document.querySelector("#type-list");
const queryInput = document.querySelector("#type-filter");
const moduleSelect = document.querySelector("#type-module-filter");
const kindSelect = document.querySelector("#type-kind-filter");
const count = document.querySelector("#type-count");
const resetButton = document.querySelector("#type-reset");
const expandButton = document.querySelector("#type-expand");
const collapseButton = document.querySelector("#type-collapse");

const state = {
  cards: [],
  query: "",
  module: "all",
  kind: "all",
};

function element(tag, className, text) {
  const node = document.createElement(tag);
  if (className) node.className = className;
  if (text !== undefined) node.textContent = text;
  return node;
}

function appendTextRow(container, term, description) {
  const row = element("div", "type-card__fact");
  row.append(element("dt", "", term), element("dd", "", description));
  container.append(row);
}

function appendBadge(container, text, variant = "") {
  const badge = element("span", `type-badge${variant ? ` type-badge--${variant}` : ""}`, text);
  container.append(badge);
}

function sourceURL(path) {
  return repositorySourceBase + path.split("/").map(encodeURIComponent).join("/");
}

function lessonLabel(lessons) {
  return lessons.map((lesson) => `L${lesson.id}`).join(" · ");
}

function identifierName(identifier) {
  const name = element("span", "type-card__name");
  const parts = identifier
    .replace(/([a-z0-9])([A-Z])/g, "$1\0$2")
    .replaceAll(".", ".\0")
    .split("\0");

  parts.forEach((part, index) => {
    if (index > 0) {
      name.append(document.createElement("wbr"));
    }
    name.append(part);
  });
  return name;
}

function searchableText(card) {
  const { metadata, lessons, experiment } = card;
  return [
    metadata.id,
    metadata.name,
    metadata.kind,
    metadata.module,
    metadata.purpose,
    metadata.analogy,
    ...metadata.inheritance,
    ...metadata.conformances,
    ...metadata.relatedTypeIDs,
    ...metadata.properties.flatMap((property) => [property.name, property.type, property.access]),
    ...metadata.methods.map((method) => method.signature),
    ...lessons.flatMap((lesson) => [lesson.title, lesson.coreAbility, `lesson ${lesson.id}`]),
    experiment.control,
    experiment.sourceFile,
  ].join(" ").toLocaleLowerCase();
}

function apiList(items, renderItem, emptyText) {
  if (items.length === 0) return element("p", "type-card__empty-line", emptyText);
  const output = element("ul", "type-api-list");
  items.forEach((item) => output.append(renderItem(item)));
  return output;
}

function propertyRow(property) {
  const item = element("li");
  item.append(element("code", "", `${property.name}: ${property.type}`));
  appendBadge(item, property.access, property.access === "get-only" ? "readonly" : "mutable");
  return item;
}

function methodRow(method) {
  const item = element("li");
  item.append(element("code", "", method.signature));
  return item;
}

function relationList(metadata) {
  const relations = element("dl", "type-card__facts");
  if (metadata.inheritance.length > 0) appendTextRow(relations, "继承", metadata.inheritance.join("、"));
  if (metadata.conformances.length > 0) appendTextRow(relations, "遵循协议", metadata.conformances.join("、"));
  if (metadata.relatedTypeIDs.length > 0) appendTextRow(relations, "关联类型", metadata.relatedTypeIDs.join("、"));
  if (relations.children.length === 0) appendTextRow(relations, "类型关系", "本卡未声明继承、协议或关联类型");
  return relations;
}

function ownershipList(metadata) {
  const ownership = element("dl", "type-card__facts");
  appendTextRow(ownership, "谁创建", metadata.createdBy);
  appendTextRow(ownership, "谁持有", metadata.ownedBy);
  appendTextRow(ownership, "何时释放", metadata.releasedWhen);
  return ownership;
}

function lessonList(lessons) {
  const output = element("ul", "type-card__lesson-list");
  lessons.forEach((lesson) => {
    const item = element("li");
    item.append(
      element("strong", "", `Lesson ${lesson.id} · ${lesson.title}`),
      element("span", "", lesson.coreAbility),
    );
    output.append(item);
  });
  return output;
}

function cardSection(title, content) {
  const section = element("section", "type-card__section");
  section.append(element("h4", "", title), content);
  return section;
}

function typeCard(card, openIDs) {
  const { metadata, lessons, experiment } = card;
  const details = element("details", "type-card");
  details.dataset.typeId = metadata.id;
  details.open = openIDs.has(metadata.id);

  const summary = element("summary", "type-card__summary");
  const meta = element("span", "type-card__meta");
  appendBadge(meta, metadata.module, "module");
  appendBadge(meta, metadata.kind, metadata.kind);
  appendBadge(meta, lessonLabel(lessons), "lesson");
  summary.append(
    meta,
    identifierName(metadata.name),
    element("span", "type-card__purpose", metadata.purpose),
    element("span", "type-card__disclosure"),
  );

  const body = element("div", "type-card__body");
  const definition = element("div", "type-card__definition");
  definition.append(
    element("span", "type-card__definition-label", "日常类比"),
    element("p", "", metadata.analogy),
  );

  const apiColumns = element("div", "type-card__columns");
  apiColumns.append(
    cardSection(
      "精选属性",
      apiList(metadata.properties, propertyRow, "本卡没有列出可直接学习的实例属性。"),
    ),
    cardSection(
      "精选方法",
      apiList(metadata.methods, methodRow, "本卡没有列出方法。"),
    ),
  );

  const relationColumns = element("div", "type-card__columns");
  relationColumns.append(
    cardSection("类型关系", relationList(metadata)),
    cardSection("所有权学习提示", ownershipList(metadata)),
  );

  const experimentBlock = element("div", "type-card__experiment");
  const experimentText = element(
    "p",
    "",
    `App 实验族：${controlLabels[experiment.control] ?? experiment.control}。这是共享教学 renderer 的分类；网页不执行 App、LLDB 或源码改值。`,
  );
  const sourceLink = element("a", "type-card__source", `查看仓库内观察入口 · ${experiment.sourceFile} ↗`);
  sourceLink.href = sourceURL(experiment.sourceFile);
  sourceLink.target = "_blank";
  sourceLink.rel = "noopener";
  experimentBlock.append(experimentText, sourceLink);
  if (experiment.compilerSample) {
    const command = element("p", "type-card__command");
    command.append("概念类比样本：", element("code", "", `make compiler-lab SAMPLE=${experiment.compilerSample}`));
    experimentBlock.append(command);
  }

  body.append(
    definition,
    apiColumns,
    relationColumns,
    cardSection("关联课程", lessonList(lessons)),
    cardSection("继续研究", experimentBlock),
    element("p", "type-card__caveat", "属性默认值、方法输入输出和生命周期文案中含目录级学习模板；这里展示精选入口，不把它当作完整 SDK API 参考。"),
  );
  details.append(summary, body);
  return details;
}

function matchingCards() {
  const normalizedQuery = state.query.trim().toLocaleLowerCase();
  return state.cards.filter(({ metadata, searchText }) => {
    const matchesQuery = normalizedQuery === "" || searchText.includes(normalizedQuery);
    const matchesModule = state.module === "all" || metadata.module === state.module;
    const matchesKind = state.kind === "all" || metadata.kind === state.kind;
    return matchesQuery && matchesModule && matchesKind;
  });
}

function renderCards() {
  const openIDs = new Set(
    Array.from(list.querySelectorAll("details[open]"), (details) => details.dataset.typeId),
  );
  const matches = matchingCards();
  const nodes = matches.map((card) => typeCard(card, openIDs));
  if (nodes.length === 0) {
    nodes.push(element("p", "lab-type-empty", "没有匹配的类型卡。试试清空搜索词或切换筛选条件。"));
  }
  list.replaceChildren(...nodes);
  count.textContent = `${matches.length} / ${state.cards.length} 张类型卡`;
}

function addOptions(select, values, cards, property) {
  values.forEach((value) => {
    const option = element("option", "", `${value} (${cards.filter((card) => card.metadata[property] === value).length})`);
    option.value = value;
    select.append(option);
  });
}

function validateCatalog(documentData) {
  if (documentData?.schemaVersion !== 1 || !Array.isArray(documentData.cards)) {
    throw new Error("unsupported type catalog schema");
  }
  if (documentData.cards.length !== 52) {
    throw new Error(`expected 52 cards, received ${documentData.cards.length}`);
  }
  const ids = new Set(documentData.cards.map((card) => card.metadata?.id));
  if (ids.size !== documentData.cards.length || ids.has(undefined)) {
    throw new Error("type catalog IDs must be present and unique");
  }
}

async function loadCatalog() {
  try {
    const response = await fetch(catalogURL);
    if (!response.ok) throw new Error(`catalog request failed with ${response.status}`);
    const documentData = await response.json();
    validateCatalog(documentData);
    state.cards = documentData.cards.map((card) => ({
      ...card,
      searchText: searchableText(card),
    }));

    const modules = [...new Set(state.cards.map((card) => card.metadata.module))];
    const kinds = [...new Set(state.cards.map((card) => card.metadata.kind))];
    addOptions(moduleSelect, modules, state.cards, "module");
    addOptions(kindSelect, kinds, state.cards, "kind");
    list.setAttribute("aria-busy", "false");
    renderCards();
  } catch (error) {
    list.setAttribute("aria-busy", "false");
    list.replaceChildren(element("p", "lab-type-empty", "类型卡数据加载失败。请刷新页面，或在仓库中查看 docs/assets/type-catalog.json。"));
    count.textContent = "类型卡加载失败";
    console.error(error);
  }
}

queryInput.addEventListener("input", () => {
  state.query = queryInput.value;
  renderCards();
});

moduleSelect.addEventListener("change", () => {
  state.module = moduleSelect.value;
  renderCards();
});

kindSelect.addEventListener("change", () => {
  state.kind = kindSelect.value;
  renderCards();
});

resetButton.addEventListener("click", () => {
  queryInput.value = "";
  moduleSelect.value = "all";
  kindSelect.value = "all";
  state.query = "";
  state.module = "all";
  state.kind = "all";
  renderCards();
  queryInput.focus();
});

expandButton.addEventListener("click", () => {
  list.querySelectorAll("details").forEach((details) => { details.open = true; });
});

collapseButton.addEventListener("click", () => {
  list.querySelectorAll("details").forEach((details) => { details.open = false; });
});

loadCatalog();
