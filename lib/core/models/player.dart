import 'attribute.dart';
import '../constants/app_ranks.dart';

class Player {
  final String name;
  final List<Attribute> attributes;

  const Player({required this.name, required this.attributes});

  int get globalLevel {
    final sum = attributes.fold(0, (acc, a) => acc + a.level);
    return (sum - 5).clamp(1, 9999);
  }

  Rank get rank => rankFromLevel(globalLevel);

  Attribute? attribute(String id) {
    try {
      return attributes.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }

  Player copyWithAttribute(Attribute updated) {
    return Player(
      name: name,
      attributes: attributes.map((a) => a.id == updated.id ? updated : a).toList(),
    );
  }
}
