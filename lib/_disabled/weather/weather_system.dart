// weather_system.dart - Weather system (pake rain particle baru)

import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'rain_particle.dart';
import 'night_filter.dart';
import '../effects/fog_effect.dart';
import 'dart:math';

enum WeatherType { clear, night, rain, storm }

class WeatherSystem extends Component {
  WeatherType currentWeather = WeatherType.clear;
  double _timer = 0;
  double _changeInterval = 30;
  final Random _random = Random();
  
  late RainParticleSystem rainSystem;
  late NightFilter nightFilter;
  late FogEffect fogEffect;
  bool _initialized = false;

  @override
  Future<void> onLoad() async {
    super.onLoad();
    
    nightFilter = NightFilter();
    await gameRef.add(nightFilter);
    
    fogEffect = FogEffect();
    await gameRef.add(fogEffect);
    
    rainSystem = RainParticleSystem();
    await gameRef.add(rainSystem);
    
    _changeWeather();
    _initialized = true;
    print('🌤️ Weather system loaded!');
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!_initialized) return;
    
    _timer += dt;
    if (_timer >= _changeInterval) {
      _timer = 0;
      _changeWeather();
    }
  }

  void _changeWeather() {
    final roll = _random.nextDouble();
    if (roll < 0.4) currentWeather = WeatherType.clear;
    else if (roll < 0.6) currentWeather = WeatherType.night;
    else if (roll < 0.8) currentWeather = WeatherType.rain;
    else currentWeather = WeatherType.storm;
    
    _applyWeather();
    print('🌤️ Weather: $currentWeather');
  }

  void _applyWeather() {
    switch (currentWeather) {
      case WeatherType.clear:
        nightFilter.setDarkness(0);
        rainSystem.setIntensity(0);
        fogEffect.setDensity(0);
        break;
      case WeatherType.night:
        nightFilter.setDarkness(0.7);
        rainSystem.setIntensity(0);
        fogEffect.setDensity(0.1);
        break;
      case WeatherType.rain:
        nightFilter.setDarkness(0.2);
        rainSystem.setIntensity(0.5);
        fogEffect.setDensity(0.2);
        break;
      case WeatherType.storm:
        nightFilter.setDarkness(0.5);
        rainSystem.setIntensity(1.0);
        fogEffect.setDensity(0.4);
        break;
    }
  }
}
