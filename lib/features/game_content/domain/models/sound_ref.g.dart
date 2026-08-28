// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sound_ref.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SoundRef _$SoundRefFromJson(Map<String, dynamic> json) => _SoundRef(
  builtIn: $enumDecodeNullable(_$SfxTypeEnumMap, json['builtIn']),
  remoteUrl: json['remoteUrl'] as String?,
);

Map<String, dynamic> _$SoundRefToJson(_SoundRef instance) => <String, dynamic>{
  'builtIn': _$SfxTypeEnumMap[instance.builtIn],
  'remoteUrl': instance.remoteUrl,
};

const _$SfxTypeEnumMap = {
  SfxType.machineGunShot: 'machineGunShot',
  SfxType.rocketLaunch: 'rocketLaunch',
  SfxType.cannonShot: 'cannonShot',
  SfxType.antiAirShot: 'antiAirShot',
  SfxType.laserShot: 'laserShot',
  SfxType.explosion: 'explosion',
  SfxType.enemyHit: 'enemyHit',
  SfxType.enemyShot: 'enemyShot',
  SfxType.enemyDeath: 'enemyDeath',
  SfxType.enemyEscape: 'enemyEscape',
  SfxType.goldGain: 'goldGain',
  SfxType.buildPlace: 'buildPlace',
  SfxType.towerDestroyed: 'towerDestroyed',
  SfxType.towerRepair: 'towerRepair',
  SfxType.towerUpgrade: 'towerUpgrade',
  SfxType.towerSell: 'towerSell',
  SfxType.waveStart: 'waveStart',
  SfxType.victory: 'victory',
  SfxType.defeat: 'defeat',
  SfxType.vehicleEngine: 'vehicleEngine',
  SfxType.vehicleExplosion: 'vehicleExplosion',
  SfxType.soldierPop: 'soldierPop',
};
