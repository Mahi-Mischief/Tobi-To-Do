class AvatarConfig {
  final String body;
  final String hairBack;
  final String hairFront;
  final String bangs;
  final String eyebrows;
  final String eyelashes;
  final String pupils;
  final String mouth;
  final String top;
  final String dress;
  final String bottom;
  final String gloves;
  final String shoes;
  final String beard;
  final String hairBonus;
  final String extras;

  const AvatarConfig({
    required this.body,
    required this.hairBack,
    required this.hairFront,
    required this.bangs,
    required this.eyebrows,
    required this.eyelashes,
    required this.pupils,
    required this.mouth,
    required this.top,
    required this.dress,
    required this.bottom,
    required this.gloves,
    required this.shoes,
    required this.beard,
    required this.hairBonus,
    required this.extras,
  });

  AvatarConfig copyWith({
    String? body,
    String? hairBack,
    String? hairFront,
    String? bangs,
    String? eyebrows,
    String? eyelashes,
    String? pupils,
    String? mouth,
    String? top,
    String? dress,
    String? bottom,
    String? gloves,
    String? shoes,
    String? beard,
    String? hairBonus,
    String? extras,
  }) {
    return AvatarConfig(
      body: body ?? this.body,
      hairBack: hairBack ?? this.hairBack,
      hairFront: hairFront ?? this.hairFront,
      bangs: bangs ?? this.bangs,
      eyebrows: eyebrows ?? this.eyebrows,
      eyelashes: eyelashes ?? this.eyelashes,
      pupils: pupils ?? this.pupils,
      mouth: mouth ?? this.mouth,
      top: top ?? this.top,
      dress: dress ?? this.dress,
      bottom: bottom ?? this.bottom,
      gloves: gloves ?? this.gloves,
      shoes: shoes ?? this.shoes,
      beard: beard ?? this.beard,
      hairBonus: hairBonus ?? this.hairBonus,
      extras: extras ?? this.extras,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'body': body,
      'hairBack': hairBack,
      'hairFront': hairFront,
      'bangs': bangs,
      'eyebrows': eyebrows,
      'eyelashes': eyelashes,
      'pupils': pupils,
      'mouth': mouth,
      'top': top,
      'dress': dress,
      'bottom': bottom,
      'gloves': gloves,
      'shoes': shoes,
      'beard': beard,
      'hairBonus': hairBonus,
      'extras': extras,
    };
  }

  factory AvatarConfig.fromJson(Map<String, dynamic> json) {
    return AvatarConfig(
      body: json['body'] as String,
      hairBack: json['hairBack'] as String,
      hairFront: json['hairFront'] as String,
      bangs: json['bangs'] as String,
      eyebrows: json['eyebrows'] as String,
      eyelashes: json['eyelashes'] as String,
      pupils: json['pupils'] as String,
      mouth: json['mouth'] as String,
      top: json['top'] as String,
      dress: (json['dress'] as String?) ?? '',
      bottom: (json['bottom'] as String?) ?? '',
      gloves: (json['gloves'] as String?) ?? '',
      shoes: json['shoes'] as String,
      beard: (json['beard'] as String?) ?? '',
      hairBonus: (json['hairBonus'] as String?) ?? '',
      extras: (json['extras'] as String?) ?? '',
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AvatarConfig &&
        other.body == body &&
        other.hairBack == hairBack &&
        other.hairFront == hairFront &&
        other.bangs == bangs &&
        other.eyebrows == eyebrows &&
        other.eyelashes == eyelashes &&
        other.pupils == pupils &&
        other.mouth == mouth &&
        other.top == top &&
        other.dress == dress &&
        other.bottom == bottom &&
        other.gloves == gloves &&
        other.shoes == shoes &&
        other.beard == beard &&
        other.hairBonus == hairBonus &&
        other.extras == extras;
  }

  @override
  int get hashCode => Object.hash(
        body,
        hairBack,
        hairFront,
        bangs,
        eyebrows,
        eyelashes,
        pupils,
        mouth,
        top,
        dress,
        bottom,
        gloves,
        shoes,
        beard,
        hairBonus,
      extras,
      );

  static const AvatarConfig defaults = AvatarConfig(
    body: 'assets/avatar/body/1.png',
    hairBack: 'assets/avatar/hair_back/1.png',
    hairFront: 'assets/avatar/hair/1.png',
    bangs: 'assets/avatar/bangs/1.png',
    eyebrows: 'assets/avatar/EYEBROWS/1.png',
    eyelashes: 'assets/avatar/EYELASHES/1.png',
    pupils: 'assets/avatar/PUPILS/1.png',
    mouth: 'assets/avatar/MOUTH/1.png',
    top: 'assets/avatar/top/1.png',
    dress: '',
    bottom: '',
    gloves: '',
    shoes: 'assets/avatar/shoes/1.png',
    beard: '',
    hairBonus: '',
    extras: '',
  );
}
