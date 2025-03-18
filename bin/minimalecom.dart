import 'dart:developer' as developer;
import 'package:args/args.dart';

const String version = '0.0.1';

ArgParser buildParser() {
  return ArgParser()
    ..addFlag(
      'help',
      abbr: 'h',
      negatable: false,
      help: 'Print this usage information.',
    )
    ..addFlag(
      'verbose',
      abbr: 'v',
      negatable: false,
      help: 'Show additional command output.',
    )
    ..addFlag(
      'version',
      negatable: false,
      help: 'Print the tool version.',
    );
}

void printUsage(ArgParser argParser) {
  developer.log(
    'Usage: dart minimalecom.dart <flags> [arguments]',
    name: 'minimalecom',
  );
  developer.log(
    argParser.usage,
    name: 'minimalecom',
  );
}

void main(List<String> arguments) {
  final ArgParser argParser = buildParser();
  try {
    final ArgResults results = argParser.parse(arguments);
    bool verbose = false;

    // Process the parsed arguments.
    if (results.wasParsed('help')) {
      printUsage(argParser);
      return;
    }
    if (results.wasParsed('version')) {
      developer.log(
        'minimalecom version: $version',
        name: 'minimalecom',
      );
      return;
    }
    if (results.wasParsed('verbose')) {
      verbose = true;
    }

    developer.log(
      'Positional arguments: ${results.rest}',
      name: 'minimalecom',
    );
    if (verbose) {
      developer.log(
        '[VERBOSE] All arguments: ${results.arguments}',
        name: 'minimalecom',
      );
    }
  } on FormatException catch (e) {
    // Log usage information if an invalid argument was provided.
    developer.log(e.message, name: 'minimalecom');
    developer.log('', name: 'minimalecom');
    printUsage(argParser);
  }
}
