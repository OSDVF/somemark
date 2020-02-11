import 'dart:convert';
import 'dart:io';

class LineReader {
  static const bufferSize = 3; //Must be (multiplies of 4)-1
  RandomAccessFile file;
  LineReader.open(File openedfile) {
    file = openedfile.openSync(mode: FileMode.read);
  }

  String readLine({String lineDelimiter = '\n', bool allowMalformed = false}) {
    final decoder = Utf8Decoder(allowMalformed: allowMalformed);

    var line = '';
    int byte;
    var priorChar = '';

    var foundDelimiter = false;
    var bytes = <int>[];
    while (true) {
      byte = file.readByteSync();
      if (byte == -1) {
        break;
      }
      bytes.add(byte);
      try {
        var char = decoder.convert(bytes);

        if (isLineDelimiter(priorChar, char, lineDelimiter)) {
          foundDelimiter = true;
          break;
        }

        line += char;
        priorChar = char;
        bytes = <int>[];//Clear buffer on success
      } on FormatException {
        continue;
      }
    }

    if (line.isEmpty && foundDelimiter == false) {
      line = null;
    }
    return line;
  }

  bool isLineDelimiter(String priorChar, String char, String lineDelimiter) {
    if (lineDelimiter.length == 1) {
      return char == lineDelimiter;
    } else {
      return priorChar + char == lineDelimiter;
    }
  }
}
