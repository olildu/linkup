class SignupProgramOption {
  final String id;
  final String label;
  final int years;

  const SignupProgramOption({required this.id, required this.label, required this.years});

  factory SignupProgramOption.fromJson(Map<String, dynamic> json) {
    return SignupProgramOption(
      id: json['id'] as String,
      label: json['label'] as String,
      years: json['years'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'label': label, 'years': years};
  }
}

class SignupOptionsConfig {
  final int version;
  final List<SignupProgramOption> programs;

  const SignupOptionsConfig({required this.version, required this.programs});

  factory SignupOptionsConfig.fromJson(Map<String, dynamic> json) {
    return SignupOptionsConfig(
      version: json['version'] as int? ?? 1,
      programs: (json['programs'] as List<dynamic>? ?? const [])
          .map((program) => SignupProgramOption.fromJson(program as Map<String, dynamic>))
          .toList(),
    );
  }

  factory SignupOptionsConfig.fallback() {
    return const SignupOptionsConfig(
      version: 1,
      programs: [
        SignupProgramOption(
          id: 'btech-computer-science',
          label: 'BTech Computer Science',
          years: 4,
        ),
        SignupProgramOption(
          id: 'btech-information-technology',
          label: 'BTech Information Technology',
          years: 4,
        ),
        SignupProgramOption(
          id: 'btech-mechanical-engineering',
          label: 'BTech Mechanical Engineering',
          years: 4,
        ),
        SignupProgramOption(
          id: 'btech-civil-engineering',
          label: 'BTech Civil Engineering',
          years: 4,
        ),
        SignupProgramOption(
          id: 'btech-electrical-engineering',
          label: 'BTech Electrical Engineering',
          years: 4,
        ),
        SignupProgramOption(id: 'bsc-computer-science', label: 'BSc Computer Science', years: 3),
      ],
    );
  }

  List<String> get programLabels => programs.map((program) => program.label).toList();

  SignupProgramOption? programForValue(String? value) {
    if (value == null) {
      return null;
    }

    for (final program in programs) {
      if (program.id == value || program.label == value) {
        return program;
      }
    }

    return null;
  }

  SignupProgramOption get defaultProgram =>
      programs.isNotEmpty ? programs.first : SignupOptionsConfig.fallback().programs.first;

  List<String> yearLabelsForProgram(SignupProgramOption? program) {
    final selectedProgram = program ?? defaultProgram;
    return List.generate(selectedProgram.years, (index) => '${index + 1}');
  }

  Map<String, dynamic> toJson() {
    return {'version': version, 'programs': programs.map((program) => program.toJson()).toList()};
  }
}
