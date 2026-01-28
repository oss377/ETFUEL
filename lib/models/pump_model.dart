class Pump {
  final int id;
  final String name;
  final String status;
  final bool isActive;
  final bool isUnderMaintenance;

  Pump({
    required this.id,
    required this.name,
    required this.status,
    required this.isActive,
    required this.isUnderMaintenance,
  });
}