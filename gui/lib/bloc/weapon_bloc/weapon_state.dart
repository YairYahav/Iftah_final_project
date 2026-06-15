part of 'weapon_bloc.dart';

abstract class WeaponState extends Equatable {
  const WeaponState();
}

class WeaponModeChangedState extends WeaponArmSafeState {
  final WeaponMode weaponMode;

  const WeaponModeChangedState(
      this.weaponMode, super.isArmSafeEnable, super.isWeaponCooldownOn);
  @override
  List<Object> get props =>
      [weaponMode, super.isArmSafeEnable, super.isWeaponCooldownOn];
}

class OpenWeaponSetupPopUpState extends WeaponState {
  const OpenWeaponSetupPopUpState();

  @override
  List<Object?> get props => [];
}

class WeaponArmSafeState extends WeaponState {
  final bool isArmSafeEnable;
  final bool isWeaponCooldownOn;
  const WeaponArmSafeState(
    this.isArmSafeEnable,
    this.isWeaponCooldownOn,
  );

  @override
  List<Object> get props => [isArmSafeEnable, isWeaponCooldownOn];
}

class WeaponInitial extends WeaponState {
  final bool isArmSafeEnable;
  final bool isWeaponCooldownOn;
  const WeaponInitial(
    this.isWeaponCooldownOn,
    this.isArmSafeEnable,
  );
  @override
  List<Object> get props => [isArmSafeEnable, isWeaponCooldownOn];
}

class SafeSwitchOneFlippedState extends WeaponState {
  final bool switchValue;
  const SafeSwitchOneFlippedState(
    this.switchValue,
  );
  @override
  List<Object> get props => [
        switchValue,
      ];
}

class SafeSwitchTwoFlippedState extends WeaponState {
  final bool isSwitchAllowed;
  final bool safeSwitchValue;
  const SafeSwitchTwoFlippedState(this.safeSwitchValue, this.isSwitchAllowed);
  @override
  List<Object> get props => [safeSwitchValue, isSwitchAllowed];
}



