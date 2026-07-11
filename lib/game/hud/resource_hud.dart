// resource_hud.dart - UI untuk ammo, fuel, repair

import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../systems/resource_manager.dart';

class ResourceHUD extends PositionComponent {
  late TextComponent ammoText;
  late TextComponent fuelText;
  late TextComponent hpText;
  late TextComponent repairText;

  @override
  void onLoad() {
    super.onLoad();
    
    // Posisi di kiri atas
    position = Vector2(20, 20);
    
    // 1. Ammo
    ammoText = TextComponent(
      text: '🔫 Ammo: 10/10',
      position: Vector2(0, 0),
      textRenderer: TextPaint(
        style: TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
          shadows: [Shadow(color: Colors.black, blurRadius: 4)],
        ),
      ),
    );
    add(ammoText);
    
    // 2. Fuel
    fuelText = TextComponent(
      text: '⛽ Fuel: 100%',
      position: Vector2(0, 24),
      textRenderer: TextPaint(
        style: TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
          shadows: [Shadow(color: Colors.black, blurRadius: 4)],
        ),
      ),
    );
    add(fuelText);
    
    // 3. HP
    hpText = TextComponent(
      text: '❤️ HP: 100%',
      position: Vector2(0, 48),
      textRenderer: TextPaint(
        style: TextStyle(
          color: Colors.green,
          fontSize: 14,
          fontWeight: FontWeight.bold,
          shadows: [Shadow(color: Colors.black, blurRadius: 4)],
        ),
      ),
    );
    add(hpText);
    
    // 4. Repair status
    repairText = TextComponent(
      text: '',
      position: Vector2(0, 72),
      textRenderer: TextPaint(
        style: TextStyle(
          color: Colors.green,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          shadows: [Shadow(color: Colors.black, blurRadius: 4)],
        ),
      ),
    );
    add(repairText);
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    // Update ammo
    ammoText.text = '🔫 Ammo: ${ResourceManager.currentAmmo}/${ResourceManager.maxAmmo}';
    
    // Update fuel
    final fuelPercent = (ResourceManager.currentFuel / ResourceManager.maxFuel * 100);
    fuelText.text = '⛽ Fuel: ${fuelPercent.toInt()}%';
    fuelText.paint.color = fuelPercent > 30 ? Colors.white : Colors.orange;
    
    // Update HP
    final hpPercent = (ResourceManager.currentShipHp / ResourceManager.maxShipHp * 100);
    hpText.text = '❤️ HP: ${hpPercent.toInt()}%';
    hpText.paint.color = hpPercent > 50 ? Colors.green : Colors.orange;
    if (hpPercent < 25) hpText.paint.color = Colors.red;
    
    // Update repair status
    if (ResourceManager.isInRepairZone) {
      repairText.text = '🔧 REPAIRING...';
      repairText.paint.color = Colors.green;
    } else {
      repairText.text = '';
    }
    
    // Reload indicator
    if (ResourceManager.currentAmmo < ResourceManager.maxAmmo && ResourceManager.reloadCooldown > 0) {
      final reloadText = children.whereType<TextComponent>().firstWhere(
        (t) => t.text.startsWith('⏳'),
        orElse: () => TextComponent(text: ''),
      );
      if (reloadText.text.isEmpty) {
        final newText = TextComponent(
          text: '⏳ Reloading... ${ResourceManager.reloadCooldown.toInt()}s',
          position: Vector2(0, 96),
          textRenderer: TextPaint(
            style: TextStyle(
              color: Colors.yellow,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              shadows: [Shadow(color: Colors.black, blurRadius: 4)],
            ),
          ),
        );
        add(newText);
      } else {
        reloadText.text = '⏳ Reloading... ${ResourceManager.reloadCooldown.toInt()}s';
      }
    } else {
      // Hapus reload text
      final reloadText = children.whereType<TextComponent>().firstWhere(
        (t) => t.text.startsWith('⏳'),
        orElse: () => null,
      );
      if (reloadText != null) {
        reloadText.removeFromParent();
      }
    }
  }
}
