import UIKit

final class GuideViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Guided Experiment"
        view.backgroundColor = .systemBackground

        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isEditable = false
        textView.adjustsFontForContentSizeCategory = true
        textView.font = .preferredFont(forTextStyle: .body)
        textView.text = """
        第一次只做一条消息发送链路。

        1. 先预测
           普通文本会按什么顺序经过 UI、Repository、Transport，再回到 UI？

        2. 发送成功
           回到 Messenger，打开 Design Study Group，发送 hello。
           你要看到状态从 sending 变成 sent。

        3. 发送失败与重试
           输入 /fail，等它变成 failed，再点失败消息重试。
           你要证明同一个 message id 被重试，不是新增一条重复消息。

        4. 看 Logs
           找到 UI -> Repository -> Transport -> Repository -> UI。
           Logs 证明顺序；断点和 Call Stack 证明谁调用谁。

        5. 再学类型
           完成发送链路后，再去第 11 课 UIView 类型卡。
           先操作 App 控件，再看 LLDB 命令，最后改源码默认值。

        完成标准：
        - 能区分 Message.id 和 serverID。
        - 能解释 failed 消息为什么可以原地 retry。
        - 能指出 Reset Learning Progress 不会删除 Messenger 消息。

        完整问题和断点见 docs/guided-learning.md。
        """

        view.addSubview(textView)
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            textView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            textView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            textView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}
