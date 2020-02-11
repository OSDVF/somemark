import 'dart:io';

import 'package:markdown/markdown.dart';
import 'package:charcode/ascii.dart';

import 'line_io.dart';

///Will return non-nested list of nodes in Markdown Document
class UnrolledBlockParser implements BlockParser {
  LineReader _reader;
  UnrolledBlockParser() {
    document = Document(inlineSyntaxes: [
      LinkSyntax(),
      ImageSyntax(),
      // Allow any punctuation to be escaped.
      EscapeSyntax(),
      // "*" surrounded by spaces is left alone.
      TextSyntax(r' \* ', startCharacter: $space),
      // "_" surrounded by spaces is left alone.
      TextSyntax(r' _ ', startCharacter: $space),
      // Parse "**strong**" and "*emphasis*" tags.
      TagSyntax(r'\*+', requiresDelimiterRun: true),
      // Parse "__strong__" and "_emphasis_" tags.
      TagSyntax(r'_+', requiresDelimiterRun: true),
      StrikethroughSyntax()
    ]);
  }

  List<MdNode> parse(File file) {
    var returnedNodes = <MdNode>[];
    _reader = LineReader.open(file);
    current = _reader.readLine();
    final blockNodes = parseLines();
    for (var bNode in blockNodes) {
      if (bNode is Element) {
        switch (bNode.tag) {
          case 'p':
            final innerNodes =
                InlineParser(bNode.children[0].textContent, document).parse();
            for (var node in innerNodes) {
              if (node is Element) {
                var newNode = MdNode(content: node.textContent, name: node.tag);
                if (node.attributes.values.isNotEmpty) {
                  newNode.extra = node.attributes.values.elementAt(0);
                }
                returnedNodes.add(newNode);
              } else {
                final text = node as Text;
                final content = text.text;
                if (content.isNotEmpty) {
                  returnedNodes.add(MdNode(content: content, name: 'text'));
                }
              }
            }
            returnedNodes.add(MdNode(name:'space'));
            break;
          default:
            returnedNodes.add(MdNode(
                content: bNode.textContent,
                extra: bNode.attributes[0],
                name: bNode.tag));
        }
      } else {
        returnedNodes.add(MdNode(
          content: bNode.textContent,
        ));
      }
    }
    return returnedNodes;
  }

  @override
  bool encounteredBlankLine;

  @override
  void advance() {
    current = _reader.readLine();
  }

  @override
  List<BlockSyntax> get blockSyntaxes => standardBlockSyntaxes;

  @override
  String current;

  @override
  Document document;

  @override
  bool get isDone =>
      _reader.file.positionSync() == _reader.file.lengthSync() - 1 ||
      current == null;

  @override
  // TODO: implement lines
  List<String> get lines => throw UnimplementedError();

  @override
  bool matches(RegExp regex) {
    return regex.hasMatch(current);
  }

  @override
  bool matchesNext(RegExp regex) {
    // TODO: implement matchesNext
    throw UnimplementedError();
  }

  @override
  // TODO: implement next
  String get next => throw UnimplementedError();

  @override
  List<Node> parseLines() {
    var blocks = <Node>[];
    while (!isDone) {
      for (var syntax in blockSyntaxes) {
        if (syntax.canParse(this)) {
          var block = syntax.parse(this);
          if (block != null) blocks.add(block);
          break;
        }
      }
    }

    return blocks;
  }

  @override
  String peek(int linesAhead) {
    // TODO: implement peek
    throw UnimplementedError();
  }

  @override
  List<BlockSyntax> get standardBlockSyntaxes => [
        const EmptyBlockSyntax(),
        const HeaderWithIdSyntax(),
        const BlockquoteSyntax(),
        const HorizontalRuleSyntax(),
        const UnorderedListSyntax(),
        const OrderedListSyntax(),
        const ParagraphSyntax()
      ];
}

class MdNode {
  String name;
  String content;
  String extra;
  MdNode({this.name, this.content, this.extra});
}

class NodeType {
  static const String paragraph = 'p';
  static const String link = 'a';
  static const String image = 'img';
  static const String bold = 'b';
  static const String heading1 = 'h1';
  static const String heading2 = 'h2';
  static const String heading3 = 'h3';
}
