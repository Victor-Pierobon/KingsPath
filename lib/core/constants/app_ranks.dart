enum Rank { E, D, C, B, A, S }

Rank rankFromLevel(int globalLevel) {
  if (globalLevel >= 150) return Rank.S;
  if (globalLevel >= 90) return Rank.A;
  if (globalLevel >= 50) return Rank.B;
  if (globalLevel >= 25) return Rank.C;
  if (globalLevel >= 10) return Rank.D;
  return Rank.E;
}
