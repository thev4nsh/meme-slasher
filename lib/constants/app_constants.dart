// ═══════════════════════════════════════════════
//  APP CONSTANTS  –  Edit faces/sounds here easily
// ═══════════════════════════════════════════════

class AppConstants {
  // ── Instagram ──────────────────────────────────
  static const String instaId    = 'the_v4nsh';
  static const String instaUrl   = 'https://instagram.com/the_v4nsh';
  static const String instaAsset = 'assets/images/insta.png';

  // ── Watermark ──────────────────────────────────
  static const String watermark  = '</>  V4nsh';

  // ── Lives ──────────────────────────────────────
  static const int    maxLives   = 3;

  // ── Spawn timing (seconds) ─────────────────────
  static const double minSpawnInterval = 0.8;
  static const double maxSpawnInterval = 1.8;

  // ── Physics ────────────────────────────────────
  static const double gravity          = 1800.0; // px/s²
  static const double minLaunchSpeed   = 900.0;
  static const double maxLaunchSpeed   = 1300.0;

  // ── Bomb chance (0.0 – 1.0) ────────────────────
  static const double bombChance       = 0.15;
}

// ═══════════════════════════════════════════════
//  FACE DATA  –  Add / remove faces here
//  score   : points awarded on slice
//  image   : file in assets/images/
//  left    : left-half  after slice
//  right   : right-half after slice
//  sound   : file in assets/audio/
// ═══════════════════════════════════════════════

class FaceData {
  final String name;
  final int    score;
  final String image;
  final String left;
  final String right;
  final String sound;

  const FaceData({
    required this.name,
    required this.score,
    required this.image,
    required this.left,
    required this.right,
    required this.sound,
  });
}

const List<FaceData> kFaces = [
  FaceData(
    name  : 'Abhi',
    score : 1,
    image : 'assets/images/abhi.png',
    left  : 'assets/images/abhi_left.png',
    right : 'assets/images/abhi_right.png',
    sound : 'assets/audio/abhi_bck.mp3',
  ),
  FaceData(
    name  : 'ACP',
    score : 2,
    image : 'assets/images/acp.png',
    left  : 'assets/images/acp_left.png',
    right : 'assets/images/acp_right.png',
    sound : 'assets/audio/acp_bc.mp3',
  ),
  FaceData(
    name  : 'Amma',
    score : 3,
    image : 'assets/images/amma.png',
    left  : 'assets/images/amma_left.png',
    right : 'assets/images/amma_right.png',
    sound : 'assets/audio/amma_atm.mp3',
  ),
  FaceData(
    name  : 'Modi',
    score : 4,
    image : 'assets/images/modi.png',
    left  : 'assets/images/modi_left.png',
    right : 'assets/images/modi_right.png',
    sound : 'assets/audio/modi_bkl.mp3',
  ),
  FaceData(
    name  : 'Rahul',
    score : 5,
    image : 'assets/images/rahul.png',
    left  : 'assets/images/rahul_left.png',
    right : 'assets/images/rahul_right.png',
    sound : 'assets/audio/rahul_maja.mp3',
  ),
];

// ── Bomb ──────────────────────────────────────
const String kBombImage = 'assets/images/bomb.png';
const String kBombSound = 'assets/audio/bomb.mp3';

// ── Miss / Background music ───────────────────
const String kMissSound     = 'assets/audio/miss.mp3';
const String kGameOverSound = 'assets/audio/gameover.mp3';
const String kBgMusic       = 'assets/audio/bg.mp3';
const String kWelcomeSound  = 'assets/audio/welcome.mp3';