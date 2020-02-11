import 'dart:io';

import 'package:somemark/md_parser.dart';

void main(List<String> arguments) {
  var p = UnrolledBlockParser();
  var nodes = p.parse(File('README.md'));
  for (var node in nodes) {
    print('[${node.name}]${node.content}<${node.extra}>');
  }
}
