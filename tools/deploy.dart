// ignore_for_file: avoid_print
import 'dart:io';

void main(List<String> args) async {
  // Determine build type from arguments or prompt
  String? buildType;
  if (args.isNotEmpty) {
    buildType = args[0].toLowerCase();
  } else {
    stdout.write('Build target (apk / appbundle)? ');
    buildType = stdin.readLineSync()?.toLowerCase();
  }

  if (buildType != 'apk' && buildType != 'appbundle' && buildType != 'app') {
    print('❌ Invalid target. Please use "apk" or "appbundle".');
    return;
  }

  print('🚀 Starting Production Build Pipeline for $buildType...');

  final pubspecFile = File('pubspec.yaml');
  if (!await pubspecFile.exists()) {
    print('❌ Error: pubspec.yaml not found.');
    return;
  }

  final String originalPubspecContent = await pubspecFile.readAsString();
  List<String> lines = await pubspecFile.readAsLines();
  String? oldVersion;
  String? newVersion;

  // 1. VERSIONING LOGIC
  if (buildType == 'appbundle'|| buildType == 'app') {
    for (int i = 0; i < lines.length; i++) {
      if (lines[i].trim().startsWith('version:')) {
        oldVersion = lines[i].split(':')[1].trim();
        final parts = oldVersion.split('+');
        final semantic = parts[0];
        final buildNumber = int.parse(parts[1]) + 1;
        newVersion = '$semantic+$buildNumber';
        lines[i] = 'version: $newVersion';
        break;
      }
    }

    if (newVersion != null) {
      await pubspecFile.writeAsString(lines.join('\n'));
      print('✅ pubspec.yaml: Temporarily updated version to $newVersion');
    }
  } else {
    print('ℹ️  Skipping version increment for APK build.');
  }

  // 2. COMPILE
  print('📦 Compiling Production $buildType...');

  final process = await Process.start('flutter', ['build', buildType!, '--release', '--dart-define=PROD=true']);

  await stdout.addStream(process.stdout);
  await stderr.addStream(process.stderr);

  final exitCode = await process.exitCode;

  if (exitCode == 0) {
    print('🎉 Build Complete! $buildType is ready.');
  } else {
    // 3. ROLLBACK (Only if we actually changed the file)
    if (buildType == 'appbundle') {
      print('❌ Build failed. Rolling back pubspec.yaml...');
      await pubspecFile.writeAsString(originalPubspecContent);
      print('✅ Rollback complete.');
    } else {
      print('❌ Build failed.');
    }
    exit(1);
  }
}
