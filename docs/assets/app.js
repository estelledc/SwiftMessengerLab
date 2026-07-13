const typeNames = [
  "PropertyBox",
  "MessageDraft",
  "ValueCounter",
  "ReferenceCounter",
  "Optional",
  "DeliveryState",
  "MessageTransport",
  "CaptureOwner",
  "String",
  "Array",
  "Set",
  "Dictionary",
  "UUID",
  "Date",
  "URL",
  "Data",
  "FileManager",
  "Task",
  "Result",
  "UIResponder",
  "UIApplication",
  "UIScene",
  "UIWindow",
  "UIView",
  "NSLayoutAnchor",
  "NSLayoutConstraint",
  "UIStackView",
  "UIViewController",
  "UINavigationItem",
  "UINavigationController",
  "UILabel",
  "UIImageView",
  "UIControl",
  "UIButton",
  "UIButton.Configuration",
  "UITextField",
  "UITextView",
  "UITextFieldDelegate",
  "UITextViewDelegate",
  "UIScrollView",
  "UICollectionView",
  "UICollectionViewCell",
  "UICollectionViewDataSource",
  "UICollectionViewDelegate",
  "UICollectionViewDiffableDataSource",
  "NSDiffableDataSourceSnapshot",
  "AppEnvironment",
  "MessageRepository",
  "JSONInboxCache",
  "MockMessageTransport",
  "Message",
  "InboxSnapshot",
];

const list = document.querySelector("#type-list");
const input = document.querySelector("#type-filter");
const count = document.querySelector("#type-count");

function renderTypes(query = "") {
  const normalized = query.trim().toLocaleLowerCase();
  const matches = typeNames.filter((name) => name.toLocaleLowerCase().includes(normalized));
  list.replaceChildren(...matches.map((name) => {
    const chip = document.createElement("span");
    chip.className = "type-chip";
    chip.textContent = name;
    return chip;
  }));
  count.textContent = `${matches.length} / ${typeNames.length} types`;
}

input.addEventListener("input", () => renderTypes(input.value));
renderTypes();
