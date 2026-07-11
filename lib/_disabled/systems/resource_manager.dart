// resource_manager.dart - Manajemen ammo & fuel

class ResourceManager {
  // ===== AMMO =====
  static const int maxAmmo = 10;
  static const int reloadTime = 5; // detik
  static double reloadCooldown = 0;
  static int currentAmmo = maxAmmo;

  // ===== FUEL (untuk pesawat) =====
  static const double maxFuel = 100;
  static double fuelConsumptionRate = 5; // per detik

  // ===== REPAIR =====
  static const double repairRate = 2; // HP per detik
  static bool isInRepairZone = false;

  // ===== UPDATE =====
  static void update(double dt) {
    // Reload ammo
    if (currentAmmo < maxAmmo) {
      reloadCooldown -= dt;
      if (reloadCooldown <= 0) {
        currentAmmo++;
        reloadCooldown = reloadTime;
      }
    }

    // Repair
    if (isInRepairZone && currentShipHp < maxShipHp) {
      currentShipHp += repairRate * dt;
      if (currentShipHp > maxShipHp) currentShipHp = maxShipHp;
    }
  }

  // ===== SHIP HP (sementara, bakal dihubungkan ke ship component) =====
  static double currentShipHp = 100;
  static const double maxShipHp = 100;

  // ===== AMMO ACTIONS =====
  static bool useAmmo() {
    if (currentAmmo > 0) {
      currentAmmo--;
      return true;
    }
    return false;
  }

  static void reloadAmmo() {
    currentAmmo = maxAmmo;
    reloadCooldown = 0;
  }

  // ===== FUEL ACTIONS =====
  static bool consumeFuel(double amount) {
    if (currentFuel >= amount) {
      currentFuel -= amount;
      return true;
    }
    return false;
  }

  static void refuel() {
    currentFuel = maxFuel;
  }

  // ===== FUEL (untuk pesawat) =====
  static double currentFuel = maxFuel;

  // ===== GETTER =====
  static double get ammoPercent => currentAmmo / maxAmmo;
  static double get fuelPercent => currentFuel / maxFuel;
  static double get hpPercent => currentShipHp / maxShipHp;
}
