import 'package:flutter/material.dart';
import 'package:jieba_flutter/analysis/jieba_segmenter.dart';
import 'package:jieba_flutter/analysis/seg_token.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await JiebaSegmenter.init();
  runApp(const JiebaDemoApp());
}

class JiebaDemoApp extends StatelessWidget {
  const JiebaDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jieba Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: const JiebaDemoPage(),
    );
  }
}

class JiebaDemoPage extends StatefulWidget {
  const JiebaDemoPage({super.key});

  @override
  State<JiebaDemoPage> createState() => _JiebaDemoPageState();
}

class _JiebaDemoPageState extends State<JiebaDemoPage> {
  final _segmenter = JiebaSegmenter();
  final _inputController = TextEditingController(
    text: '结过婚和尚未结过婚的都可以参加活动',
  );

  SegMode _mode = SegMode.SEARCH;
  List<SegToken> _tokens = const [];

  @override
  void initState() {
    super.initState();
    _segment();
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  void _segment() {
    setState(() {
      _tokens = _segmenter.process(_inputController.text.trim(), _mode);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('jieba_flutter 分词示例')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _inputController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: '输入中文文本',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            SegmentedButton<SegMode>(
              segments: const [
                ButtonSegment(value: SegMode.SEARCH, label: Text('SEARCH')),
                ButtonSegment(value: SegMode.INDEX, label: Text('INDEX')),
              ],
              selected: {_mode},
              onSelectionChanged: (selection) {
                setState(() => _mode = selection.first);
                _segment();
              },
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _segment,
              child: const Text('开始分词'),
            ),
            const SizedBox(height: 12),
            Text('共 ${_tokens.length} 个分词结果'),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.separated(
                itemCount: _tokens.length,
                separatorBuilder: (_, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final token = _tokens[index];
                  return ListTile(
                    dense: true,
                    title: Text(token.word),
                    subtitle:
                        Text('start=${token.startOffset}, end=${token.endOffset}'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
